import { CustomError } from "../lib/custom-error";
import {
  getScrapeQueue,
  redisConnection,
  scrapeQueueName,
} from "./queue-service";
import "dotenv/config";
import { logtail } from "./logtail";
import { startWebScraperPipeline } from "../main/runWebScraper";
import { callWebhook } from "./webhook";
import { logJob } from "./logging/log_job";
import { initSDK } from "@hyperdx/node-opentelemetry";
import { Job } from "bullmq";
import { Logger } from "../lib/logger";
import { Worker } from "bullmq";
import systemMonitor from "./system-monitor";
import { v4 as uuidv4 } from "uuid";
import { addCrawlJob, addCrawlJobDone, crawlToCrawler, getCrawl, getCrawlJobs, isCrawlFinished, lockURL } from "../lib/crawl-redis";
import { StoredCrawl } from "../lib/crawl-redis";
import { addScrapeJob } from "./queue-jobs";
import { supabaseGetJobById } from "../../src/lib/supabase-jobs";

if (process.env.ENV === "production") {
  initSDK({
    consoleCapture: true,
    additionalInstrumentations: [],
  });
}
const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const workerLockDuration = Number(process.env.WORKER_LOCK_DURATION) || 60000;
const workerStalledCheckInterval =
  Number(process.env.WORKER_STALLED_CHECK_INTERVAL) || 30000;
const jobLockExtendInterval =
  Number(process.env.JOB_LOCK_EXTEND_INTERVAL) || 15000;
const jobLockExtensionTime =
  Number(process.env.JOB_LOCK_EXTENSION_TIME) || 60000;

const cantAcceptConnectionInterval =
  Number(process.env.CANT_ACCEPT_CONNECTION_INTERVAL) || 2000;
const connectionMonitorInterval =
  Number(process.env.CONNECTION_MONITOR_INTERVAL) || 10;
const gotJobInterval = Number(process.env.CONNECTION_MONITOR_INTERVAL) || 20;

const processJobInternal = async (token: string, job: Job) => {
  const extendLockInterval = setInterval(async () => {
    Logger.info(`🐂 Worker extending lock on job ${job.id}`);
    await job.extendLock(token, jobLockExtensionTime);
  }, jobLockExtendInterval);

  try {
    const result = await processJob(job, token);
    try{
      if (job.data.crawl_id && process.env.USE_DB_AUTHENTICATION === "true") {
        await job.moveToCompleted(null, token, false);
      } else {
        await job.moveToCompleted(result.docs, token, false);
      }
    }catch(e){
    }
  } catch (error) {
    console.log("Job failed, error:", error);

    await job.moveToFailed(error, token, false);
  } finally {
    clearInterval(extendLockInterval);
  }
};

let isShuttingDown = false;

process.on("SIGINT", () => {
  console.log("Received SIGINT. Shutting down gracefully...");
  isShuttingDown = true;
});

const workerFun = async (queueName: string, processJobInternal: (token: string, job: Job) => Promise<void>) => {
  const worker = new Worker(queueName, null, {
    connection: redisConnection,
    lockDuration: 1 * 60 * 1000, // 1 minute
    // lockRenewTime: 15 * 1000, // 15 seconds
    stalledInterval: 30 * 1000, // 30 seconds
    maxStalledCount: 10, // 10 times
  });

  worker.startStalledCheckTimer();

  const monitor = await systemMonitor;

  while (true) {
    if (isShuttingDown) {
      console.log("No longer accepting new jobs. SIGINT");
      break;
    }
    const token = uuidv4();
    const canAcceptConnection = await monitor.acceptConnection();
    if (!canAcceptConnection) {
      console.log("Cant accept connection");
      await sleep(cantAcceptConnectionInterval); // more sleep
      continue;
    }

    const job = await worker.getNextJob(token);
    if (job) {
      processJobInternal(token, job);
      await sleep(gotJobInterval);
    } else {
      await sleep(connectionMonitorInterval);
    }
  }
};

workerFun(scrapeQueueName, processJobInternal);

async function processJob(job: Job, token: string) {
  Logger.info(`🐂 Worker taking job ${job.id}`);

  try {
    job.updateProgress({
      current: 1,
      total: 100,
      current_step: "SCRAPING",
      current_url: "",
    });
    const start = Date.now();
    const { success, message, docs } = await startWebScraperPipeline({
      job,
      token,
    });
    const end = Date.now();
    const timeTakenInSeconds = (end - start) / 1000;

    const data = {
      success,
      result: {
        links: docs.map((doc) => {
          return {
            content: doc,
            source: doc?.metadata?.sourceURL ?? doc?.url ?? "",
          };
        }),
      },
      project_id: job.data.project_id,
      error: message /* etc... */,
      docs,
    };

    if (job.data.mode === "crawl") {
      await callWebhook(job.data.team_id, job.id as string, data);
    }

    if (job.data.crawl_id) {
      await logJob({
        job_id: job.id as string,
        success: success,
        message: message,
        num_docs: docs.length,
        docs: docs,
        time_taken: timeTakenInSeconds,
        team_id: job.data.team_id,
        mode: job.data.mode,
        url: job.data.url,
        crawlerOptions: job.data.crawlerOptions,
        pageOptions: job.data.pageOptions,
        origin: job.data.origin,
        crawl_id: job.data.crawl_id,
      });

      await addCrawlJobDone(job.data.crawl_id, job.id);

      const sc = await getCrawl(job.data.crawl_id) as StoredCrawl;

      if (!job.data.sitemapped) {
        if (!sc.cancelled) {
          const crawler = crawlToCrawler(job.data.crawl_id, sc);

          const links = crawler.filterLinks((data.docs[0].linksOnPage ?? [])
            .map(href => crawler.filterURL(href.trim(), sc.originUrl))
            .filter(x => x !== null),
            Infinity,
            sc.crawlerOptions?.maxDepth ?? 10
          )
          
          for (const link of links) {
            if (await lockURL(job.data.crawl_id, sc, link)) {
              const newJob = await addScrapeJob({
                url: link,
                mode: "single_urls",
                crawlerOptions: sc.crawlerOptions,
                team_id: sc.team_id,
                pageOptions: sc.pageOptions,
                origin: job.data.origin,
                crawl_id: job.data.crawl_id,
              });

              await addCrawlJob(job.data.crawl_id, newJob.id);
            }
          }
        }
      }

      if (await isCrawlFinished(job.data.crawl_id)) {
        const jobIDs = await getCrawlJobs(job.data.crawl_id);

        const jobs = (await Promise.all(jobIDs.map(async x => {
          if (x === job.id) {
            return {
              async getState() {
                return "completed"
              },
              timestamp: Date.now(),
              returnvalue: docs,
            }
          }

          const j = await getScrapeQueue().getJob(x);
          
          if (process.env.USE_DB_AUTHENTICATION === "true") {
            const supabaseData = await supabaseGetJobById(j.id);
    
            if (supabaseData) {
              j.returnvalue = supabaseData.docs;
            }
          }
    
          return j;
        }))).sort((a, b) => a.timestamp - b.timestamp);
        const jobStatuses = await Promise.all(jobs.map(x => x.getState()));
        const jobStatus = sc.cancelled ? "failed" : jobStatuses.every(x => x === "completed") ? "completed" : jobStatuses.some(x => x === "failed") ? "failed" : "active";
    
        const fullDocs = jobs.map(x => Array.isArray(x.returnvalue) ? x.returnvalue[0] : x.returnvalue);

        await logJob({
          job_id: job.data.crawl_id,
          success: jobStatus === "completed",
          message: message,
          num_docs: fullDocs.length,
          docs: [],
          time_taken: (Date.now() - sc.createdAt) / 1000,
          team_id: job.data.team_id,
          mode: "crawl",
          url: sc.originUrl,
          crawlerOptions: sc.crawlerOptions,
          pageOptions: sc.pageOptions,
          origin: job.data.origin,
        });

        const data = {
          success: jobStatus !== "failed",
          result: {
            links: fullDocs.map((doc) => {
              return {
                content: doc,
                source: doc?.metadata?.sourceURL ?? doc?.url ?? "",
              };
            }),
          },
          project_id: job.data.project_id,
          error: message /* etc... */,
          docs: fullDocs,
        };

        await callWebhook(job.data.team_id, job.data.crawl_id, data);
      }
    }

    Logger.info(`🐂 Job done ${job.id}`);
    return data;
  } catch (error) {
    Logger.error(`🐂 Job errored ${job.id} - ${error}`);

    if (error instanceof CustomError) {
      // Here we handle the error, then save the failed job
      Logger.error(error.message); // or any other error handling

      logtail.error("Custom error while ingesting", {
        job_id: job.id,
        error: error.message,
        dataIngestionJob: error.dataIngestionJob,
      });
    }
    Logger.error(error);
    if (error.stack) {
      Logger.error(error.stack);
    }

    logtail.error("Overall error ingesting", {
      job_id: job.id,
      error: error.message,
    });

    const data = {
      success: false,
      docs: [],
      project_id: job.data.project_id,
      error:
        "Something went wrong... Contact help@mendable.ai or try again." /* etc... */,
    };
    
    if (job.data.mode === "crawl" || job.data.crawl_id) {
      await callWebhook(job.data.team_id, job.data.crawl_id ?? job.id as string, data);
    }
    
    if (job.data.crawl_id) {
      await logJob({
        job_id: job.id as string,
        success: false,
        message:
          typeof error === "string"
            ? error
            : error.message ?? "Something went wrong... Contact help@mendable.ai",
        num_docs: 0,
        docs: [],
        time_taken: 0,
        team_id: job.data.team_id,
        mode: job.data.mode,
        url: job.data.url,
        crawlerOptions: job.data.crawlerOptions,
        pageOptions: job.data.pageOptions,
        origin: job.data.origin,
        crawl_id: job.data.crawl_id,
      });

      const sc = await getCrawl(job.data.crawl_id);

      await logJob({
        job_id: job.data.crawl_id,
        success: false,
        message:
          typeof error === "string"
            ? error
            : error.message ?? "Something went wrong... Contact help@mendable.ai",
        num_docs: 0,
        docs: [],
        time_taken: 0,
        team_id: job.data.team_id,
        mode: "crawl",
        url: sc ? sc.originUrl : job.data.url,
        crawlerOptions: sc ? sc.crawlerOptions : job.data.crawlerOptions,
        pageOptions: sc ? sc.pageOptions : job.data.pageOptions,
        origin: job.data.origin,
      });
    }
    // done(null, data);
    return data;
  }
}

// wsq.process(
//   Math.floor(Number(process.env.NUM_WORKERS_PER_QUEUE ?? 8)),
//   processJob
// );

// wsq.on("waiting", j => ScrapeEvents.logJobEvent(j, "waiting"));
// wsq.on("active", j => ScrapeEvents.logJobEvent(j, "active"));
// wsq.on("completed", j => ScrapeEvents.logJobEvent(j, "completed"));
// wsq.on("paused", j => ScrapeEvents.logJobEvent(j, "paused"));
// wsq.on("resumed", j => ScrapeEvents.logJobEvent(j, "resumed"));
// wsq.on("removed", j => ScrapeEvents.logJobEvent(j, "removed"));

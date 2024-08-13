import { Job, Queue } from "bullmq";
import { getScrapeQueue } from "./queue-service";
import { v4 as uuidv4 } from "uuid";
import { WebScraperOptions } from "../types";

export async function addScrapeJob(
  webScraperOptions: WebScraperOptions,
  options: any = {},
  jobId: string = uuidv4(),
): Promise<Job> {
  return await getScrapeQueue().add(jobId, webScraperOptions, {
    ...options,
    jobId,
    priority: webScraperOptions.crawl_id ? 2 : 1,
  });
}


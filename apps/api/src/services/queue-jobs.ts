import { Job, Queue } from "bull";
import {
  getWebScraperQueue,
} from "./queue-service";
import { v4 as uuidv4 } from "uuid";
import { WebScraperOptions } from "../types";

export async function addWebScraperJob(
  webScraperOptions: WebScraperOptions,
  options: any = {},
  jobId: string = uuidv4(),
): Promise<Job> {
  return await getWebScraperQueue().add(webScraperOptions, {
    ...options,
    jobId,
  });
}


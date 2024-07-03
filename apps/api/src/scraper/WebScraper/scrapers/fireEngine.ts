import axios from "axios";
import { FireEngineResponse } from "../../../lib/entities";
import { logScrape } from "../../../services/logging/scrape_log";
import { generateRequestParams } from "../single_url";
import { fetchAndProcessPdf } from "../utils/pdfProcessor";
import { universalTimeout } from "../global";

export async function scrapWithFireEngine({
  url,
  waitFor = 0,
  screenshot = false,
  pageOptions = { parsePDF: true },
  headers,
  options,
}: {
  url: string;
  waitFor?: number;
  screenshot?: boolean;
  pageOptions?: { scrollXPaths?: string[]; parsePDF?: boolean };
  headers?: Record<string, string>;
  options?: any;
}): Promise<FireEngineResponse> {
  const logParams = {
    url,
    scraper: "fire-engine",
    success: false,
    response_code: null,
    time_taken_seconds: null,
    error_message: null,
    html: "",
    startTime: Date.now(),
  };

  try {
    const reqParams = await generateRequestParams(url);
    const waitParam = reqParams["params"]?.wait ?? waitFor;
    const screenshotParam = reqParams["params"]?.screenshot ?? screenshot;
    console.log(
      `[Fire-Engine] Scraping ${url} with wait: ${waitParam} and screenshot: ${screenshotParam}`
    );

    const response = await axios.post(
      process.env.FIRE_ENGINE_BETA_URL + "/scrape",
      {
        url: url,
        wait: waitParam,
        screenshot: screenshotParam,
        headers: headers,
        pageOptions: pageOptions,
      },
      {
        headers: {
          "Content-Type": "application/json",
        },
        timeout: universalTimeout + waitParam,
      }
    );

    if (response.status !== 200) {
      console.error(
        `[Fire-Engine] Error fetching url: ${url} with status: ${response.status}`
      );
      logParams.error_message = response.data?.pageError;
      logParams.response_code = response.data?.pageStatusCode;
      return {
        html: "",
        screenshot: "",
        pageStatusCode: response.data?.pageStatusCode,
        pageError: response.data?.pageError,
      };
    }

    const contentType = response.headers["content-type"];
    if (contentType && contentType.includes("application/pdf")) {
      const { content, pageStatusCode, pageError } = await fetchAndProcessPdf(
        url,
        pageOptions?.parsePDF
      );
      logParams.success = true;
      // We shouldnt care about the pdf logging here I believe
      return { html: content, screenshot: "", pageStatusCode, pageError };
    } else {
      const data = response.data;
      logParams.success =
        (data.pageStatusCode >= 200 && data.pageStatusCode < 300) ||
        data.pageStatusCode === 404;
      logParams.html = data.content ?? "";
      logParams.response_code = data.pageStatusCode;
      logParams.error_message = data.pageError;
      return {
        html: data.content ?? "",
        screenshot: data.screenshot ?? "",
        pageStatusCode: data.pageStatusCode,
        pageError: data.pageError,
      };
    }
  } catch (error) {
    if (error.code === "ECONNABORTED") {
      console.log(`[Fire-Engine] Request timed out for ${url}`);
      logParams.error_message = "Request timed out";
    } else {
      console.error(`[Fire-Engine][c] Error fetching url: ${url} -> ${error}`);
      logParams.error_message = error.message || error;
    }
    return { html: "", screenshot: "" };
  } finally {
    const endTime = Date.now();
    const time_taken_seconds = (endTime - logParams.startTime) / 1000;
    await logScrape({
      url: logParams.url,
      scraper: logParams.scraper,
      success: logParams.success,
      response_code: logParams.response_code,
      time_taken_seconds,
      error_message: logParams.error_message,
      html: logParams.html,
    });
  }
}

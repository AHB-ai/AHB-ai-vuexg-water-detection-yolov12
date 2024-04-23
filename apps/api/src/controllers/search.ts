import { Request, Response } from "express";
import { WebScraperDataProvider } from "../scraper/WebScraper";
import { billTeam, checkTeamCredits } from "../services/billing/credit_billing";
import { authenticateUser } from "./auth";
import { RateLimiterMode } from "../types";
import { logJob } from "../services/logging/log_job";
import { PageOptions, SearchOptions } from "../lib/entities";
import { search } from "../search/googlesearch";

export async function searchHelper(
  req: Request,
  team_id: string,
  crawlerOptions: any,
  pageOptions: PageOptions,
  searchOptions: SearchOptions
): Promise<{
  success: boolean;
  error?: string;
  data?: any;
  returnCode: number;
}> {
  const query = req.body.query;
  const advanced = false;
  if (!query) {
    return { success: false, error: "Query is required", returnCode: 400 };
  }

  const res = await search(query, advanced, searchOptions.limit ?? 7);

  let justSearch = pageOptions.fetchPageContent === false;

  if (justSearch) {
    return { success: true, data: res, returnCode: 200 };
  }

  if (res.results.length === 0) {
    return { success: true, error: "No search results found", returnCode: 200 };
  }
  console.log(res.results);

  const a = new WebScraperDataProvider();
  await a.setOptions({
    mode: "single_urls",
    urls: res.results.map((r) => (!advanced ? r : r.url)),
    crawlerOptions: {
      ...crawlerOptions,
    },
    pageOptions: {
      ...pageOptions,
      onlyMainContent: pageOptions?.onlyMainContent ?? true,
      fetchPageContent: pageOptions?.fetchPageContent ?? true,
      fallback: false,
    },
  });

  const docs = await a.getDocuments(true);
  if (docs.length === 0) {
    return { success: true, error: "No search results found", returnCode: 200 };
  }

  // make sure doc.content is not empty
  const filteredDocs = docs.filter(
    (doc: { content?: string }) => doc.content && doc.content.trim().length > 0
  );

  if (filteredDocs.length === 0) {
    return { success: true, error: "No page found", returnCode: 200 };
  }

  const { success, credit_usage } = await billTeam(
    team_id,
    filteredDocs.length
  );
  if (!success) {
    return {
      success: false,
      error:
        "Failed to bill team. Insufficient credits or subscription not found.",
      returnCode: 402,
    };
  }

  return {
    success: true,
    data: filteredDocs,
    returnCode: 200,
  };
}

export async function searchController(req: Request, res: Response) {
  try {
    // make sure to authenticate user first, Bearer <token>
    const { success, team_id, error, status } = await authenticateUser(
      req,
      res,
      RateLimiterMode.Search
    );
    if (!success) {
      return res.status(status).json({ error });
    }
    const crawlerOptions = req.body.crawlerOptions ?? {};
    const pageOptions = req.body.pageOptions ?? {
      onlyMainContent: true,
      fetchPageContent: true,
      fallback: false,
    };
    const origin = req.body.origin ?? "api";

    const searchOptions = req.body.searchOptions ?? { limit: 7 };

    try {
      const { success: creditsCheckSuccess, message: creditsCheckMessage } =
        await checkTeamCredits(team_id, 1);
      if (!creditsCheckSuccess) {
        return res.status(402).json({ error: "Insufficient credits" });
      }
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: "Internal server error" });
    }
    const startTime = new Date().getTime();
    const result = await searchHelper(
      req,
      team_id,
      crawlerOptions,
      pageOptions,
      searchOptions
    );
    const endTime = new Date().getTime();
    const timeTakenInSeconds = (endTime - startTime) / 1000;
    logJob({
      success: result.success,
      message: result.error,
      num_docs: 1,
      docs: [result.data],
      time_taken: timeTakenInSeconds,
      team_id: team_id,
      mode: "search",
      url: req.body.url,
      crawlerOptions: crawlerOptions,
      pageOptions: pageOptions,
      origin: origin,
    });
    return res.status(result.returnCode).json(result);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
}

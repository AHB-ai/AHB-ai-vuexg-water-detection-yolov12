import FirecrawlApp, { CrawlStatusResponse, CrawlResponse } from '@mendable/firecrawl-js';

const app = new FirecrawlApp({apiKey: "fc-YOUR_API_KEY"});

const main = async () => {

  // Scrape a website:
  const scrapeResult = await app.scrapeUrl('firecrawl.dev');

  if (scrapeResult) {
    console.log(scrapeResult.markdown)
  }

  // Crawl a website:
  // @ts-ignore
  const crawlResult = await app.crawlUrl('mendable.ai', { excludePaths: ['blog/*'], limit: 5}, false) as CrawlResponse;
  console.log(crawlResult)

  const id = crawlResult.id;
  console.log(id);

  let checkStatus: CrawlStatusResponse;
  while (true) {
    checkStatus = await app.checkCrawlStatus(id);
    if (checkStatus.status === 'completed') {
      break;
    }
    await new Promise(resolve => setTimeout(resolve, 1000)); // wait 1 second
  }

  if (checkStatus.data) {
    console.log(checkStatus.data[0].markdown);
  }

  // Map a website:
  const mapResult = await app.mapUrl('https://firecrawl.dev');
  console.log(mapResult)

  // Crawl a website with WebSockets:
  const watch = await app.crawlUrlAndWatch('mendable.ai', { excludePaths: ['blog/*'], limit: 5});

  watch.addEventListener("document", doc => {
    console.log("DOC", doc.detail);
  });

  watch.addEventListener("error", err => {
    console.error("ERR", err.detail.error);
  });

  watch.addEventListener("done", state => {
    console.log("DONE", state.detail.status);
  });
}

main()
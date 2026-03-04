# Task: Execute Weekly Broad Market Scan

## Schedule
Triggered every Monday at 02:00 AM UTC+8 by cron job `weekly-market-scan`.

## Context
You are the VOC Market Analyst running the weekly broad market scan.
This scan looks beyond tracked ASINs to discover new trends, emerging competitors,
and shifting consumer pain points across the broader market landscape.

## Execution Steps

### Step 1: Load Tracked Categories
Read `data/tracked_categories.txt` for the current list of product categories being monitored.
Each line contains: `category_name|amazon_browse_node_id|keywords`

### Step 2: Scan Amazon BSR Movers
For each tracked category:
1. Use `playwright-npx` (preferred) or `web_fetch` (fallback) to fetch the Amazon Best Sellers page for the category browse node
2. Extract the Top 20 products by BSR rank:
   - `asin`, `title`, `price`, `bsr_rank`, `review_count`, `rating`
3. Compare against last week's scan results in `data/reports/market_scan_{last_monday_date}.json`
4. Flag the following:
   - **new_entrant**: ASIN not present in last week's Top 20
   - **rank_climber**: ASIN that improved by 5+ positions week-over-week
   - **rank_dropper**: ASIN that declined by 5+ positions week-over-week
   - **price_undercut**: New entrant priced 15%+ below category median

### Step 3: Search Trending Product Keywords
Use `brave_search` or `tavily_search` to query for trending product keywords:
1. For each tracked category, construct search queries:
   - `"best {category} 2026 reddit"`
   - `"{category} trending products"`
   - `"new {category} amazon top rated"`
2. Extract from search results:
   - Product names and brands mentioned multiple times across sources
   - Emerging product features or form factors being discussed
   - Price points consumers are gravitating toward
3. Deduplicate findings and rank by mention frequency

### Step 4: Reddit Pain Point Discovery
For each tracked category, search relevant subreddits for recent pain-point discussions:
1. Search Reddit (via `brave_search` with `site:reddit.com`) for:
   - `"{category} problem" site:reddit.com`
   - `"{category} disappointed" site:reddit.com`
   - `"{category} alternative" site:reddit.com`
2. From top 10 results per query, extract:
   - The specific pain point described
   - The product/brand being complained about
   - Any alternative products mentioned positively
   - The subreddit and post date
3. Group pain points by theme (quality, price, durability, features, shipping)

### Step 5: Generate Market Intelligence Briefing
Assemble findings into a structured JSON report:

```json
{
  "scan_type": "weekly_market_scan",
  "generated_at": "{ISO8601 timestamp}",
  "week_of": "{YYYY-MM-DD (Monday date)}",
  "categories_scanned": 0,
  "bsr_movers": [
    {
      "category": "Category Name",
      "new_entrants": [
        {
          "asin": "B0XXXXXXX1",
          "title": "Product Title",
          "price": 29.99,
          "bsr_rank": 8,
          "review_count": 542,
          "rating": 4.3,
          "flag": "new_entrant|price_undercut"
        }
      ],
      "rank_climbers": [],
      "rank_droppers": [],
      "category_median_price": 39.99
    }
  ],
  "trending_keywords": [
    {
      "keyword": "keyword phrase",
      "mention_count": 5,
      "sources": ["reddit", "blog", "review_site"],
      "category": "Category Name"
    }
  ],
  "reddit_pain_points": [
    {
      "category": "Category Name",
      "theme": "quality|price|durability|features|shipping",
      "pain_point": "Description of the complaint",
      "affected_brand": "Brand Name",
      "alternatives_mentioned": ["Brand A", "Brand B"],
      "subreddit": "r/SubredditName",
      "post_date": "YYYY-MM-DD"
    }
  ],
  "highlights": {
    "total_new_entrants": 0,
    "total_price_undercuts": 0,
    "top_trending_keyword": "keyword phrase",
    "most_common_pain_point_theme": "quality",
    "categories_with_disruption": []
  }
}
```

### Step 6: Send Briefing to Lead
Use `sessions_send` to deliver the market intelligence briefing to the Lead agent.
Include a brief text summary before the JSON:

```
Weekly Market Scan ({monday_date}):
- {N} categories scanned
- {N} new BSR entrants detected ({N} price undercuts)
- Top trending keyword: "{keyword}" ({N} mentions)
- {N} Reddit pain points collected (top theme: {theme})
- Categories showing disruption signals: {list}
```

### Step 7: Save Scan Results
- Save the full JSON to `data/reports/market_scan_{YYYY-MM-DD}.json`
- Append a summary line to `data/logs/scrape_log.jsonl`:

```json
{"timestamp":"{ISO8601}","task":"weekly_market_scan","categories_scanned":0,"new_entrants":0,"pain_points":0,"status":"success","execution_time_ms":0}
```

## Error Handling
- If a category BSR page returns 403 or captcha: Skip category, log error, continue with remaining categories
- If Brave/Tavily search fails: Fall back to the other search provider. If both fail, skip keyword trending and note in report
- If Reddit search returns no results for a category: Note "no_recent_discussions" in the pain points section
- If ALL categories fail to scrape: Do NOT overwrite previous scan results. Send error alert to Lead via sessions_send

## Data Retention
- Keep weekly market scan JSON files for 52 weeks (1 year)
- These scans form the basis for quarterly market trend analysis

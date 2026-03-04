# Task: Add Competitor ASINs to Tracking System

## Trigger
Received via `sessions_send` from Lead agent with `task_type: "add_competitor"`.

## Input Format

```json
{
  "task_type": "add_competitor",
  "competitor_asins": ["B0XXXXXXX1", "B0XXXXXXX2"],
  "category": "product category name",
  "request_id": "req_YYYYMMDD_NNN"
}
```

## Execution Steps

1. **Parse input ASIN list**
   - Extract all ASINs from the `competitor_asins` array
   - Validate each ASIN matches the expected format (starts with `B0`, 10 characters)
   - Skip and log any invalid ASINs

2. **Scrape current product data for each ASIN**
   Use the following tool priority for scraping each Amazon product page:
   - **Primary**: Decodo `amazon` skill with the ASIN as input
   - **Fallback 1**: `playwright-npx` to load `https://amazon.com/dp/{ASIN}` and extract data
   - **Fallback 2**: `web_fetch` for the same URL

   Extract the following fields for each ASIN:
   - `asin`: the ASIN string
   - `title`: full product title
   - `brand`: brand name
   - `current_price`: numeric price in USD
   - `currency`: "USD"
   - `current_rating`: star rating (e.g., 4.3)
   - `review_count`: total number of reviews
   - `bsr_rank`: Best Seller Rank in the primary category
   - `bsr_category`: the category name for the BSR rank
   - `stock_status`: "in_stock" | "low_stock" | "out_of_stock"
   - `promo_tag`: any active promotion ("Lightning Deal", "Coupon", "Subscribe & Save", or empty)
   - `main_image_url`: URL of the primary product image
   - `seller_type`: "FBA" | "FBM" | "brand_direct" (if identifiable)
   - `category`: from the input task
   - `added_date`: ISO 8601 timestamp of when this profile was created
   - `scrape_tool`: which tool was used to extract the data
   - `url`: full Amazon product URL

3. **Create competitor profile JSON files**
   For each successfully scraped ASIN, save a profile to `data/competitor_profiles/{ASIN}.json`:

   ```json
   {
     "asin": "B0XXXXXXX1",
     "title": "Product Title Here",
     "brand": "Brand Name",
     "category": "camping folding bed",
     "current_price": 49.99,
     "currency": "USD",
     "current_rating": 4.1,
     "review_count": 3200,
     "bsr_rank": 3,
     "bsr_category": "Camping Cots",
     "stock_status": "in_stock",
     "promo_tag": "",
     "main_image_url": "https://images-na.ssl-images-amazon.com/...",
     "seller_type": "FBA",
     "added_date": "2026-03-05T14:30:00+08:00",
     "scrape_tool": "decodo/amazon",
     "url": "https://amazon.com/dp/B0XXXXXXX1",
     "price_history": [
       {
         "date": "2026-03-05",
         "price": 49.99,
         "bsr_rank": 3,
         "review_count": 3200,
         "stock_status": "in_stock"
       }
     ]
   }
   ```

   - If a profile already exists for the ASIN, update the fields with fresh data and append to `price_history` array
   - Do NOT overwrite `added_date` or `price_history` on update

4. **Add entries to price_memory.txt**
   Append each new ASIN to `data/price_memory.txt` for daily cron monitoring:

   ```
   {ASIN}|{title}|{price}|{currency}|{stock_status}|{bsr_rank}|{promo_tag}|{url}
   ```

   - If the ASIN already exists in `price_memory.txt`, update the line with fresh data
   - Preserve the file header comments
   - Update the `# Updated:` timestamp in the header

5. **Send confirmation to Lead**
   Use `sessions_send` to deliver a confirmation message to the Lead agent:

   ```json
   {
     "status": "completed",
     "agent": "voc-analyst",
     "task_type": "add_competitor",
     "request_id": "req_YYYYMMDD_NNN",
     "results": {
       "asins_requested": 2,
       "asins_added": 2,
       "asins_failed": 0,
       "profiles_created": [
         {
           "asin": "B0XXXXXXX1",
           "title": "Product Title",
           "price": 49.99,
           "rating": 4.1,
           "reviews": 3200,
           "bsr_rank": 3
         }
       ],
       "failures": []
     },
     "message": "Successfully added 2 competitor ASINs to tracking. Daily price monitoring will begin on next cron cycle (03:00 AM UTC+8)."
   }
   ```

6. **Log the operation**
   Append to `data/logs/scrape_log.jsonl`:

   ```json
   {"timestamp":"{ISO8601}","tool":"competitor_tracking","query":"add_competitor {ASIN_list}","results":{count},"status":"success","request_id":"{request_id}"}
   ```

## Error Handling

- If Decodo fails for an ASIN, try `playwright-npx`, then `web_fetch`
- If all tools fail for an ASIN, include it in the `failures` array with error reason
- If the Amazon product page returns 404 (product not found), report as `"error": "ASIN not found or product removed"`
- If rate-limited (HTTP 429), wait 60 seconds and retry once
- Apply standard retry policy: 3 retries, exponential backoff (5s, 15s, 45s)
- Always send confirmation to Lead even if some ASINs failed -- include partial results

## Notes

- Competitor profiles are the foundation for the daily price monitoring cron job (`price_monitor.md`)
- New ASINs added here will be picked up by the next daily cron run automatically
- The weekly digest cron (`weekly_digest.md`) will include new ASINs in its next Sunday report

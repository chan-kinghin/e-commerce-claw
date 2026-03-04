# Task: Execute daily price monitoring sweep

## Context
You are the VOC Market Analyst running the daily price monitoring cron job.
This task runs at 03:00 AM UTC+8 (Beijing time) when most US sellers make overnight price adjustments.

## Execution Steps

### Step 1: Load Yesterday's Snapshot
Read `data/price_memory.txt` to load the previous price snapshot.
Parse each line (skip comment lines starting with #) into structured records:
- Format: `ASIN|title|price|currency|stock_status|bsr_rank|promo_tag|url`

### Step 2: Scrape Current Prices
For each competitor entry in price_memory.txt:
1. Use `playwright-npx` (preferred) or `web_fetch` (fallback) to scrape the current product page
2. Extract the following fields from the live page:
   - `current_price`: The current listed price (handle sale prices, "was/now" formats)
   - `stock_status`: in_stock | low_stock | out_of_stock (check for "Currently unavailable", "Only X left")
   - `bsr_rank`: Best Sellers Rank from the Product Information section
   - `promo_tag`: Lightning Deal | Coupon | Subscribe & Save | Prime Day | (empty if none)
   - `review_count`: Current total review count (for review velocity tracking)

### Step 3: Compare Against Yesterday
For each product, compare every field against yesterday's snapshot. Flag changes:
- **price_change**: Trigger if price differs by more than $0.01
- **stockout**: Trigger if stock_status changed to "out_of_stock"
- **restock**: Trigger if stock_status changed FROM "out_of_stock" to "in_stock"
- **new_promo**: Trigger if promo_tag changed from empty to non-empty
- **promo_ended**: Trigger if promo_tag changed from non-empty to empty
- **bsr_shift**: Trigger if BSR rank changed by more than 5 positions

### Step 4: Generate Alerts (If Changes Detected)
For each detected change, generate an alert payload:

```json
{
  "alert_type": "price_change | stockout | restock | new_promo | promo_ended | bsr_shift",
  "product": "Product Title",
  "asin": "B0XXXXXXX1",
  "old_value": "previous value",
  "new_value": "current value",
  "change": "percentage or description of change",
  "url": "https://amazon.com/dp/B0XXXXXXX1",
  "detected_at": "ISO8601 timestamp"
}
```

Send each alert via webhook:
- **Feishu**: POST to $FEISHU_WEBHOOK_URL with interactive card format
- **Telegram**: POST to Telegram Bot API with markdown-formatted message

### Step 5: Update price_memory.txt
Overwrite `data/price_memory.txt` with today's scraped data.
Preserve the header comment block. Update the "# Updated:" timestamp to now.

### Step 6: Append to Price History
Create or append to `data/price_history/{YYYY-MM-DD}_prices.json`:

```json
{
  "snapshot_date": "YYYY-MM-DD",
  "snapshot_time": "HH:MM:SS+08:00",
  "products": [
    {
      "asin": "B0XXXXXXX1",
      "price": 39.99,
      "bsr_rank": 3,
      "stock_status": "in_stock",
      "promo_tag": "",
      "review_count": 3215
    }
  ]
}
```

### Step 7: Log Operation
Append a summary entry to `logs/scrape_log.jsonl`:

```jsonl
{"timestamp":"ISO8601","task":"price_monitor","products_checked":N,"changes_detected":N,"alerts_sent":N,"status":"success|partial_failure","errors":[],"execution_time_ms":N}
```

## Error Handling
- If a product page returns 404: Mark product as "delisted" in price_memory.txt, generate alert
- If a product page times out: Retry up to 3 times (5s, 15s, 45s backoff). If all fail, skip and log error
- If webhook delivery fails: Log the alert payload locally to `data/reports/unsent_alerts.jsonl` for manual retry
- If ALL products fail to scrape: Do NOT overwrite price_memory.txt. Log full error and exit

## Silent Termination
If no changes are detected across all products:
- Do NOT send any webhooks
- Still update the "# Updated:" timestamp in price_memory.txt
- Still append to price_history (for trend analysis continuity)
- Log operation with `changes_detected: 0`

# Task: Generate Weekly Trend Digest

## Schedule
Triggered every Sunday at 04:00 AM UTC+8 by cron job `weekly-trend-digest`.

## Execution Steps

1. **Load 7-day price history**
   - Read all daily snapshot files from `data/price_history/` for the past 7 days
   - Expected files: `{YYYY-MM-DD}_prices.json` for each of the last 7 days
   - If any day is missing, note the gap and proceed with available data

2. **Compute per-ASIN 7-day price trajectory**
   For each ASIN tracked across the 7 daily snapshots, calculate:
   - `price_min`: lowest price observed in the 7-day window
   - `price_max`: highest price observed in the 7-day window
   - `price_avg`: average price across all available days (rounded to 2 decimals)
   - `price_direction`: classify as `"rising"` / `"falling"` / `"stable"` / `"volatile"`
     - Rising: price on day 7 is > 5% above day 1
     - Falling: price on day 7 is > 5% below day 1
     - Volatile: price swung > 10% at any point but ended within 5% of start
     - Stable: all other cases

3. **Compute BSR rank movement**
   For each ASIN, compare day 1 vs day 7 BSR rank:
   - `bsr_direction`: `"improved"` (rank number decreased), `"declined"` (rank number increased), `"stable"` (changed by fewer than 3 positions)
   - `bsr_change`: absolute change in rank positions
   - `bsr_day1`: starting rank
   - `bsr_day7`: ending rank

4. **Compute review velocity**
   For each ASIN, compare review_count on day 1 vs day 7:
   - `new_reviews_total`: day 7 review_count minus day 1 review_count
   - `reviews_per_day`: new_reviews_total / days_with_data (rounded to 1 decimal)
   - Flag ASINs with review_velocity > 10/day as `"high_velocity"`

5. **Detect stock status changes**
   Scan all 7 daily snapshots for stock_status transitions:
   - Record any ASIN that changed from `"in_stock"` to `"out_of_stock"` or `"low_stock"`
   - Record any ASIN that changed from `"out_of_stock"` back to `"in_stock"`
   - Include the date each transition occurred

6. **Generate weekly digest JSON**
   Assemble the digest in this format:

```json
{
  "digest_type": "weekly_trend",
  "generated_at": "{ISO8601 timestamp}",
  "period": {
    "start": "{YYYY-MM-DD of 7 days ago}",
    "end": "{YYYY-MM-DD of today}"
  },
  "days_with_data": 7,
  "asins_tracked": 0,
  "price_trends": [
    {
      "asin": "B0XXXXXXX1",
      "title": "Product Title",
      "price_min": 39.99,
      "price_max": 49.99,
      "price_avg": 44.99,
      "price_direction": "falling",
      "price_day1": 49.99,
      "price_day7": 39.99,
      "price_change_pct": -20.0
    }
  ],
  "bsr_movements": [
    {
      "asin": "B0XXXXXXX1",
      "title": "Product Title",
      "bsr_day1": 7,
      "bsr_day7": 3,
      "bsr_change": 4,
      "bsr_direction": "improved"
    }
  ],
  "review_velocity": [
    {
      "asin": "B0XXXXXXX1",
      "title": "Product Title",
      "reviews_day1": 3200,
      "reviews_day7": 3285,
      "new_reviews_total": 85,
      "reviews_per_day": 12.1,
      "velocity_flag": "high_velocity"
    }
  ],
  "stock_events": [
    {
      "asin": "B0XXXXXXX3",
      "title": "Product Title",
      "event": "stockout",
      "from_status": "in_stock",
      "to_status": "out_of_stock",
      "detected_date": "2026-03-03"
    }
  ],
  "highlights": {
    "biggest_price_drop": {
      "asin": "B0XXXXXXX1",
      "title": "Product Title",
      "change_pct": -20.0
    },
    "biggest_price_increase": null,
    "fastest_review_growth": {
      "asin": "B0XXXXXXX1",
      "reviews_per_day": 12.1
    },
    "stockout_count": 1,
    "asins_with_promos": ["B0XXXXXXX2"]
  }
}
```

7. **Send digest to Lead**
   - Use `sessions_send` to deliver the weekly digest JSON to the Lead agent
   - Include a brief text summary before the JSON:
     ```
     Weekly Trend Digest ({start_date} to {end_date}):
     - {N} ASINs tracked
     - {N} price drops detected (biggest: {ASIN} at {pct}%)
     - {N} BSR improvements
     - {N} stockout events
     - Fastest review growth: {ASIN} at {N}/day
     ```

8. **Save digest locally**
   - Save the full JSON to `data/reports/weekly_digest_{YYYY-MM-DD}.json`
   - Append a summary line to `data/logs/scrape_log.jsonl`:
     ```json
     {"timestamp":"{ISO8601}","tool":"weekly_digest","query":"7-day trend aggregation","results":{asin_count},"status":"success","request_id":"cron_weekly_{date}"}
     ```

## Error Handling

- If fewer than 4 days of price history are available, mark the digest as `"partial"` and include a `"data_gaps"` field listing missing dates
- If price_history directory is empty, send an alert to Lead: "Weekly digest skipped: no price history data available for the past 7 days"
- If a specific ASIN appears in some days but not others, compute metrics only for days where data exists and note the gap

## Retention

- Keep weekly digest JSON files indefinitely (they are already compressed summaries)
- These digests serve as the long-term trend archive after daily snapshots are purged at 90 days

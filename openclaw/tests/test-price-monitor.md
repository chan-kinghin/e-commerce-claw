# Test T-003: Daily Price Monitoring Cron Job

> **Purpose**: Validate the daily price monitoring cron job: price scraping, comparison against snapshot, alert generation, and history file creation.
> **Agents involved**: voc-analyst
> **Estimated time**: 3-5 minutes
> **Prerequisites**: Playwright-npx or web_fetch skill installed, DECODO_AUTH_TOKEN set

---

## Test Description

This test simulates the daily 03:00 AM price monitoring cron job by:

1. Pre-seeding `price_memory.txt` with known prices (some intentionally stale)
2. Triggering the price monitor prompt
3. Verifying that the agent detects price changes
4. Validating alert generation and history file creation

---

## Step 1: Pre-Seed Test Data

Before running the test, seed the `price_memory.txt` with known competitor prices. At least one price should be intentionally wrong (different from the current live price) so the monitor detects a change.

**Seed file**: `~/.openclaw/workspace-voc/data/price_memory.txt`

```
# VOC Price Monitor Snapshot
# Last updated: 2026-03-04T03:00:00+08:00
# Format: ASIN|product_title|price|currency|stock_status|bsr_rank|promo_tag|url

B09V3KXJPB|Ninja BN401 Nutri Pro Compact Personal Blender|79.99|USD|in_stock|5||https://amazon.com/dp/B09V3KXJPB
B0CHX3TKG9|Coleman ComfortSmart Camping Cot|54.99|USD|in_stock|3||https://amazon.com/dp/B0CHX3TKG9
B0DCNQNW86|KingCamp Oversized Camping Cot|69.99|USD|in_stock|7|Lightning Deal|https://amazon.com/dp/B0DCNQNW86
```

**Seed command**:
```bash
cat > ~/.openclaw/workspace-voc/data/price_memory.txt << 'SEED_EOF'
# VOC Price Monitor Snapshot
# Last updated: 2026-03-04T03:00:00+08:00
# Format: ASIN|product_title|price|currency|stock_status|bsr_rank|promo_tag|url

B09V3KXJPB|Ninja BN401 Nutri Pro Compact Personal Blender|79.99|USD|in_stock|5||https://amazon.com/dp/B09V3KXJPB
B0CHX3TKG9|Coleman ComfortSmart Camping Cot|54.99|USD|in_stock|3||https://amazon.com/dp/B0CHX3TKG9
B0DCNQNW86|KingCamp Oversized Camping Cot|69.99|USD|in_stock|7|Lightning Deal|https://amazon.com/dp/B0DCNQNW86
SEED_EOF
```

Also ensure the price_history directory exists:
```bash
mkdir -p ~/.openclaw/workspace-voc/data/price_history
```

---

## Step 2: Execute Price Monitor Prompt

Feed this prompt to the **voc-analyst** agent (`~/.openclaw/workspace-voc`):

```
# Task: Execute daily price monitoring sweep (TEST MODE)

You are executing the daily price monitoring cron job. This is a test run.

## Execution Steps:

1. Read `data/price_memory.txt` to load yesterday's price snapshot.
   - Parse each line (skip comment lines starting with #)
   - Extract: ASIN, product_title, price, currency, stock_status, bsr_rank, promo_tag, url

2. For each competitor entry, scrape the current product page to extract today's data:
   - Use `playwright-npx` or `web_fetch` to load the Amazon product page
   - If Amazon scraping fails, use Decodo Skill `amazon` tool with the ASIN
   - Extract: current_price, stock_status, bsr_rank, promotional_tags
   - Timeout per product: 60 seconds

3. Compare each field against yesterday's snapshot. Detect:
   - Price changes (any difference from snapshot price)
   - Stock status changes (in_stock -> low_stock -> out_of_stock)
   - BSR rank changes (shift of 5+ positions)
   - New promotional tags (Lightning Deal, Coupon, etc.)

4. For EACH change detected, generate an alert payload:
   {
     "alert_type": "price_change | stockout | new_promo | bsr_shift",
     "product": "Product Title",
     "asin": "B0XXXXXXXX",
     "field_changed": "price | stock_status | bsr_rank | promo_tag",
     "old_value": "previous value",
     "new_value": "current value",
     "change_description": "human-readable description (e.g. '-20%' or 'now out of stock')",
     "url": "https://amazon.com/dp/B0XXXXXXXX",
     "detected_at": "ISO8601 timestamp"
   }

5. Generate webhook payloads for each alert:

   Feishu format:
   {
     "msg_type": "interactive",
     "card": {
       "header": {
         "title": { "tag": "plain_text", "content": "Price Alert: [alert_type]" },
         "template": "red"
       },
       "elements": [
         {
           "tag": "div",
           "text": {
             "tag": "lark_md",
             "content": "**Product**: [title]\n**ASIN**: [asin]\n**Change**: [old] -> [new] ([change_description])\n**Detected**: [timestamp]\n[View on Amazon]([url])"
           }
         }
       ]
     }
   }

   Telegram format:
   {
     "chat_id": "{TELEGRAM_CHAT_ID}",
     "text": "Price Alert\nProduct: [title]\nChange: [old] -> [new] ([change_description])\n[url]",
     "parse_mode": "Markdown"
   }

   Note: In test mode, DO NOT actually send webhooks. Instead, save the payloads to:
   data/price_history/test_alerts_{date}.json

6. Overwrite `data/price_memory.txt` with today's scraped data (same format as original).

7. Create `data/price_history/{YYYY-MM-DD}_prices.json` with today's full snapshot:
   {
     "snapshot_date": "YYYY-MM-DD",
     "snapshot_time": "HH:MM:SS+08:00",
     "triggered_by": "test_run",
     "products": [
       {
         "asin": "B0XXXXXXXX",
         "title": "Product Title",
         "price": 49.99,
         "currency": "USD",
         "bsr_rank": 3,
         "stock_status": "in_stock",
         "promo_tag": "",
         "review_count": null
       }
     ],
     "alerts_generated": NNN,
     "scrape_success_count": NNN,
     "scrape_failure_count": NNN
   }

8. Log operation summary to `data/logs/scrape_log.jsonl`:
   {"timestamp":"ISO8601","operation":"price_monitor","products_checked":3,"changes_detected":NNN,"alerts_generated":NNN,"scrape_failures":0,"execution_time_ms":NNN,"triggered_by":"test_run"}

## Output:
Return a summary of the test run:
{
  "test_id": "T-003",
  "test_name": "Price Monitor Cron Job",
  "products_checked": 3,
  "scrape_successes": NNN,
  "scrape_failures": NNN,
  "changes_detected": [
    { "asin": "...", "field": "...", "old": "...", "new": "..." }
  ],
  "alerts_generated": NNN,
  "price_memory_updated": true/false,
  "price_history_created": true/false,
  "webhook_payloads_saved": true/false,
  "overall_status": "PASS/FAIL"
}
```

---

## Expected Outcomes

### If prices changed (expected for at least 1 product):
- Alert JSON generated with `old_value`, `new_value`, and `change_description`
- `price_memory.txt` updated with new prices
- `price_history/{date}_prices.json` created with today's snapshot
- Feishu and Telegram webhook payloads saved (not sent in test mode)
- `scrape_log.jsonl` contains the operation entry

### If no prices changed (possible):
- No alerts generated
- `price_memory.txt` still updated (timestamp refresh)
- `price_history/{date}_prices.json` still created (snapshot of current state)
- `alerts_generated: 0` in the summary

### If scraping fails for a product:
- Failed ASIN logged in scrape_log.jsonl with error details
- Other products still processed
- Failed product retains yesterday's data in price_memory.txt
- Summary shows `scrape_failures > 0`

---

## Pass/Fail Criteria

### PASS conditions (ALL must be true):

- [ ] `price_memory.txt` is read and parsed without errors (3 products loaded)
- [ ] At least 2 out of 3 products are successfully scraped
- [ ] `price_memory.txt` is updated after the run (file modification time changes)
- [ ] `price_history/{date}_prices.json` file is created
- [ ] `price_history/{date}_prices.json` contains valid JSON with `products` array
- [ ] `scrape_log.jsonl` has a new entry for this run
- [ ] If any price changed: alert payload is valid JSON with all required fields
- [ ] If any price changed: Feishu webhook payload follows the interactive card format
- [ ] Alert `detected_at` timestamp is within the last 10 minutes

### FAIL conditions (ANY triggers FAIL):

- [ ] `price_memory.txt` cannot be read or parsed (file missing or corrupt format)
- [ ] All 3 products fail to scrape (0 successes)
- [ ] `price_history/{date}_prices.json` is not created
- [ ] Alert payload has missing required fields
- [ ] `price_memory.txt` is not updated after the run
- [ ] Execution time exceeds 5 minutes

---

## Validation Commands (Post-Test)

```bash
# Check price_memory.txt was updated (modification time should be recent)
stat -f "%Sm" ~/.openclaw/workspace-voc/data/price_memory.txt

# Check price_history file was created for today
TODAY=$(date +%Y-%m-%d)
test -f "$HOME/.openclaw/workspace-voc/data/price_history/${TODAY}_prices.json" && echo "PASS: History file created" || echo "FAIL: History file missing"

# Validate price_history JSON structure
python3 -c "
import json
from datetime import date
today = date.today().isoformat()
try:
    with open(f'$HOME/.openclaw/workspace-voc/data/price_history/{today}_prices.json') as f:
        d = json.load(f)
    checks = [
        ('snapshot_date present', 'snapshot_date' in d),
        ('products is array', isinstance(d.get('products'), list)),
        ('products not empty', len(d.get('products', [])) > 0),
        ('each product has asin', all('asin' in p for p in d.get('products', []))),
        ('each product has price', all('price' in p for p in d.get('products', []))),
    ]
    for name, result in checks:
        print(f'  {name}: {\"PASS\" if result else \"FAIL\"}')
except FileNotFoundError:
    print('FAIL: History file not found')
except json.JSONDecodeError:
    print('FAIL: History file is not valid JSON')
"

# Check if alerts were generated
TODAY=$(date +%Y-%m-%d)
ALERT_FILE="$HOME/.openclaw/workspace-voc/data/price_history/test_alerts_${TODAY}.json"
if [ -f "$ALERT_FILE" ]; then
    echo "Alerts generated:"
    python3 -c "import json; d=json.load(open('$ALERT_FILE')); print(f'  Count: {len(d) if isinstance(d, list) else 1}')"
else
    echo "No alert file generated (may be expected if no prices changed)"
fi

# Check scrape_log.jsonl has new entry
tail -1 ~/.openclaw/workspace-voc/data/logs/scrape_log.jsonl 2>/dev/null || echo "FAIL: scrape_log.jsonl missing or empty"

# Verify price_memory.txt format is valid
python3 -c "
with open('$HOME/.openclaw/workspace-voc/data/price_memory.txt') as f:
    lines = [l.strip() for l in f if l.strip() and not l.startswith('#')]
for line in lines:
    parts = line.split('|')
    assert len(parts) == 8, f'Expected 8 fields, got {len(parts)}: {line}'
    assert parts[2].replace('.','').isdigit(), f'Price not numeric: {parts[2]}'
print(f'PASS: {len(lines)} products, all valid format')
"
```

---

## Webhook Payload Validation

### Feishu Card Format Check

```python
# Validate Feishu webhook payload structure
import json
from datetime import date

today = date.today().isoformat()
alert_file = f"~/.openclaw/workspace-voc/data/price_history/test_alerts_{today}.json"

try:
    alerts = json.load(open(alert_file))
    if not isinstance(alerts, list):
        alerts = [alerts]

    for alert in alerts:
        if 'feishu_payload' in alert:
            payload = alert['feishu_payload']
            assert payload['msg_type'] == 'interactive', "msg_type must be 'interactive'"
            assert 'card' in payload, "card field required"
            assert 'header' in payload['card'], "card.header required"
            assert 'elements' in payload['card'], "card.elements required"
            print(f"PASS: Feishu payload for {alert.get('asin', 'unknown')}")

        if 'telegram_payload' in alert:
            payload = alert['telegram_payload']
            assert 'text' in payload, "text field required"
            assert 'chat_id' in payload or 'TELEGRAM_CHAT_ID' in str(payload), "chat_id required"
            print(f"PASS: Telegram payload for {alert.get('asin', 'unknown')}")

except FileNotFoundError:
    print("No alerts file (expected if no price changes detected)")
except Exception as e:
    print(f"FAIL: {e}")
```

---

## Failure Diagnosis

| Failure Mode | Likely Cause | Fix |
|-------------|-------------|-----|
| price_memory.txt not found | Workspace not fully scaffolded | Run seed command from Step 1 |
| All scrapes fail | Amazon blocking requests, DECODO_AUTH_TOKEN expired | Check token validity, try with Decodo Skill instead of direct scraping |
| History file not created | Agent did not reach Step 7, or data/price_history/ dir missing | Create directory: `mkdir -p ~/.openclaw/workspace-voc/data/price_history` |
| Alert format invalid | Agent did not follow the alert schema | Check SOUL.md has price_monitor instructions, verify prompt template |
| Scrape returns stale prices | Cached page served | Add cache-busting headers, or use Decodo for fresh data |
| price_memory.txt corrupted | Agent wrote in wrong format | Compare against expected pipe-delimited format |

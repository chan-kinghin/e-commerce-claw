# Task: Weekly SOP Compliance Audit

## Schedule
Triggered every Friday at 09:00 AM UTC+8 by cron job `reddit-sop-compliance`.

## Context
You are the Reddit Marketing Specialist running the weekly SOP compliance audit.
This audit ensures all Reddit accounts are progressing through the 5-week nurturing SOP
correctly and flags any accounts that violate engagement rules or promotional ratios.

## Execution Steps

### Step 1: Load SOP Progress Data
Read `data/nurturing/sop-progress.json` to get the current state of all accounts.
For each account, extract:
- `account_id`
- `current_week` (W1 through W5)
- `week_started_at` (ISO-8601 timestamp)
- `progression_history`
- `compliance_checks` (previous audit results)

### Step 2: Load Activity Logs
For each account, read its activity log from `data/logs/account_{account_id}_activity.jsonl`.
Filter to entries from the past 7 days. Each entry contains:
- `timestamp`, `action_type` (comment|post|upvote|reply), `subreddit`, `is_promotional` (boolean), `content_hash`

If the activity log file does not exist for an account, flag the account as `"no_activity_data"`.

### Step 3: Check Week-Specific Compliance Rules
Apply the compliance rules for each account based on its `current_week`:

**W1 (Pure Lurking & Upvoting)**:
- PASS: Account has 0 comments and 0 posts
- PASS: Account has upvote-only activity
- FAIL: Any comment or post activity detected
- FAIL: Account joined fewer than 3 subreddits

**W2 (Non-Promotional Comments Only)**:
- PASS: All comments have `is_promotional: false`
- PASS: At least 5 comments made this week
- FAIL: Any comment with `is_promotional: true`
- FAIL: Fewer than 3 comments this week (insufficient engagement)
- FAIL: Same content_hash appears more than once (template reuse)

**W3 (Community Building)**:
- PASS: At least 10 comments/replies made this week
- PASS: At least 2 different subreddits engaged
- PASS: Promotional ratio is 0% (still no promotional content)
- FAIL: Promotional ratio above 0%
- FAIL: Fewer than 5 comments/replies this week
- FAIL: Activity in only 1 subreddit

**W4 (Soft Product Mentions)**:
- PASS: Promotional ratio is between 1% and 20% of total comments
- PASS: No direct product links in any comment
- PASS: At least 10 total comments this week
- FAIL: Promotional ratio above 20%
- FAIL: Direct product link detected in any comment
- FAIL: Fewer than 5 total comments this week

**W5 (Sustained Engagement)**:
- PASS: Promotional ratio stays between 5% and 20%
- PASS: At least 15 total comments this week
- PASS: Activity across 3+ subreddits
- FAIL: Promotional ratio above 20%
- FAIL: Promotional ratio below 5% (underutilizing the account)
- FAIL: Activity in fewer than 2 subreddits
- FAIL: Fewer than 8 total comments this week

### Step 4: Check Universal Rules (All Weeks)
For every account regardless of week:
- FAIL: Any two comments with identical `content_hash` (template reuse across threads)
- FAIL: More than 5 comments in a single hour (bot-like behavior)
- FAIL: Any activity during 02:00-04:00 UTC (known bot-sweep window)
- FAIL: Comments posted less than 30 minutes apart in the same subreddit
- WARNING: Account has been in the same week for more than 10 days without progression

### Step 5: Check Promotional-to-Organic Ratio
For each account, compute:
- `total_comments`: count of all comment/reply actions in the past 7 days
- `promotional_comments`: count where `is_promotional: true`
- `organic_comments`: `total_comments - promotional_comments`
- `promotional_ratio`: `promotional_comments / total_comments` (as percentage, 1 decimal)

Compare against the allowed ratio for the account's current week (see Step 3).

### Step 6: Generate Compliance Report
Assemble the audit into a structured JSON report:

```json
{
  "report_type": "sop_compliance_audit",
  "generated_at": "{ISO8601 timestamp}",
  "audit_period": {
    "start": "{YYYY-MM-DD (7 days ago)}",
    "end": "{YYYY-MM-DD (today)}"
  },
  "accounts_audited": 0,
  "accounts_passing": 0,
  "accounts_failing": 0,
  "accounts_warned": 0,
  "account_results": [
    {
      "account_id": "account_name",
      "current_week": "W3",
      "days_in_current_week": 5,
      "total_comments": 12,
      "promotional_comments": 0,
      "organic_comments": 12,
      "promotional_ratio_pct": 0.0,
      "subreddits_active": ["r/Camping", "r/BuyItForLife"],
      "status": "pass|fail|warning",
      "violations": [
        {
          "rule": "rule description",
          "severity": "fail|warning",
          "detail": "specific violation detail"
        }
      ],
      "recommendation": "Action to take if failing"
    }
  ],
  "summary": {
    "accounts_ready_for_promotion": [],
    "accounts_at_risk": [],
    "accounts_stalled": [],
    "overall_health": "healthy|at_risk|critical"
  }
}
```

### Step 7: Determine Overall Health
- **healthy**: All accounts passing, no warnings
- **at_risk**: 1+ accounts with warnings or 1 account failing
- **critical**: 2+ accounts failing or any account with bot-detection risk violations

### Step 8: Send Report to Lead
Use `sessions_send` to deliver the compliance report to the Lead agent.
Include a brief text summary before the JSON:

```
Reddit SOP Compliance Audit ({audit_date}):
- {N} accounts audited
- {N} passing, {N} failing, {N} warnings
- Overall health: {healthy|at_risk|critical}
- Ready for promotion: {account_list or "none"}
- At risk: {account_list or "none"}
```

### Step 9: Update SOP Progress
For accounts that pass all compliance checks and have completed their minimum week duration:
- W1 (7+ days) -> promote to W2
- W2 (7+ days) -> promote to W3
- W3 (7+ days) -> promote to W4
- W4 (7+ days) -> promote to W5

Update `data/nurturing/sop-progress.json`:
- Set `current_week` to the new week
- Append to `progression_history` with promotion timestamp and criteria met
- Append this audit to `compliance_checks`

### Step 10: Save Report
- Save the full JSON to `data/nurturing/weekly-reports/sop_compliance_{YYYY-MM-DD}.json`
- Append a summary line to `data/logs/reddit_audit_log.jsonl`:

```json
{"timestamp":"{ISO8601}","task":"sop_compliance","accounts_audited":0,"passing":0,"failing":0,"warnings":0,"promotions":0,"status":"success"}
```

## Error Handling
- If `sop-progress.json` is empty or has no accounts: Send alert to Lead: "SOP compliance audit skipped: no accounts registered. Add accounts to sop-progress.json to begin tracking."
- If an account's activity log is missing: Mark account as `"no_activity_data"` with a warning, do not fail the account
- If the activity log is corrupted (invalid JSON lines): Skip corrupted lines, note count of skipped entries in the report
- If sop-progress.json cannot be written (permissions): Save the report but skip the promotion step, alert Lead about the write failure

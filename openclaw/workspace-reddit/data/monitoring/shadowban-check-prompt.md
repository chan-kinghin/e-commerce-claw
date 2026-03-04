# Shadowban Detection - Weekly Check Prompt

## Purpose
Run this check weekly for every active account to detect shadowbans early. A shadowban means the account's posts and comments are invisible to other users while the account owner sees no change.

## Detection Steps

### Method 1: Profile Page Check (Primary)
1. Open an incognito / logged-out browser session
2. Navigate to `https://www.reddit.com/user/{USERNAME}`
3. If the page returns 404 or "page not found" -> POSSIBLE SHADOWBAN
4. If the profile loads normally with recent activity visible -> CLEAN

### Method 2: JSON API Check (Confirmation)
1. In a logged-out session, request `https://www.reddit.com/user/{USERNAME}/about.json`
2. If 404 response -> CONFIRMS SHADOWBAN
3. If valid JSON with user data -> CLEAN

### Method 3: Comment Visibility Check (Secondary)
1. Use reddit-readonly skill to fetch the subreddit's recent comments
2. Search for the account's recently posted comments
3. If comments do not appear in subreddit listings but exist on the profile -> POSSIBLE SHADOWBAN
4. If comments appear normally -> CLEAN

## Decision Logic

```
IF Method 1 = 404 AND Method 2 = 404:
    -> SHADOWBAN CONFIRMED
    -> Set account status to "shadowbanned"
    -> Halt all activity immediately
    -> Log alert to alerts.jsonl
    -> Notify Lead agent

IF Method 1 = 404 AND Method 2 = OK:
    -> FALSE ALARM (Reddit may have been temporarily down)
    -> Log as "inconclusive" and recheck in 24 hours

IF Method 1 = OK AND Method 3 = comments missing:
    -> PARTIAL SHADOWBAN POSSIBLE
    -> Reduce activity to browse-only for 3 days
    -> Recheck after 3 days

IF all methods = OK:
    -> CLEAN
    -> Log result to shadowban-checks.jsonl
    -> Continue normal operations
```

## Alert Format

Log to `data/monitoring/shadowban-checks.jsonl`:
```json
{
  "account_id": "acc-001",
  "checked_at": "ISO-8601 timestamp",
  "method_1_result": "clean|404|error",
  "method_2_result": "clean|404|error",
  "method_3_result": "clean|missing|error",
  "overall_status": "clean|shadowbanned|inconclusive|partial",
  "action_taken": "none|activity_halted|recheck_scheduled"
}
```

## Schedule
- **Frequency**: Every 7 days for all active accounts
- **Additional checks**: Immediately after any moderator action or comment removal
- **Preferred time**: Vary the check time to avoid patterns

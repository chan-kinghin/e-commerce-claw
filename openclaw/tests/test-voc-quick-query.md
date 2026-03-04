# Test T-004: VOC Quick Query - Reddit-Only for "4K TV"

> **Purpose**: Test the single-platform quick query workflow. Send a Reddit-only research task to voc-analyst and validate fast response, data quality, and correct confidence marking.
> **Agents involved**: voc-analyst
> **Estimated time**: 1-2 minutes
> **Prerequisites**: Decodo Skill or reddit-readonly installed, DECODO_AUTH_TOKEN set (or reddit-readonly as fallback)

---

## Test Description

This test sends a `quick_query` task to the voc-analyst for "4K TV" sentiment on Reddit only. Because only 1 data source is used, the agent must correctly mark confidence as "LOW" per the confidence logic:

```
4/4 sources successful  -> HIGH
3/4 sources successful  -> MEDIUM
2/4 sources successful  -> LOW
1/4 sources successful  -> LOW (with warning)
0/4 sources successful  -> NONE
```

---

## Input JSON (sent via sessions_send from Lead)

```json
{
  "task_type": "quick_query",
  "category": "4K TV",
  "keywords": ["4K TV", "OLED TV", "4K television", "best TV 2026"],
  "target_market": "US",
  "competitor_asins": [],
  "platforms": ["reddit"],
  "subreddits": ["r/4kTV", "r/hometheater", "r/HTBuyingAdvices"],
  "time_range": "3months",
  "priority": "urgent",
  "request_id": "test-quick-voc-004"
}
```

---

## Test Execution Prompt

Feed this prompt to the **voc-analyst** agent (`~/.openclaw/workspace-voc`):

```
# Task: Quick Reddit-Only Market Query for "4K TV"

You have received an urgent quick_query task from Lead. Execute a single-platform (Reddit-only) analysis.

## Input Task:
{
  "task_type": "quick_query",
  "category": "4K TV",
  "keywords": ["4K TV", "OLED TV", "4K television", "best TV 2026"],
  "target_market": "US",
  "platforms": ["reddit"],
  "subreddits": ["r/4kTV", "r/hometheater", "r/HTBuyingAdvices"],
  "time_range": "3months",
  "priority": "urgent",
  "request_id": "test-quick-voc-004"
}

## Execution Steps:

1. Start a timer. The total execution MUST complete within 120 seconds.

2. Query Reddit using the following priority:
   a. Primary: Decodo Skill `reddit_subreddit` for each target subreddit
   b. Fallback: reddit-readonly skill if Decodo fails
   c. Search terms: "4K TV", "OLED TV", "best TV 2026", "TV recommendation"

3. For each subreddit, collect:
   - Top 10-15 posts matching keywords (sorted by relevance, then by hot)
   - For each post: title, score, comment_count, url, created_date
   - Top 3-5 comments from each post (sorted by score)

4. Analyze the collected data:
   - Extract pain points from comments (complaints, frustrations, wishes)
   - Identify frequently mentioned brands and models
   - Note price expectations and budget ranges mentioned
   - Tag sentiment (positive/negative/neutral) per mention

5. Generate a quick report conforming to VOCReport schema:
   - CRITICAL: Set confidence to "LOW" because only 1 platform was queried
   - Include a warning note: "Single-source analysis. Cross-validation not performed."
   - Include at least 3 pain points with representative quotes and source URLs

6. Save outputs:
   - JSON report to: data/reports/4k_tv_quick_{date}.json
   - Markdown summary to: data/reports/4k_tv_quick_{date}.md

7. Return the report via sessions_send to Lead.

## Response Format:

Return the complete VOCReport JSON. Key fields that MUST be populated:

{
  "report_id": "voc_{date}_4k_tv_quick",
  "request_id": "test-quick-voc-004",
  "category": "4K TV",
  "generated_at": "ISO8601",
  "confidence": "LOW",
  "confidence_warning": "Single-source analysis (Reddit only). Cross-validation not performed. Findings should be verified against Amazon reviews and YouTube evaluations before making decisions.",
  "data_sources": {
    "reddit": {
      "posts_analyzed": NNN,
      "subreddits": ["r/4kTV", "r/hometheater", "r/HTBuyingAdvices"],
      "scrape_tool": "decodo/reddit_subreddit or reddit-readonly",
      "scrape_timestamp": "ISO8601",
      "status": "success"
    }
  },
  "market_overview": {
    "price_range": { "min": NNN, "max": NNN, "median": NNN, "currency": "USD" },
    "frequently_mentioned_brands": ["brand1", "brand2", "brand3"],
    "sentiment_distribution": { "positive": 0.XX, "negative": 0.XX, "neutral": 0.XX },
    "market_saturation": "HIGH/MEDIUM/LOW"
  },
  "pain_points": [
    {
      "rank": 1,
      "issue": "...",
      "severity_score": NNN,
      "frequency": "mentioned in X% of negative posts",
      "sources": ["reddit_r/4kTV", "reddit_r/hometheater"],
      "source_count": 1,
      "representative_quotes": [
        {
          "text": "exact quote from Reddit post or comment",
          "source": "r/4kTV",
          "url": "https://reddit.com/r/4kTV/comments/..."
        }
      ],
      "design_opportunity": "..."
    }
  ],
  "recommendation": {
    "verdict": "REQUIRES_MORE_DATA",
    "rationale": "Single-source analysis provides directional insights but is insufficient for a market entry decision. Recommend full_analysis with Amazon, YouTube, and Google Maps data.",
    "suggested_next_steps": ["Run full_analysis with all 4 platforms", "Check Amazon BSR for top 50 4K TVs", "Review YouTube unboxing videos for build quality data"]
  },
  "metadata": {
    "total_api_calls": NNN,
    "estimated_token_cost": NNN,
    "execution_time_seconds": NNN,
    "needs_geo_optimization": false,
    "needs_tiktok_content": false,
    "needs_reddit_seeding": false
  }
}
```

---

## Expected Output Schema

### Required Fields

| Field Path | Type | Expected Value / Constraint |
|-----------|------|---------------------------|
| `report_id` | string | Contains "4k_tv" and today's date |
| `request_id` | string | `"test-quick-voc-004"` (echoed back) |
| `confidence` | string | `"LOW"` (mandatory for single-source) |
| `confidence_warning` | string | Non-empty, mentions single-source limitation |
| `data_sources.reddit.posts_analyzed` | number | `>= 10` |
| `data_sources.reddit.status` | string | `"success"` |
| `pain_points` | array | Length `>= 3` |
| `pain_points[*].representative_quotes` | array | Each pain point has at least 1 quote |
| `pain_points[*].representative_quotes[*].url` | string | Valid Reddit URL |
| `recommendation.verdict` | string | `"REQUIRES_MORE_DATA"` (not a strong recommendation) |
| `metadata.execution_time_seconds` | number | `<= 120` |

---

## Pass/Fail Criteria

### PASS conditions (ALL must be true):

- [ ] Agent responds within 120 seconds of task receipt
- [ ] Response is valid JSON conforming to VOCReport schema
- [ ] `confidence` is exactly `"LOW"`
- [ ] `confidence_warning` is present and non-empty
- [ ] `data_sources.reddit.posts_analyzed` >= 10
- [ ] `data_sources.reddit.status` == `"success"`
- [ ] `pain_points` array has at least 3 entries
- [ ] Each pain point has at least 1 `representative_quote` with a valid Reddit URL
- [ ] `recommendation.verdict` is NOT `"RECOMMENDED_ENTRY"` (insufficient data for strong recommendation)
- [ ] `metadata.execution_time_seconds` <= 120
- [ ] `request_id` in response matches `"test-quick-voc-004"`
- [ ] JSON report saved to `data/reports/4k_tv_quick_{date}.json`
- [ ] Markdown report saved to `data/reports/4k_tv_quick_{date}.md`

### FAIL conditions (ANY triggers FAIL):

- [ ] Agent does not respond within 120 seconds
- [ ] Response is not valid JSON
- [ ] `confidence` is anything other than `"LOW"`
- [ ] `posts_analyzed` < 10 (insufficient data collected)
- [ ] `pain_points` array has fewer than 3 entries
- [ ] Pain points have no representative quotes or no source URLs
- [ ] `recommendation.verdict` is `"RECOMMENDED_ENTRY"` (should not make strong recommendation from single source)
- [ ] Report files not saved to workspace

---

## Validation Commands (Post-Test)

```bash
# Check JSON report exists
TODAY=$(date +%Y-%m-%d | tr -d '-')
ls ~/.openclaw/workspace-voc/data/reports/4k_tv_quick_${TODAY}*.json 2>/dev/null && echo "JSON report: EXISTS" || echo "JSON report: MISSING"

# Check Markdown report exists
ls ~/.openclaw/workspace-voc/data/reports/4k_tv_quick_${TODAY}*.md 2>/dev/null && echo "MD report: EXISTS" || echo "MD report: MISSING"

# Full validation
python3 << 'VALIDATE_EOF'
import json, glob, os

home = os.path.expanduser("~")
pattern = f"{home}/.openclaw/workspace-voc/data/reports/4k_tv_quick_*.json"
files = glob.glob(pattern)

if not files:
    print("FAIL: No quick query report found")
    exit(1)

# Use the most recent file
report_file = sorted(files)[-1]
print(f"Validating: {report_file}")

with open(report_file) as f:
    d = json.load(f)

checks = [
    ("request_id matches",
     d.get("request_id") == "test-quick-voc-004"),

    ("confidence is LOW",
     d.get("confidence") == "LOW"),

    ("confidence_warning present",
     bool(d.get("confidence_warning"))),

    ("reddit posts_analyzed >= 10",
     d.get("data_sources", {}).get("reddit", {}).get("posts_analyzed", 0) >= 10),

    ("reddit status is success",
     d.get("data_sources", {}).get("reddit", {}).get("status") == "success"),

    ("pain_points >= 3",
     len(d.get("pain_points", [])) >= 3),

    ("each pain point has quotes",
     all(len(p.get("representative_quotes", [])) >= 1 for p in d.get("pain_points", [])[:3])),

    ("quotes have URLs",
     all(
         any("reddit.com" in q.get("url", "") for q in p.get("representative_quotes", []))
         for p in d.get("pain_points", [])[:3]
     )),

    ("verdict is not RECOMMENDED_ENTRY",
     d.get("recommendation", {}).get("verdict") != "RECOMMENDED_ENTRY"),

    ("execution_time <= 120s",
     d.get("metadata", {}).get("execution_time_seconds", 999) <= 120),
]

all_pass = True
for name, result in checks:
    status = "PASS" if result else "FAIL"
    if not result:
        all_pass = False
    print(f"  {status}: {name}")

print(f"\nOverall: {'PASS' if all_pass else 'FAIL'}")
VALIDATE_EOF
```

---

## Failure Diagnosis

| Failure Mode | Likely Cause | Fix |
|-------------|-------------|-----|
| No Reddit data returned | Both Decodo and reddit-readonly failed | Check DECODO_AUTH_TOKEN. Test reddit-readonly standalone: `curl https://old.reddit.com/r/4kTV/hot.json?limit=5` |
| Fewer than 10 posts | Subreddits have limited content for these keywords | Broaden keywords: add "TV recommendation", "which TV should I buy". Add more subreddits. |
| Confidence not marked LOW | SOUL.md missing confidence logic | Verify SOUL.md Section "Error Handling" has the confidence level rules |
| Execution exceeds 120s | Slow API responses from Reddit/Decodo | Check network latency. Consider reducing post count to 10 instead of 15 per subreddit. |
| No representative quotes | Agent extracted pain points but did not collect quotes | Check prompt instructs agent to collect actual text from Reddit comments |
| Report files not saved | Workspace data/reports/ directory missing | Create: `mkdir -p ~/.openclaw/workspace-voc/data/reports` |
| Verdict is RECOMMENDED_ENTRY | Agent ignoring single-source limitation | Reinforce in SOUL.md: "quick_query tasks with 1 platform must NEVER return RECOMMENDED_ENTRY" |

---

## Notes

- This test specifically validates the "fast path" for when Lead needs a quick answer, not a full multi-source analysis
- The 120-second constraint is a hard requirement - users expect quick queries to be fast
- The LOW confidence marking is critical for downstream decision-making - Lead should not route this data to GEO or TikTok without a full analysis
- The `metadata.needs_geo_optimization` and `needs_tiktok_content` should both be `false` for quick queries - these flags should only be set for full analyses with HIGH/MEDIUM confidence

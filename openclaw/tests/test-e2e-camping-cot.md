# Test T-002: End-to-End Camping Cot - Full Pipeline

> **Purpose**: Execute the complete camping cot scenario from business plan Section 2.7 - from user trigger through all 5 agents to final aggregated report.
> **Agents involved**: lead, voc-analyst, geo-optimizer, reddit-spec, tiktok-director
> **Estimated time**: 15-20 minutes
> **Prerequisites**: All API keys set, all Skills installed, Feishu configured (or run via CLI)

---

## Scenario Overview

User sends: "分析露营折叠床市场，全渠道铺内容"

The Lead agent decomposes this into a 6-step DAG workflow:

```
Step 1: User trigger (Feishu or CLI)
Step 2: Lead decomposes into 4 sub-tasks
Step 3: VOC + Reddit PARALLEL (market data + high-ranking posts)
Step 4: GEO + TikTok + Reddit PARALLEL (content + video + comments)
Step 5: Lead aggregates all outputs
Step 6: Final report delivered (Feishu card or CLI output)
```

---

## Test Execution Prompt

Feed this prompt to the **Lead agent** (`~/.openclaw/workspace-lead`):

```
You are executing the end-to-end camping cot test scenario. This simulates a real user request.

USER REQUEST: "分析露营折叠床市场，全渠道铺内容"
(Translation: "Analyze the camping folding bed market and create content across all channels")

Execute the following 6-step DAG workflow. Log the start/end timestamp of each step.

## Step 1: Parse User Intent

Parse the request into structured sub-tasks:
- Task A: Market research on camping folding beds/cots (assign to voc-analyst)
- Task B: Find high-ranking Reddit posts about camping cots (assign to reddit-spec)
- Task C: Generate GEO-optimized content (depends on Task A results) (assign to geo-optimizer)
- Task D: Generate TikTok UGC video storyboard (depends on Task A results) (assign to tiktok-director)
- Task E: Draft traffic hijacking comments (depends on Task A + Task B results) (assign to reddit-spec)
- Task F: Aggregate all outputs into final report (depends on C, D, E)

Log the DAG:
{
  "dag": {
    "parallel_wave_1": ["task_a_voc", "task_b_reddit_search"],
    "parallel_wave_2": ["task_c_geo", "task_d_tiktok", "task_e_reddit_comment"],
    "sequential_final": ["task_f_aggregate"]
  },
  "dependencies": {
    "task_c_geo": ["task_a_voc"],
    "task_d_tiktok": ["task_a_voc"],
    "task_e_reddit_comment": ["task_a_voc", "task_b_reddit_search"],
    "task_f_aggregate": ["task_c_geo", "task_d_tiktok", "task_e_reddit_comment"]
  }
}

## Step 2: Dispatch Wave 1 (Parallel)

### Task A: VOC Market Analysis
sessions_send to "voc-analyst":
{
  "task_type": "full_analysis",
  "category": "camping folding bed",
  "keywords": ["camping cot", "portable bed", "folding cot outdoor", "camping bed"],
  "target_market": "US",
  "competitor_asins": [],
  "platforms": ["amazon", "reddit", "youtube", "google_maps"],
  "subreddits": ["r/Camping", "r/BuyItForLife", "r/CampingGear", "r/camping"],
  "time_range": "6months",
  "priority": "normal",
  "request_id": "e2e-test-voc-001"
}

### Task B: Reddit High-Ranking Post Search
sessions_send to "reddit-spec":
{
  "task_type": "find_high_ranking_posts",
  "product_category": "camping folding bed",
  "search_queries": [
    "best camping cot reddit",
    "camping cot recommendation site:reddit.com",
    "folding bed camping review reddit",
    "what camping cot do you use site:reddit.com"
  ],
  "target_subreddits": ["r/Camping", "r/BuyItForLife", "r/CampingGear"],
  "min_post_age_months": 3,
  "min_score_threshold": 7,
  "request_id": "e2e-test-reddit-search-001"
}

Wait for both Task A and Task B to complete before proceeding to Step 3.

## Step 3: Collect Wave 1 Results

### Expected VOC Result (from voc-analyst):
A structured VOCReport JSON containing:
- market_overview (price range, avg rating, BSR data)
- pain_points (ranked list with cross-validation)
- competitor_analysis (top competitor ASINs)
- recommendation (verdict + rationale)

Log received VOC report summary:
- Number of products analyzed
- Number of pain points identified
- Top pain point and severity score
- Confidence level

### Expected Reddit Search Result (from reddit-spec):
{
  "task_id": "e2e-test-reddit-search-001",
  "high_ranking_posts": [
    {
      "url": "https://reddit.com/r/.../comments/...",
      "title": "...",
      "subreddit": "r/...",
      "karma": NNN,
      "comment_count": NNN,
      "age_months": NNN,
      "google_rank_position": NNN,
      "evaluation_score": NNN,
      "eligible_for_hijacking": true/false
    }
  ],
  "total_found": NNN,
  "total_eligible": NNN
}

## Step 4: Dispatch Wave 2 (Parallel - depends on Wave 1)

### Task C: GEO Content Generation
sessions_send to "geo-optimizer":
{
  "task_type": "generate_product_content",
  "source_report": "<voc_report_id from Step 3>",
  "pain_points_summary": [
    {
      "issue": "<top pain point from VOC>",
      "data_point": "<frequency/severity from VOC>",
      "design_solution": "<suggested solution from VOC>"
    }
  ],
  "competitive_positioning": {
    "price_range": "<from VOC market_overview>",
    "key_differentiators": ["<from VOC recommendation>"],
    "authority_citations": ["OutdoorGearLab", "Wirecutter", "SectionHiker"]
  },
  "target_content": ["independent_site_blog", "amazon_listing"],
  "request_id": "e2e-test-geo-001"
}

### Task D: TikTok Video Storyboard
sessions_send to "tiktok-director":
{
  "task_type": "generate_ugc_video",
  "source_report": "<voc_report_id from Step 3>",
  "pain_points_for_script": [
    {
      "pain_point": "<top pain point>",
      "visual_demo": "<suggested visual demonstration>",
      "second_marker": "Show at second 2-4"
    },
    {
      "pain_point": "<second pain point>",
      "visual_demo": "<suggested visual demonstration>",
      "second_marker": "Show at second 6-10"
    }
  ],
  "product_specs": {
    "weight_capacity": "450 lbs",
    "fold_mechanism": "one-fold",
    "weight": "12 lbs",
    "price": "$69.99"
  },
  "video_style": "UGC camping scenario, handheld camera, outdoor lighting",
  "request_id": "e2e-test-tiktok-001"
}

### Task E: Reddit Traffic Hijacking Comments
sessions_send to "reddit-spec":
{
  "task_type": "draft_hijacking_comments",
  "target_posts": "<eligible posts from Step 3 Reddit search>",
  "voc_pain_points": "<pain points from Step 3 VOC report>",
  "product_name": "UltraRest Pro Camping Cot",
  "product_features": ["450lb capacity", "one-fold mechanism", "aircraft-grade aluminum", "integrated carry bag"],
  "tone": "authentic, personal experience, no hard sell",
  "request_id": "e2e-test-reddit-comment-001"
}

Wait for all Wave 2 tasks to complete.

## Step 5: Collect Wave 2 Results and Aggregate

Collect from geo-optimizer:
- Independent site blog article (Markdown)
- Amazon listing (title, bullets, description)

Collect from tiktok-director:
- 25-grid storyboard JSON
- Video generation prompts for Seedance

Collect from reddit-spec:
- Draft comments for each eligible post
- Comment strategy notes

## Step 6: Generate Final Report

Compile all results into a single aggregated report:
{
  "test_id": "T-002",
  "test_name": "End-to-End Camping Cot",
  "executed_at": "ISO8601",
  "total_execution_time_seconds": NNN,
  "dag_execution": {
    "wave_1_start": "ISO8601",
    "wave_1_end": "ISO8601",
    "wave_1_duration_seconds": NNN,
    "wave_2_start": "ISO8601",
    "wave_2_end": "ISO8601",
    "wave_2_duration_seconds": NNN,
    "aggregation_duration_seconds": NNN
  },
  "step_results": {
    "voc_analysis": {
      "status": "success/failure",
      "products_analyzed": NNN,
      "pain_points_found": NNN,
      "top_pain_point": "...",
      "confidence": "HIGH/MEDIUM/LOW",
      "report_saved_to": "path"
    },
    "reddit_search": {
      "status": "success/failure",
      "posts_found": NNN,
      "posts_eligible": NNN,
      "top_post_url": "..."
    },
    "geo_content": {
      "status": "success/failure",
      "blog_generated": true/false,
      "listing_generated": true/false,
      "blog_word_count": NNN,
      "geo_rules_applied": ["no_keyword_stuffing", "quantitative_data", "authority_citations"]
    },
    "tiktok_video": {
      "status": "success/failure",
      "storyboard_generated": true/false,
      "grid_count": 25,
      "video_duration_seconds": 15,
      "first_2_seconds_hook": "..."
    },
    "reddit_comments": {
      "status": "success/failure",
      "comments_drafted": NNN,
      "target_posts": NNN,
      "spam_check_passed": true/false
    }
  },
  "overall_status": "PASS/FAIL"
}

If running with Feishu configured, also send a summary card to the Feishu group.
```

---

## Step-by-Step Timing Expectations

| Step | Action | Expected Duration | Timeout |
|:----:|--------|:-----------------:|:-------:|
| 1 | Parse user intent | ~5 seconds | 30s |
| 2 | Dispatch Wave 1 (VOC + Reddit search) | ~5 seconds (dispatch only) | 10s |
| 3 | Wait for Wave 1 results | ~3 minutes | 5 min |
| 4 | Dispatch Wave 2 (GEO + TikTok + Reddit comments) | ~5 seconds (dispatch only) | 10s |
| 5 | Wait for Wave 2 results | ~10 minutes (TikTok is slowest) | 15 min |
| 6 | Aggregate and generate final report | ~10 seconds | 60s |

**Total**: 15-20 minutes

---

## Pass/Fail Criteria

### Per-Step Pass Criteria

**Step 2 - VOC Analysis (voc-analyst)**:
- [ ] VOC report returned as valid JSON conforming to VOCReport schema
- [ ] `data_sources` contains at least 3 platforms with `status: "success"`
- [ ] `pain_points` array has at least 3 entries
- [ ] Top pain point has `source_count >= 2` (cross-validated)
- [ ] `market_overview.price_range` has valid min/max values
- [ ] `confidence` is "HIGH" or "MEDIUM"
- [ ] Execution time <= 300 seconds

**Step 2 - Reddit Search (reddit-spec)**:
- [ ] Response contains at least 3 candidate posts
- [ ] At least 1 post has `evaluation_score >= 7`
- [ ] All returned posts are from target subreddits or adjacent communities
- [ ] Posts are at least 3 months old

**Step 4 - GEO Content (geo-optimizer)**:
- [ ] Blog article generated in Markdown format
- [ ] Blog contains quantitative data points (numbers, measurements, percentages)
- [ ] Blog contains at least 1 authority citation (OutdoorGearLab, Wirecutter, etc.)
- [ ] Blog does NOT contain keyword stuffing patterns
- [ ] Amazon listing generated with title, bullets, and description
- [ ] Amazon listing bullets reference specific pain points from VOC data

**Step 4 - TikTok Storyboard (tiktok-director)**:
- [ ] 25-grid storyboard JSON generated
- [ ] First 2 seconds contain a "hook" addressing the #1 pain point
- [ ] Storyboard includes product detail shots (e.g., weight capacity demo)
- [ ] Video style is UGC (handheld camera, outdoor setting)
- [ ] Storyboard references VOC pain point data

**Step 4 - Reddit Comments (reddit-spec)**:
- [ ] At least 1 comment draft generated per eligible post
- [ ] Each comment addresses the original post's topic
- [ ] Product mention is natural and embedded in narrative
- [ ] No direct product links in any comment
- [ ] Comments pass spam score check (score < 0.2)
- [ ] Each comment is 100-250 words

**Step 6 - Aggregation (lead)**:
- [ ] Final report contains all sub-task results
- [ ] DAG execution times are logged
- [ ] Overall status correctly reflects sub-task statuses

### Overall PASS Criteria

ALL of the following must be true:
- [ ] All 5 agents participated successfully
- [ ] Total execution time <= 25 minutes
- [ ] VOC report has confidence >= "MEDIUM"
- [ ] At least 1 GEO content piece generated
- [ ] TikTok storyboard generated with 25 grids
- [ ] At least 1 Reddit comment draft generated
- [ ] Final aggregated report is valid JSON

---

## What to Check if It Fails

| Failed Step | Diagnosis |
|------------|-----------|
| VOC returns no data | Check DECODO_AUTH_TOKEN is valid. Check reddit-readonly skill is installed. Try running voc-analyst standalone with a simple query. |
| Reddit search returns no posts | Check Brave Search API key. Try the search queries manually in a browser. Check if target subreddits exist. |
| GEO content is empty | Check if VOC data was correctly forwarded. Verify geo-optimizer SOUL.md has content generation rules. Check model temperature (0.7 recommended for creative content). |
| TikTok storyboard missing | Check tiktok-director received VOC pain points. Verify nano-banana-pro skill is installed. Check SOUL.md has 25-grid template. |
| Reddit comments look spammy | Check reddit-spec SOUL.md tone guidelines. Verify subreddit-profiles exist in workspace. Review the comment against prohibited patterns. |
| Wave 2 never starts | Wave 1 timed out. Check voc-analyst logs. Check reddit-spec logs. Increase Wave 1 timeout. |
| Final report incomplete | Check sessions_send responses for errors. Verify Lead agent collected all results before aggregating. |

---

## Validation Commands (Post-Test)

```bash
# Check VOC report was saved
ls ~/.openclaw/workspace-voc/data/reports/camping_folding_bed_*.json && echo "VOC Report: EXISTS" || echo "VOC Report: MISSING"

# Validate VOC report structure
python3 -c "
import json, glob
files = glob.glob('$HOME/.openclaw/workspace-voc/data/reports/camping_folding_bed_*.json')
if not files:
    print('FAIL: No VOC report found')
else:
    d = json.load(open(files[0]))
    checks = [
        ('pain_points >= 3', len(d.get('pain_points', [])) >= 3),
        ('confidence valid', d.get('confidence') in ['HIGH', 'MEDIUM', 'LOW']),
        ('price_range exists', 'price_range' in d.get('market_overview', {})),
    ]
    for name, result in checks:
        print(f'  {name}: {\"PASS\" if result else \"FAIL\"}')"

# Check GEO content was saved
ls ~/.openclaw/workspace-geo/data/content/camping_folding_bed_* 2>/dev/null && echo "GEO Content: EXISTS" || echo "GEO Content: MISSING"

# Check TikTok storyboard was saved
ls ~/.openclaw/workspace-tiktok/data/storyboards/camping_folding_bed_* 2>/dev/null && echo "TikTok Storyboard: EXISTS" || echo "TikTok Storyboard: MISSING"

# Check Reddit comment drafts were saved
ls ~/.openclaw/workspace-reddit/data/hijacking/comment-drafts/e2e-test-* 2>/dev/null && echo "Reddit Drafts: EXISTS" || echo "Reddit Drafts: MISSING"
```

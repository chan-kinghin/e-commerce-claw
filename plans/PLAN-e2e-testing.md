# End-to-End Testing and Validation Strategy

**System**: Cross-Border E-Commerce AI Platform (OpenClaw Multi-Agent Architecture)
**Agents Under Test**: lead, voc-analyst, geo-optimizer, reddit-spec, tiktok-director
**Date**: 2026-03-05
**Status**: Not Started

---

## 1. System Smoke Tests

Before running any functional tests, verify that every agent is alive, connected, and has access to its required resources.

### 1.1 Agent Health Checks

| Agent | Test | Command / Method | Expected Result | Timeout |
|-------|------|-----------------|-----------------|---------|
| `lead` | Agent responds to ping | `openclaw agent ping lead` | Returns `{ "status": "alive", "agent": "lead" }` | 10s |
| `lead` | Model connectivity | `openclaw agent test-model lead` | doubao-seed-2.0-code returns a completion | 30s |
| `lead` | Workspace read/write | Write then read a test file in `~/.openclaw/workspace-lead/data/test_smoke.txt` | File content matches | 5s |
| `lead` | SOUL.md loaded | Check `~/.openclaw/workspace-lead/SOUL.md` exists and is non-empty | File size > 100 bytes | 5s |
| `lead` | AGENTS.md loaded | Check `~/.openclaw/workspace-lead/AGENTS.md` exists | File size > 100 bytes | 5s |
| `voc-analyst` | Agent responds to ping | `openclaw agent ping voc-analyst` | Returns `{ "status": "alive" }` | 10s |
| `voc-analyst` | Model connectivity | `openclaw agent test-model voc-analyst` | Kimi K2.5 returns a completion | 30s |
| `voc-analyst` | Workspace read/write | Write then read in `~/.openclaw/workspace-voc/data/test_smoke.txt` | File content matches | 5s |
| `voc-analyst` | SOUL.md loaded | Check `~/.openclaw/workspace-voc/SOUL.md` exists and is non-empty | File size > 100 bytes | 5s |
| `geo-optimizer` | Agent responds to ping | `openclaw agent ping geo-optimizer` | Returns `{ "status": "alive" }` | 10s |
| `geo-optimizer` | Model connectivity | `openclaw agent test-model geo-optimizer` | doubao-seed-2.0-code returns a completion | 30s |
| `geo-optimizer` | Workspace read/write | Write then read in `~/.openclaw/workspace-geo/data/test_smoke.txt` | File content matches | 5s |
| `geo-optimizer` | GEO rules file loaded | Check `~/.openclaw/workspace-geo/rules/geo-rules.md` exists | File size > 500 bytes | 5s |
| `reddit-spec` | Agent responds to ping | `openclaw agent ping reddit-spec` | Returns `{ "status": "alive" }` | 10s |
| `reddit-spec` | Model connectivity | `openclaw agent test-model reddit-spec` | Kimi K2.5 returns a completion | 30s |
| `reddit-spec` | Workspace read/write | Write then read in `~/.openclaw/workspace-reddit/data/test_smoke.txt` | File content matches | 5s |
| `reddit-spec` | Account registry exists | Check `~/.openclaw/workspace-reddit/data/accounts/account-registry.json` | Valid JSON, `accounts` array present | 5s |
| `tiktok-director` | Agent responds to ping | `openclaw agent ping tiktok-director` | Returns `{ "status": "alive" }` | 10s |
| `tiktok-director` | Model connectivity | `openclaw agent test-model tiktok-director` | doubao-seed-2.0-code returns a completion | 30s |
| `tiktok-director` | Workspace read/write | Write then read in `~/.openclaw/workspace-tiktok/data/test_smoke.txt` | File content matches | 5s |
| `tiktok-director` | Storyboard template exists | Check `~/.openclaw/workspace-tiktok/templates/storyboard-25grid.json` | Valid JSON with `grids` array | 5s |

### 1.2 Skills Verification

| Agent | Skill | Verification Command | Expected Result | Timeout |
|-------|-------|---------------------|-----------------|---------|
| `voc-analyst` | Decodo Skill | `openclaw skill test decodo --workspace workspace-voc` | Skill responds with capability list | 15s |
| `voc-analyst` | reddit-readonly | `openclaw skill test reddit-readonly --workspace workspace-voc` | Skill fetches r/test successfully | 15s |
| `voc-analyst` | Brave Search | `openclaw skill test brave-search --workspace workspace-voc` | Search returns results for test query | 15s |
| `voc-analyst` | Apify | `openclaw skill test apify --workspace workspace-voc` | Apify actor list returned | 15s |
| `geo-optimizer` | Tavily | `openclaw skill test tavily --workspace workspace-geo` | Search returns results | 15s |
| `geo-optimizer` | Brave Search | `openclaw skill test brave-search --workspace workspace-geo` | Search returns results | 15s |
| `geo-optimizer` | Firecrawl | `openclaw skill test firecrawl --workspace workspace-geo` | Crawl of test URL succeeds | 15s |
| `reddit-spec` | reddit-readonly | `openclaw skill test reddit-readonly --workspace workspace-reddit` | Subreddit data returned | 15s |
| `reddit-spec` | Brave Search | `openclaw skill test brave-search --workspace workspace-reddit` | Search returns results | 15s |
| `tiktok-director` | nano-banana-pro | `openclaw skill test nano-banana-pro` | Image generation capability confirmed | 15s |
| `tiktok-director` | seedance-video | `openclaw skill test seedance-video` | Video generation capability confirmed | 15s |
| `tiktok-director` | manga-style-video | `openclaw skill test manga-style-video --workspace workspace-tiktok` | Style list returned (8 styles) | 15s |
| `tiktok-director` | manga-drama | `openclaw skill test manga-drama --workspace workspace-tiktok` | Skill responds | 15s |
| `tiktok-director` | volcengine-video-understanding | `openclaw skill test volcengine-video-understanding --workspace workspace-tiktok` | QA analysis capability confirmed | 15s |

### 1.3 Environment Variable Verification

| Variable | Required By | Check Method | Expected |
|----------|------------|-------------|----------|
| `DECODO_AUTH_TOKEN` | voc-analyst | `test -n "$DECODO_AUTH_TOKEN"` | Non-empty string starting with `VTAw` |
| `BRAVE_API_KEY` | voc-analyst, geo-optimizer, reddit-spec | `test -n "$BRAVE_API_KEY"` | Non-empty string starting with `BSA` |
| `APIFY_TOKEN` | voc-analyst | `test -n "$APIFY_TOKEN"` | Non-empty string starting with `apify_api_` |
| `TAVILY_API_KEY` | geo-optimizer | `test -n "$TAVILY_API_KEY"` | Non-empty string starting with `tvly-` |
| `FEISHU_WEBHOOK_URL` | lead, voc-analyst | `test -n "$FEISHU_WEBHOOK_URL"` | Valid URL |
| Feishu App Credentials | lead | Check `openclaw.json` channels.feishu.accounts.lead | `appId` and `appSecret` are non-placeholder values |

### 1.4 sessions_send Connectivity

| From | To | Test | Expected | Timeout |
|------|-----|------|----------|---------|
| lead | voc-analyst | `sessions_send` echo test: `{ "type": "ping" }` | voc-analyst receives message and responds `{ "type": "pong" }` | 15s |
| lead | geo-optimizer | `sessions_send` echo test | geo-optimizer responds with pong | 15s |
| lead | reddit-spec | `sessions_send` echo test | reddit-spec responds with pong | 15s |
| lead | tiktok-director | `sessions_send` echo test | tiktok-director responds with pong | 15s |
| voc-analyst | lead | `sessions_send` echo test (reverse) | lead receives and responds | 15s |

---

## 2. Unit-Level Agent Tests

These tests validate each agent's core functionality in isolation. They are drawn directly from each agent's implementation plan.

### 2.1 VOC Analyst Tests (from PLAN-voc-analyst.md)

| # | Test Name | What It Validates | Expected Duration | Dependencies |
|---|-----------|-------------------|:-----------------:|-------------|
| V1 | **Full Cross-Validation Analysis** | End-to-end multi-source category analysis for "portable blender" across 4 platforms (Amazon, Reddit, YouTube, Google Maps). Validates JSON report schema, pain point cross-validation (source_count >= 2), confidence level, and markdown report generation. | 5 min | Decodo, reddit-readonly, Apify, Brave Search |
| V2 | **Single-Platform Quick Query** | Reddit-only quick sentiment check for "4K TV". Validates response within 120s, at least 10 posts analyzed, confidence marked LOW (single source). | 2 min | reddit-readonly or Decodo |
| V3 | **Price Monitoring Detection** | Seeds price_memory.txt with known prices, runs price monitor, detects price changes and generates alerts. Validates price_memory.txt update and price_history file creation. | 3 min | Playwright-npx or web_fetch |
| V4 | **Graceful Degradation Under Platform Failure** | Full analysis with invalid Apify token. Validates report still generated with 3/4 sources, google_maps status is "error", confidence downgraded to MEDIUM. | 5 min | Decodo, reddit-readonly (Apify intentionally broken) |
| V5 | **Competitor Tracking Addition** | Adds 2 competitor ASINs, validates profile JSON creation, price_memory.txt entries added. | 2 min | Decodo |
| V6 | **Empty Data Handling** | Query for non-existent category ("quantum entanglement dog collar"). Validates confidence LOW, verdict INSUFFICIENT_DATA, empty pain_points, no crash. | 2 min | All search skills |

### 2.2 GEO Optimizer Tests (from PLAN-geo-optimizer.md)

| # | Test Name | What It Validates | Expected Duration | Dependencies |
|---|-----------|-------------------|:-----------------:|-------------|
| G1 | **Camping Cot Blog Post** | Blog generation from VOC pain points. Validates 1500-2500 words, 6+ citations, 15+ data points, FAQ section, comparison table, GEO score >= 80. | 8 min | Tavily, Brave Search, Exa |
| G2 | **Bluetooth Earbuds Amazon Listing** | Amazon listing optimization. Validates title < 200 chars with numeric spec, 5 bullets with CAPS benefit + data, no keyword stuffing (category keyword max 3x per 500 words), GEO score >= 80. | 5 min | Decodo, Brave Search |
| G3 | **Standing Desk Product Description** | Product description with expert citations. Validates BIFMA/UL authority citations, all specs have units, named competitor comparison, 10+ data points, GEO score >= 80. | 4 min | Search skills |
| G4 | **GEO Rule Violation Detection** | Rules engine catches deliberate violations in pre-written bad content. Validates detection of: C1 (keyword stuffing), C2 (vague qualifier), C4 (generic opener), A1 (no citations), D1 (no FAQ). Score < 40. | 1 min | None (rules engine only) |
| G5 | **Multi-Format Output from Single VOC Report** | Full content suite for portable blender: blog + Amazon listing + product description. Validates all three use same VOC data, each format passes GEO rules, pain point #1 addressed in all outputs, cross-format duplication < 20%. | 12 min | All search skills |
| G6 | **Citation Freshness and Verification** | Detects stale citations (2022-2023) in wireless charger content. Validates warnings on citations older than 18 months, replacement sources suggested. | 3 min | Search skills |

### 2.3 Reddit Specialist Tests (from PLAN-reddit-specialist.md)

| # | Test Name | What It Validates | Expected Duration | Dependencies |
|---|-----------|-------------------|:-----------------:|-------------|
| R1 | **W2 Comment Generation** | Non-promotional comment for camping cot thread (W2 stage). Validates: zero product mentions, addresses OP's problem, actionable advice, spam score < 0.1, 100-200 words. | 1 min | None (comment generation only) |
| R2 | **W4 Soft Recommendation** | Soft product recommendation for skincare discussion (W4 stage). Validates: product mentioned once naturally, 1+ alternative mentioned, honest trade-off included, subreddit jargon used, spam score < 0.2, no direct links. | 1 min | None (comment generation only) |
| R3 | **Traffic Hijacking Post Evaluation** | Score a candidate post for traffic hijacking. Validates: correct score calculation per rubric, 7/10 threshold decision, comment drafted if Go, evaluation logged in JSON format. | 2 min | Brave Search |
| R4 | **Multi-Account Rotation Compliance** | 3 accounts at different SOP stages with assigned subreddits. Validates: correct account used per subreddit, W3 account excluded from promo, no subreddit overlap, frequency limits respected. | 1 min | None (logic validation) |
| R5 | **Shadowban Detection and Response** | Detect shadowban via 2 independent methods, update registry, halt activity, initiate recovery. Validates: two detection methods used, status updated, 14-day cooldown set, alert logged, subreddit assignments redistributed. | 3 min | Playwright-npx, reddit-readonly |
| R6 | **End-to-End Traffic Hijacking** | Complete workflow from Google search to posted comment for "portable blender". Validates: 5+ candidate posts found, 3 evaluated, 1-2 selected (score >= 7), comments address VOC pain points, no direct links, W5 account used, monitoring schedule set. | 5 min | Brave Search, reddit-readonly |

### 2.4 TikTok Director Tests (from PLAN-tiktok-director.md)

| # | Test Name | What It Validates | Expected Duration | Dependencies |
|---|-----------|-------------------|:-----------------:|-------------|
| T1 | **Standard UGC Video -- Camping Cot** | Full 25-grid storyboard + 10-12 key frames + 15s video + QA. Validates: all 25 grids present (3/5/7/6/4 distribution), breathing movement in first 2s, mattress press demo, QA composite >= 7.0, video < 50MB, duration 15s +/- 0.5s. | 15 min | nano-banana-pro, seedance-video, volcengine-video-understanding |
| T2 | **Manga Drama -- Wuxia Tea Product** | 3-scene Chinese ink wash manga drama. Validates: character consistency across scenes, ink wash style (limited palette, brush strokes), per-scene QA >= 6.5, continuous story flow. | 20 min | canghe-image-gen, manga-style-video, manga-drama, seedance-video, volcengine-video-understanding |
| T3 | **A/B Testing Matrix -- Portable Blender** | 4 hook variants from 1 base storyboard. Validates: identical content from second 2 onward, distinct hook visuals/audio, all 4 pass QA >= 6.5, file sizes within 20% of each other. | 25 min | nano-banana-pro, seedance-video, volcengine-video-understanding |
| T4 | **Ghibli Style Video -- Bamboo Toothbrush** | 10-second Ghibli-style video. Validates: watercolor textures and earth tones present, 17-grid storyboard scaled correctly, nature context (not bathroom), volcengine detects positive sentiment, QA >= 7.0. | 12 min | nano-banana-pro, seedance-video, volcengine-video-understanding |
| T5 | **Video QA Failure and Regeneration** | Deliberate minimal-prompt video generation to trigger QA failure. Validates: QA identifies deficiencies, regeneration targets only failed segments, second attempt improves scores, loop completes in <= 3 attempts, cost tracking reflects multi-attempt. | 20 min | All TikTok skills |

---

## 3. Integration Tests (Agent-to-Agent)

These tests validate `sessions_send` communication between specific agent pairs, ensuring data flows correctly through the system.

### 3.1 Lead -> VOC Analyst: Task Dispatch and Result Collection

**Input Message** (Lead sends via sessions_send):
```json
{
  "task_type": "full_analysis",
  "category": "camping folding bed",
  "keywords": ["camping cot", "portable bed", "folding cot outdoor"],
  "target_market": "US",
  "platforms": ["amazon", "reddit", "youtube", "google_maps"],
  "subreddits": ["r/Camping", "r/BuyItForLife", "r/CampingGear"],
  "time_range": "6months",
  "priority": "normal",
  "request_id": "int_test_lead_voc_001"
}
```

**Expected Response** (VOC returns via sessions_send):
- Valid VOCReport JSON with `request_id: "int_test_lead_voc_001"`
- `data_sources` has entries for each requested platform
- `pain_points` array is non-empty
- `metadata.needs_geo_optimization` and `metadata.needs_tiktok_content` flags present
- Report files saved to `~/.openclaw/workspace-voc/data/reports/`

**Validation Criteria**:
- [ ] Lead receives response within 5 minutes
- [ ] Response JSON validates against VOCReport schema
- [ ] `request_id` matches the sent value
- [ ] `confidence` is HIGH or MEDIUM (at least 3 sources succeeded)
- [ ] Lead can parse and extract `pain_points_summary` for downstream routing

**Timeout**: 6 minutes

### 3.2 Lead -> GEO Optimizer: Content Generation Request and Delivery

**Input Message** (Lead sends via sessions_send):
```json
{
  "task": "generate_product_content",
  "source_report": "voc_test_camping_cot",
  "pain_points_summary": [
    { "issue": "Insufficient weight capacity", "data_point": "68% of negative reviews", "design_solution": "450lb capacity" },
    { "issue": "Difficult storage", "data_point": "42% of negative reviews", "design_solution": "One-fold mechanism" }
  ],
  "competitive_positioning": {
    "price_range": "$59.99 - $79.99",
    "key_differentiators": ["450lb capacity", "one-fold design"],
    "authority_citations": ["OutdoorGearLab", "Wirecutter"]
  },
  "target_content": ["independent_site_blog", "amazon_listing"]
}
```

**Expected Response**:
- Status `completed` with `outputs` array containing blog and Amazon listing
- Each output has `geo_score >= 80`
- `quality_summary.all_hard_fail_rules_passed: true`
- Files saved to `~/.openclaw/workspace-geo/data/output/`

**Validation Criteria**:
- [ ] Lead receives response within 10 minutes
- [ ] Blog output contains quantitative data from pain_points_summary (e.g., "68%", "450")
- [ ] Amazon listing title contains numeric spec
- [ ] Both outputs have GEO score >= 80
- [ ] No HARD FAIL rule violations

**Timeout**: 12 minutes

### 3.3 Lead -> Reddit Specialist: Campaign Assignment and Status Reporting

**Input Message** (Lead sends via sessions_send):
```json
{
  "task_type": "reddit_campaign",
  "product": {
    "name": "UltraRest Pro Camping Cot",
    "category": "outdoor/camping",
    "key_features": ["450lb capacity", "2-minute setup"],
    "price_range": "$89-$129"
  },
  "target_subreddits": ["r/Camping", "r/BuyItForLife"],
  "voc_pain_points": [
    "Competitors: cots collapse under heavy users (200+ lbs)",
    "Competitors: setup takes 10+ minutes"
  ],
  "campaign_type": "traffic_hijack"
}
```

**Expected Response**:
- Status `in_progress` with eligible accounts listed
- Plan includes target_posts_found count, posts evaluated, posts selected
- Estimated posting window provided
- No blockers (or specific blocker reasons if accounts not ready)

**Validation Criteria**:
- [ ] Lead receives acknowledgment within 2 minutes
- [ ] Response lists only W4+ accounts as eligible
- [ ] Target posts found > 0
- [ ] Estimated posting window is realistic (3-7 days)
- [ ] Weekly report follows within the posting window period

**Timeout**: 3 minutes (for initial acknowledgment)

### 3.4 Lead -> TikTok Director: Video Generation Request and Asset Delivery

**Input Message** (Lead sends via sessions_send):
```json
{
  "source": "lead",
  "task_type": "video_production",
  "product": {
    "name": "UltraLight Camping Cot X500",
    "category": "outdoor-camping",
    "key_features": ["450lb capacity", "3-second fold"],
    "target_audience": "outdoor enthusiasts, 25-45, US market",
    "price": 49.99
  },
  "video_requirements": {
    "type": "ugc",
    "style": "standard",
    "duration": 15,
    "quantity": 1
  },
  "priority": "high"
}
```

**Expected Response**:
- Status `completed` with deliverables object
- Storyboard JSON with 25 grids
- Images directory with 10-12 PNG files at 1080x1920
- Video file (MP4, 15s, 9:16)
- QA report with composite score >= 7.0
- Cost and timing breakdown

**Validation Criteria**:
- [ ] Lead receives final deliverables within 15 minutes
- [ ] Video file exists and is playable (MP4, < 50MB)
- [ ] QA composite score >= 7.0
- [ ] Storyboard categories match 3/5/7/6/4 distribution
- [ ] Cost breakdown present with all token counts

**Timeout**: 18 minutes

### 3.5 VOC -> GEO (via Lead): Pain Point Data Flowing to Content Creation

**Test Flow**:
1. Lead dispatches category analysis to VOC
2. VOC returns pain point report
3. Lead extracts pain_points_summary and competitive_positioning
4. Lead forwards structured data to GEO
5. GEO produces content using VOC data

**Validation Criteria**:
- [ ] GEO content references specific pain point data from VOC (e.g., "68% of negative reviews")
- [ ] GEO blog comparison table includes competitor data from VOC report
- [ ] GEO content does not fabricate pain points not present in VOC data
- [ ] Data transformation from VOCReport to GEO input preserves accuracy
- [ ] End-to-end time from VOC dispatch to GEO output < 15 minutes

**Timeout**: 18 minutes

### 3.6 VOC -> TikTok (via Lead): Pain Point Data Flowing to Video Creation

**Test Flow**:
1. Lead dispatches category analysis to VOC
2. VOC returns pain point report
3. Lead extracts pain_points_for_script with visual demos and second markers
4. Lead forwards structured data to TikTok Director
5. TikTok produces storyboard and video

**Validation Criteria**:
- [ ] TikTok storyboard pain_point grids (4-8) reference actual VOC issues
- [ ] First pain point maps to "Show at second 2-4" in storyboard
- [ ] Product specs from VOC data appear in CTA text overlays
- [ ] Video QA confirms pain point display category is present
- [ ] End-to-end time from VOC dispatch to video delivery < 20 minutes

**Timeout**: 22 minutes

---

## 4. End-to-End Scenario: Camping Folding Cot (Flagship)

This is the complete system test based on the business plan's reference scenario (Section 2.7). It exercises all 5 agents working together.

### 4.1 Trigger

**User Input** (Feishu group message):
```
@Lead  "All channels, full content push"
```

**Equivalent English**: "Analyze the camping folding bed market and push content to all channels"

### 4.2 Step-by-Step Execution

#### Step 1: User Message Received (T+0s)

| Item | Detail |
|------|--------|
| Channel | Feishu WebSocket |
| Receiver | Lead agent (sole human interface) |
| Action | Lead receives natural language instruction |
| Validation | Lead acknowledges receipt in Feishu group within 5 seconds |

#### Step 2: Lead Decomposes Task (T+5s)

| Item | Detail |
|------|--------|
| Action | Lead parses intent, generates DAG execution plan with 4 sub-tasks |
| Sub-tasks | (1) VOC market analysis, (2) Reddit high-ranking post search, (3) GEO content generation (depends on VOC), (4) TikTok video generation (depends on VOC), (5) Reddit comment drafting (depends on Reddit search + VOC) |
| DAG Structure | Tasks 1+2 run in parallel; Tasks 3+4+5 run after 1+2 complete |
| Validation | Lead posts progress update in Feishu: "Starting analysis, 4 sub-tasks created" |
| Expected Duration | ~5 seconds |

#### Step 3: VOC + Reddit Search in PARALLEL (T+5s to T+3min)

**Sub-task 3A: VOC Market Analysis**

| Item | Detail |
|------|--------|
| Agent | voc-analyst |
| Input | `sessions_send` from Lead: full_analysis for "camping folding bed" across Amazon, Reddit, YouTube, Google Maps |
| Actions | Amazon BSR top 50, Reddit subreddit scraping (r/Camping, r/BuyItForLife), YouTube subtitle extraction (top 3 reviews), Google Maps wholesale data |
| Expected Output | Pain points: weight capacity insufficient (severity 9.2), difficult storage (severity 7.5); price range $30-80; BSR top 50 analysis; competitor weaknesses |
| Duration | ~3 minutes |

**Sub-task 3B: Reddit High-Ranking Post Search**

| Item | Detail |
|------|--------|
| Agent | reddit-spec |
| Input | `sessions_send` from Lead: find high-ranking old posts about camping cots in r/Camping, r/BuyItForLife |
| Actions | Brave Search for "best camping cot reddit", evaluate post quality per scoring rubric (10-point scale), select posts scoring >= 7/10 |
| Expected Output | 3 high-ranking old posts identified with scores, URLs, and thread context |
| Duration | ~2 minutes |

**Checkpoint at T+3min**:
- [ ] VOC report received by Lead with pain points and market data
- [ ] Reddit post list received by Lead with 3+ evaluated posts
- [ ] Both agents completed without errors
- [ ] Lead posts Feishu update: "Market analysis complete. Top pain point: weight capacity."

#### Step 4: GEO + Reddit Comment + TikTok in PARALLEL (T+3min to T+13min)

**Sub-task 4A: GEO Content Generation**

| Item | Detail |
|------|--------|
| Agent | geo-optimizer |
| Input | VOC pain points + competitive positioning data routed by Lead |
| Actions | Research authority sources (OutdoorGearLab, Wirecutter), draft blog with comparison table, apply GEO rules engine, self-evaluate |
| Expected Output | Blog post with quantitative data ("supports up to 450 lbs"), OutdoorGearLab citation, FAQ section with 5+ Q&A pairs, GEO score >= 80 |
| Duration | ~5-8 minutes |

**Sub-task 4B: Reddit Comment Drafting**

| Item | Detail |
|------|--------|
| Agent | reddit-spec |
| Input | 3 target posts from Step 3B + VOC pain points from Step 3A |
| Actions | Craft genuine comments for each target post (100-250 words each), address OP's pain points, naturally embed product mention, run spam score check |
| Expected Output | 2-3 comment drafts ready for posting, each with spam score < 0.2, no direct product links |
| Duration | ~3-5 minutes |

**Sub-task 4C: TikTok Video Generation**

| Item | Detail |
|------|--------|
| Agent | tiktok-director |
| Input | Product brief + VOC pain points routed by Lead |
| Actions | Design 25-grid storyboard, generate key frame images (nano-banana-pro), generate video segments (Seedance 1.5 Pro), assemble final video, run QA (volcengine) |
| Expected Output | 15-second UGC video with breathing camera movement in first 2 seconds, mattress press close-up at second 4, QA composite >= 7.0 |
| Duration | ~10 minutes |

**Checkpoint at T+13min**:
- [ ] GEO blog post received by Lead with GEO score >= 80
- [ ] Reddit comment drafts received by Lead
- [ ] TikTok video + QA report received by Lead
- [ ] All three agents completed without critical errors

#### Step 5: Lead Aggregates All Outputs (T+13min to T+15min)

| Item | Detail |
|------|--------|
| Agent | lead |
| Actions | Collect all outputs, validate completeness, format Feishu summary card |
| Output | Feishu interactive card message containing: market summary, top pain points, blog link, Amazon listing preview, Reddit campaign status, video thumbnail + download link |
| Duration | ~10 seconds |

### 4.3 Total Timeline

| Phase | Duration | Agents Active |
|-------|:--------:|:-------------:|
| Message receipt + decomposition | ~5s | lead |
| Parallel research (VOC + Reddit search) | ~3 min | voc-analyst + reddit-spec |
| Parallel content creation (GEO + Reddit comments + TikTok) | ~10 min | geo-optimizer + reddit-spec + tiktok-director |
| Result aggregation + Feishu report | ~10s | lead |
| **Total** | **~15-20 minutes** | All 5 agents |

### 4.4 Success Criteria

| # | Criterion | Validation Method |
|---|-----------|-------------------|
| 1 | All 5 deliverables present: VOC report, blog post, Amazon listing, Reddit comments, TikTok video | Count distinct deliverable types in Lead's collection |
| 2 | VOC report has HIGH or MEDIUM confidence with >= 3 data sources | Check `confidence` and `data_sources` in VOCReport JSON |
| 3 | GEO blog passes all HARD FAIL rules (Categories A-D) | Run GEO rules engine on blog output |
| 4 | GEO blog GEO score >= 80 | Check `geo_score` in output metadata |
| 5 | Reddit comments have spam score < 0.2 and no product links | Content analysis of each comment draft |
| 6 | TikTok video QA composite >= 7.0 | Check QA report JSON |
| 7 | TikTok video is 15s +/- 0.5s, 1080x1920, MP4 | ffprobe on output video file |
| 8 | TikTok video first 2 seconds contain breathing movement (no static frames) | volcengine first-N-frames analysis |
| 9 | Feishu summary card sent to group | Verify card message received in Feishu group |
| 10 | Total execution time <= 20 minutes | Wall-clock time from Feishu message to summary card |
| 11 | No unhandled errors across any agent | Check error logs for all 5 workspaces |
| 12 | VOC pain point data ("weight capacity", "storage") appears in GEO content and TikTok storyboard | Cross-reference pain_points between VOC output and downstream outputs |

---

## 5. Additional E2E Scenarios

### 5.1 Scenario: Bluetooth Earbuds (VOC + GEO + Reddit, No TikTok)

This scenario tests a partial pipeline where TikTok video generation is not requested.

**Trigger** (Feishu):
```
@Lead  "Research Bluetooth earbuds market, write content, seed Reddit. No video."
```

#### Step-by-Step

| Step | Agent | Action | Expected Output | Duration |
|------|-------|--------|-----------------|:--------:|
| 1 | Lead | Parse intent, identify 3 sub-tasks (no TikTok) | DAG with VOC -> GEO + Reddit | ~5s |
| 2 | voc-analyst | Full analysis: "bluetooth earbuds" across Amazon, Reddit, YouTube | Pain points: battery dies fast (34%), falls out during exercise (22%), poor noise cancellation (18%); price range $20-35 | ~3 min |
| 3a | geo-optimizer | Blog post + Amazon listing using VOC pain points | Blog: "48-hour battery" data point, comparison table of 4+ earbuds, FAQ with 5+ Q&A, GEO score >= 80. Amazon: title with battery hours spec, 5 CAPS bullets | ~8 min |
| 3b | reddit-spec | Search for high-ranking posts in r/headphones, r/BuyItForLife, r/budgetaudiophile; draft comments | 2-3 target posts found, comment drafts addressing battery/fit pain points, no links | ~5 min |
| 4 | Lead | Aggregate: VOC report + blog + listing + Reddit campaign status | Feishu summary card (no video section) | ~10s |

**Success Criteria**:

| # | Criterion |
|---|-----------|
| 1 | TikTok agent is NOT invoked (Lead correctly excludes it) |
| 2 | VOC report covers 3 platforms minimum |
| 3 | GEO blog references battery life data from VOC (e.g., "34% of negative reviews cite battery life") |
| 4 | Amazon listing title contains numeric battery spec (e.g., "48-Hour") |
| 5 | Reddit comments target r/headphones or r/budgetaudiophile (different subs than camping scenario) |
| 6 | Reddit comments mention earbuds naturally within personal experience narrative |
| 7 | Feishu summary card has 3 sections (VOC + GEO + Reddit), no video section |
| 8 | Total time <= 12 minutes |

### 5.2 Scenario: Portable Blender (Full Pipeline, Different Product Category)

This scenario exercises the full 5-agent pipeline with a different product category, different subreddits, and a different manga style for TikTok.

**Trigger** (Feishu):
```
@Lead  "Full pipeline: portable blender market analysis + all channels. TikTok style: Japanese healing."
```

#### Step-by-Step

| Step | Agent | Action | Expected Output | Duration |
|------|-------|--------|-----------------|:--------:|
| 1 | Lead | Parse intent, create 4 sub-tasks, note TikTok style preference (japanese) | DAG: VOC + Reddit search parallel, then GEO + Reddit comment + TikTok parallel | ~5s |
| 2a | voc-analyst | Full analysis: "portable blender" across Amazon, Reddit, YouTube, Google Maps | Pain points: blade not strong enough for ice (38%), battery too low (29%), hard to clean (21%); price $25-45; BSR top 50 | ~3 min |
| 2b | reddit-spec | Search for high-ranking posts in r/BuyItForLife, r/Cooking, r/MealPrepSunday | 3+ candidate posts about portable blenders, evaluated and scored | ~2 min |
| 3a | geo-optimizer | Blog + Amazon listing + product description for portable blender | Blog with ice-blending test data, comparison table, FAQ. Amazon listing with blade count spec. Product description with USB-C charging detail. All GEO score >= 80 | ~10 min |
| 3b | reddit-spec | Draft comments for selected posts using VOC pain points (blade, battery, cleaning) | 2 comments addressing blender-specific pain points, using r/Cooking jargon ("mise en place", "batch prep") | ~4 min |
| 3c | tiktok-director | 25-grid storyboard in `japanese` healing style + 15s video | Soft pastel colors, warm lighting, kitchen/lifestyle setting, product demo of ice blending, QA composite >= 7.0 | ~12 min |
| 4 | Lead | Aggregate all 5 deliverables | Feishu summary card with all sections including video thumbnail | ~10s |

**Success Criteria**:

| # | Criterion |
|---|-----------|
| 1 | VOC report identifies ice-blending as top pain point with frequency data |
| 2 | GEO content contains ice-blending quantitative data (e.g., "crushes 10 ice cubes in 15 seconds") |
| 3 | Reddit comments target different subreddits than camping scenario (r/Cooking, r/MealPrepSunday) |
| 4 | Reddit comments use cooking-community jargon naturally |
| 5 | TikTok video uses `japanese` manga style (soft pastels, warm lighting confirmed by volcengine) |
| 6 | TikTok storyboard pain_point grids show ice-blending demonstration |
| 7 | All 5 deliverables present in Feishu summary |
| 8 | No cross-contamination with camping cot data from other test runs |
| 9 | Total time <= 20 minutes |

---

## 6. Performance Benchmarks

| Stage | Agent | Target Time | Max Acceptable | Notes |
|-------|-------|:-----------:|:--------------:|-------|
| Task decomposition | lead | 5s | 15s | Parse natural language, generate DAG |
| VOC full analysis (4 platforms) | voc-analyst | 3 min | 5 min | Parallel scraping of Amazon, Reddit, YouTube, Google Maps |
| VOC quick query (1 platform) | voc-analyst | 1 min | 2 min | Single-platform sentiment check |
| GEO blog post generation | geo-optimizer | 5 min | 8 min | Research + draft + rules check + revision |
| GEO Amazon listing generation | geo-optimizer | 3 min | 5 min | Competitor analysis + draft + rules check |
| GEO product description | geo-optimizer | 3 min | 4 min | Feature-benefit mapping + draft |
| Reddit post finding (Google search) | reddit-spec | 1 min | 2 min | Brave Search for high-ranking posts |
| Reddit comment drafting (per comment) | reddit-spec | 1 min | 2 min | Read thread + craft genuine comment |
| TikTok storyboard generation | tiktok-director | 45s | 90s | doubao-seed-2.0-code script generation |
| TikTok image generation (per frame) | tiktok-director | 30s | 60s | nano-banana-pro single image |
| TikTok video generation (per segment) | tiktok-director | 90s | 120s | Seedance 1.5 Pro per 5-10s clip |
| TikTok QA analysis | tiktok-director | 45s | 60s | volcengine-video-understanding per video |
| TikTok full pipeline (storyboard to video) | tiktok-director | 10 min | 15 min | End-to-end for one product |
| Result aggregation | lead | 10s | 30s | Collect outputs, format Feishu card |
| **Full pipeline (all 5 agents)** | **All** | **15 min** | **20 min** | **Camping cot reference scenario** |
| Price monitoring cycle (20 ASINs) | voc-analyst | 2 min | 3 min | Daily cron job |

---

## 7. Failure Injection Tests

These tests validate system resilience when individual components fail.

### 7.1 VOC Agent Timeout Mid-Research

| Item | Detail |
|------|--------|
| **Setup** | Trigger a full_analysis task but kill the voc-analyst process after it begins Amazon scraping but before Reddit scraping completes |
| **Expected Behavior** | Lead detects voc-analyst timeout after configured threshold (5 min). Lead reports partial results if any were received before timeout. Lead sends Feishu message: "VOC analysis timed out. Partial data available. Proceeding with available results." |
| **Validation** | Lead does not crash. If partial Amazon data was received, it is included in the report. GEO and TikTok receive whatever data is available (may proceed with reduced quality). Feishu notification includes error context. |
| **Pass Criteria** | Lead gracefully handles timeout, does not hang indefinitely, delivers partial report to user |

### 7.2 Reddit Rate-Limited (429)

| Item | Detail |
|------|--------|
| **Setup** | Configure reddit-readonly to return 429 responses (simulate by setting invalid rate limit headers or exhausting quota) |
| **Expected Behavior** | reddit-spec detects 429, retries with exponential backoff (5s, 15s, 45s). If still failing after 3 retries, falls back to Decodo reddit_subreddit. If Decodo also fails, falls back to Brave Search with `site:reddit.com`. Lead waits for reddit-spec's response or timeout. |
| **Validation** | Retry attempts are logged in `scrape_log.jsonl`. Fallback chain is followed in correct order. If all Reddit sources fail, reddit-spec reports failure to Lead with specifics. Lead proceeds without Reddit data for downstream tasks. |
| **Pass Criteria** | Agent follows retry/fallback strategy, never crashes, reports clear error context |

### 7.3 Seedance API Down

| Item | Detail |
|------|--------|
| **Setup** | Block outbound connections to Seedance API endpoint (or set invalid API credentials) |
| **Expected Behavior** | tiktok-director fails at video generation step. Storyboard and image assets are still generated successfully. Agent reports to Lead: `{ "status": "partial_failure", "completed": ["storyboard", "images"], "failed": ["video_generation"], "error": "Seedance API unreachable" }`. Lead delivers all other results (VOC, GEO, Reddit) to user without video. Feishu card includes note: "Video generation unavailable. Storyboard and key frames delivered instead." |
| **Validation** | Lead delivers 4/5 deliverables to user. Feishu card is properly formatted without video section. Storyboard JSON and images are accessible. No cascading failure to other agents. |
| **Pass Criteria** | System delivers partial results, video failure does not block other agents |

### 7.4 Feishu WebSocket Disconnect

| Item | Detail |
|------|--------|
| **Setup** | Disconnect the Feishu WebSocket connection mid-pipeline (after Lead has dispatched tasks but before final aggregation) |
| **Expected Behavior** | Lead detects WebSocket disconnect. Lead attempts reconnection with exponential backoff. Agent pipeline continues executing (sessions_send is independent of Feishu). Once WebSocket reconnects, Lead delivers the queued Feishu summary card. If reconnection fails after 5 attempts, Lead logs the completed results to workspace for manual retrieval. |
| **Validation** | Agent-to-agent communication (sessions_send) is unaffected by Feishu disconnect. Results are not lost. Queued messages are delivered upon reconnection. If reconnection fails, results are saved to disk. |
| **Pass Criteria** | Feishu disconnect does not affect agent pipeline execution, messages delivered after reconnect |

### 7.5 Bad Data from VOC (Malformed JSON)

| Item | Detail |
|------|--------|
| **Setup** | Inject malformed JSON in VOC's sessions_send response (e.g., truncated JSON, missing required fields, invalid data types) |
| **Expected Behavior** | Lead detects JSON parse error or schema validation failure. Lead does not forward malformed data to GEO or TikTok. Lead requests VOC to retry (one retry attempt). If retry also fails, Lead reports to user: "Market analysis returned invalid data. Please try again." GEO and TikTok are never sent malformed input. |
| **Validation** | Lead performs input validation before routing. GEO/TikTok never receive garbage data. Error is logged with the malformed payload for debugging. Feishu notification is clear and actionable. |
| **Pass Criteria** | Malformed data is caught at Lead, never propagated downstream |

### 7.6 All Agents Timeout

| Item | Detail |
|------|--------|
| **Setup** | Kill all 4 worker agents (voc-analyst, geo-optimizer, reddit-spec, tiktok-director) after Lead dispatches tasks |
| **Expected Behavior** | Lead waits for configured timeout per agent. As each agent times out, Lead records the failure. After all agents have timed out, Lead escalates to human: Feishu message with "All agents unresponsive. No data collected. Manual intervention required." Lead includes diagnostic info: which agents were unreachable, timestamps, last known status. |
| **Validation** | Lead does not hang forever. Timeout is bounded (max 10 minutes for all agents). Feishu escalation includes actionable diagnostic info. System can recover after agents are restarted without manual cleanup. |
| **Pass Criteria** | Lead escalates clearly, does not deadlock, provides diagnostic information |

### 7.7 Model API Quota Exhausted

| Item | Detail |
|------|--------|
| **Setup** | Exhaust doubao-seed-2.0-code or Kimi K2.5 API quota mid-task |
| **Expected Behavior** | Affected agent receives API error (429 or quota exceeded). Agent reports specific error to Lead via sessions_send. Lead adjusts: if execution-layer model (Kimi K2.5) is down, tasks cannot be rerouted (different model type). Lead reports to user which capability is affected. |
| **Validation** | Clear error reporting with model name and quota details. No silent failures. User informed of which features are temporarily unavailable. |
| **Pass Criteria** | Quota exhaustion is reported clearly, does not cause crashes or data corruption |

---

## 8. Success Criteria Matrix

| Test Category | Test Name | Pass Criteria | Fail Criteria | Priority |
|--------------|-----------|---------------|---------------|:--------:|
| **Smoke** | Agent health check (all 5) | All 5 agents return alive within 10s | Any agent unresponsive after 10s | P0 |
| **Smoke** | Skills verification | All required skills respond to test command | Any P0 skill fails to respond | P0 |
| **Smoke** | Environment variables | All required env vars are set and non-empty | Any required env var missing | P0 |
| **Smoke** | sessions_send connectivity | All 5 agent pairs complete echo test | Any pair fails to communicate | P0 |
| **Unit** | VOC full analysis (V1) | JSON report valid, >= 3 pain points, source_count >= 2, confidence HIGH/MEDIUM | Invalid JSON, < 3 pain points, or NONE confidence | P0 |
| **Unit** | VOC graceful degradation (V4) | Report generated with 3/4 sources, error logged | Agent crash or no report generated | P1 |
| **Unit** | VOC empty data handling (V6) | verdict INSUFFICIENT_DATA, no crash | Crash, fabricated data, or hang | P1 |
| **Unit** | GEO blog post (G1) | GEO score >= 80, 6+ citations, FAQ present, table present | GEO score < 60 or HARD FAIL violations | P0 |
| **Unit** | GEO rule violation detection (G4) | All 5 intentional violations detected, score < 40 | Any violation missed | P1 |
| **Unit** | GEO multi-format output (G5) | 3 formats generated, all score >= 80, same VOC data used | Any format missing or score < 60 | P1 |
| **Unit** | Reddit W2 comment (R1) | Zero product mentions, spam score < 0.1, 100-200 words | Product mentioned, or spam score >= 0.3 | P0 |
| **Unit** | Reddit W4 soft recommendation (R2) | Product mentioned once, alternative present, spam < 0.2 | Multiple product mentions, no alternative, or links present | P0 |
| **Unit** | Reddit traffic hijacking (R6) | Posts found, evaluated, comments drafted, no links | No posts found or comments contain direct links | P1 |
| **Unit** | TikTok UGC video (T1) | 25 grids, 15s video, QA >= 7.0, breathing movement present | QA < 6.0, wrong duration, or static opening | P0 |
| **Unit** | TikTok manga drama (T2) | Character consistency, style consistency, per-scene QA >= 6.5 | Character inconsistency or wrong manga style | P1 |
| **Unit** | TikTok QA failure recovery (T5) | Deficiency detected, targeted regeneration, <= 3 attempts | False positive QA, full regeneration instead of targeted, or > 3 attempts | P1 |
| **Integration** | Lead -> VOC dispatch (3.1) | Response within 5 min, valid schema, request_id matches | Timeout, invalid schema, or wrong request_id | P0 |
| **Integration** | Lead -> GEO dispatch (3.2) | Response within 10 min, GEO score >= 80, no HARD FAIL | Timeout or HARD FAIL violations in output | P0 |
| **Integration** | Lead -> Reddit dispatch (3.3) | Acknowledgment within 2 min, eligible accounts listed | Timeout or no eligible accounts | P1 |
| **Integration** | Lead -> TikTok dispatch (3.4) | Video delivered within 15 min, QA >= 7.0 | Timeout or QA < 6.0 | P0 |
| **Integration** | VOC -> GEO data flow (3.5) | GEO content references VOC pain point data accurately | GEO fabricates data not in VOC report | P0 |
| **Integration** | VOC -> TikTok data flow (3.6) | Storyboard pain_point grids reference VOC issues | Storyboard ignores VOC data | P1 |
| **E2E** | Camping cot full pipeline (4) | All 5 deliverables present, total time <= 20 min, Feishu card sent | Any deliverable missing or total time > 25 min | P0 |
| **E2E** | Bluetooth earbuds partial pipeline (5.1) | 3 deliverables (no TikTok), TikTok correctly excluded, total <= 12 min | TikTok invoked or > 15 min | P1 |
| **E2E** | Portable blender full pipeline (5.2) | All 5 deliverables, japanese style confirmed, different subreddits | Wrong style or same subreddits as camping | P1 |
| **Failure** | VOC timeout (7.1) | Lead reports partial results, no hang | Lead hangs or crashes | P0 |
| **Failure** | Reddit rate-limited (7.2) | Retry + fallback chain followed, error reported | Agent crashes on 429 | P1 |
| **Failure** | Seedance API down (7.3) | 4/5 deliverables delivered, video section omitted | All deliverables blocked by video failure | P0 |
| **Failure** | Feishu disconnect (7.4) | Pipeline continues, messages delivered on reconnect | Pipeline halts or data lost | P0 |
| **Failure** | Bad VOC JSON (7.5) | Malformed data caught at Lead, not forwarded | GEO/TikTok receive garbage data | P0 |
| **Failure** | All agents timeout (7.6) | Lead escalates to human with diagnostics, no deadlock | Lead deadlocks or sends empty report | P0 |

---

## 9. Test Execution Runbook

### 9.1 Prerequisites Checklist

Before running any tests, verify all of the following:

- [ ] **All 5 agents running**: `openclaw agent list` shows lead, voc-analyst, geo-optimizer, reddit-spec, tiktok-director all in `running` state
- [ ] **OpenClaw runtime active**: `openclaw status` returns healthy
- [ ] **openclaw.json configured**: All agent entries present with correct workspace paths and model assignments
- [ ] **Skills installed**: Run skills verification table (Section 1.2) -- all P0 skills must pass
- [ ] **API keys set**: All environment variables from Section 1.3 are configured with valid (non-placeholder) values
- [ ] **Feishu apps connected**: At least the Lead Feishu app has valid (non-placeholder) appId and appSecret; WebSocket connection is established
- [ ] **Workspace directories exist**: All 5 workspace directories under `~/.openclaw/` exist with SOUL.md files
- [ ] **Disk space**: At least 5 GB free (TikTok video generation requires temporary storage)
- [ ] **Network connectivity**: Outbound access to Volcengine (Seedance, doubao), Moonshot (Kimi K2.5), Brave Search, Reddit, Amazon APIs
- [ ] **Test isolation**: No production data in workspace `data/` directories (or backed up)

### 9.2 Test Execution Order

Tests must be run in this order because later stages depend on earlier ones passing:

```
Phase 1: Smoke Tests (5 minutes)
  1.1 Agent health checks (all 5 agents)
  1.2 Skills verification (all required skills)
  1.3 Environment variable verification
  1.4 sessions_send connectivity tests
  --> STOP if any P0 smoke test fails. Fix before proceeding.

Phase 2: Unit Tests (60-90 minutes)
  2.1 VOC Analyst tests (V1-V6) -- ~20 min
  2.2 GEO Optimizer tests (G1-G6) -- ~35 min
  2.3 Reddit Specialist tests (R1-R6) -- ~15 min
  2.4 TikTok Director tests (T1-T5) -- ~90 min (most time-intensive)
  --> Run VOC + Reddit in parallel (different agents, no dependency)
  --> Run GEO after VOC V1 passes (GEO needs VOC-format data)
  --> Run TikTok tests independently (longest duration)
  --> STOP if any P0 unit test fails. Fix before proceeding.

Phase 3: Integration Tests (30-40 minutes)
  3.1 Lead -> VOC dispatch test
  3.2 Lead -> GEO dispatch test
  3.3 Lead -> Reddit dispatch test
  3.4 Lead -> TikTok dispatch test
  3.5 VOC -> GEO data flow test (requires 3.1 + 3.2 passing)
  3.6 VOC -> TikTok data flow test (requires 3.1 + 3.4 passing)
  --> Run 3.1-3.4 sequentially (all go through Lead)
  --> Run 3.5 and 3.6 after their dependencies pass
  --> STOP if any P0 integration test fails. Fix before proceeding.

Phase 4: E2E Scenarios (40-60 minutes)
  4.1 Camping cot full pipeline (flagship scenario) -- ~20 min
  4.2 Bluetooth earbuds partial pipeline -- ~12 min
  4.3 Portable blender full pipeline -- ~20 min
  --> Run sequentially to avoid resource contention

Phase 5: Failure Injection Tests (30-40 minutes)
  5.1 VOC timeout test
  5.2 Reddit rate-limited test
  5.3 Seedance API down test
  5.4 Feishu disconnect test
  5.5 Bad VOC JSON test
  5.6 All agents timeout test
  --> Run sequentially; each test modifies system state
  --> Restore system to normal state after each test
```

**Total estimated duration**: 3-4 hours for full suite

### 9.3 How to Run Each Test Category

#### Smoke Tests
```bash
# Run all smoke tests
openclaw test smoke --config ~/.openclaw/openclaw.json --verbose

# Or run individually
openclaw agent ping lead
openclaw agent ping voc-analyst
openclaw agent ping geo-optimizer
openclaw agent ping reddit-spec
openclaw agent ping tiktok-director

# Skills verification
for skill in decodo reddit-readonly brave-search apify tavily firecrawl \
            nano-banana-pro seedance-video manga-style-video manga-drama \
            volcengine-video-understanding; do
  openclaw skill test $skill && echo "$skill: PASS" || echo "$skill: FAIL"
done

# Environment variable check
for var in DECODO_AUTH_TOKEN BRAVE_API_KEY APIFY_TOKEN TAVILY_API_KEY \
           FEISHU_WEBHOOK_URL; do
  test -n "${!var}" && echo "$var: SET" || echo "$var: MISSING"
done
```

#### Unit Tests
```bash
# VOC tests -- send test payloads via sessions_send
openclaw test unit --agent voc-analyst --test-suite plans/test-payloads/voc-tests.json

# GEO tests
openclaw test unit --agent geo-optimizer --test-suite plans/test-payloads/geo-tests.json

# Reddit tests
openclaw test unit --agent reddit-spec --test-suite plans/test-payloads/reddit-tests.json

# TikTok tests
openclaw test unit --agent tiktok-director --test-suite plans/test-payloads/tiktok-tests.json
```

#### Integration Tests
```bash
# Run integration test suite (sends messages via Lead, validates round-trips)
openclaw test integration --config ~/.openclaw/openclaw.json \
  --test-suite plans/test-payloads/integration-tests.json \
  --timeout 1200  # 20 minute timeout
```

#### E2E Tests
```bash
# Camping cot scenario
openclaw test e2e --scenario "camping-cot" \
  --trigger "Feishu message" \
  --message "Analyze camping folding bed market, full channel push" \
  --timeout 1200

# Bluetooth earbuds scenario
openclaw test e2e --scenario "bluetooth-earbuds" \
  --trigger "Feishu message" \
  --message "Research bluetooth earbuds, write content, seed Reddit, no video" \
  --timeout 900

# Portable blender scenario
openclaw test e2e --scenario "portable-blender" \
  --trigger "Feishu message" \
  --message "Full pipeline: portable blender, all channels, TikTok style japanese" \
  --timeout 1200
```

#### Failure Injection Tests
```bash
# Each failure test requires setup, execution, and teardown
# Run with the failure injection framework
openclaw test failure --test voc-timeout --setup "kill voc-analyst after 30s"
openclaw test failure --test reddit-429 --setup "mock reddit-readonly to return 429"
openclaw test failure --test seedance-down --setup "block seedance API endpoint"
openclaw test failure --test feishu-disconnect --setup "disconnect WebSocket after dispatch"
openclaw test failure --test bad-voc-json --setup "inject malformed JSON in voc-analyst response"
openclaw test failure --test all-timeout --setup "kill all worker agents after dispatch"
```

### 9.4 How to Collect and Review Results

**Log Locations**:
```
~/.openclaw/workspace-lead/logs/          # Lead agent logs
~/.openclaw/workspace-voc/logs/           # VOC agent logs + scrape_log.jsonl
~/.openclaw/workspace-geo/data/quality-logs/  # GEO quality score history
~/.openclaw/workspace-reddit/logs/        # Reddit agent logs
~/.openclaw/workspace-reddit/data/monitoring/  # Shadowban checks, comment performance
~/.openclaw/workspace-tiktok/data/performance-log.json  # TikTok QA scores, render times
```

**Result Collection Script**:
```bash
#!/bin/bash
# Collect all test results into a single directory
RESULTS_DIR="test-results/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"

# Copy agent logs
for ws in workspace-lead workspace-voc workspace-geo workspace-reddit workspace-tiktok; do
  mkdir -p "$RESULTS_DIR/$ws"
  cp -r ~/.openclaw/$ws/logs/* "$RESULTS_DIR/$ws/" 2>/dev/null
done

# Copy GEO quality logs
cp ~/.openclaw/workspace-geo/data/quality-logs/score-history.jsonl "$RESULTS_DIR/geo-scores.jsonl" 2>/dev/null

# Copy TikTok performance log
cp ~/.openclaw/workspace-tiktok/data/performance-log.json "$RESULTS_DIR/tiktok-performance.json" 2>/dev/null

# Copy VOC scrape log
cp ~/.openclaw/workspace-voc/data/logs/scrape_log.jsonl "$RESULTS_DIR/voc-scrape-log.jsonl" 2>/dev/null

# Generate summary
echo "Test run completed at $(date)" > "$RESULTS_DIR/SUMMARY.md"
echo "Results directory: $RESULTS_DIR"
```

**Review Checklist**:
1. Check `SUMMARY.md` for overall pass/fail counts
2. Review any FAIL results -- examine the specific agent logs for error details
3. For GEO tests: check `geo-scores.jsonl` for score distribution
4. For TikTok tests: check `tiktok-performance.json` for QA scores and render times
5. For VOC tests: check `voc-scrape-log.jsonl` for scrape success rates
6. Cross-reference timestamps to verify timing benchmarks
7. Check error logs for any unhandled exceptions

### 9.5 How to Handle Failures During Test Run

| Failure Type | Action |
|-------------|--------|
| P0 smoke test fails | STOP all testing. Fix the root cause (agent down, skill missing, env var unset). Re-run smoke suite. |
| P0 unit test fails | STOP testing for that agent. Debug using agent logs. Fix and re-run that specific test. Continue with other agents. |
| P1 unit test fails | Log the failure. Continue with remaining tests. Address after all P0 tests pass. |
| Integration test fails | Check both sender and receiver agent logs. Verify sessions_send is working (re-run connectivity smoke test). Check for schema mismatches in message payloads. |
| E2E test fails | Identify which step failed from Lead's aggregation log. Run the failing step's integration test in isolation. Check for timing issues (increase timeout if close to threshold). |
| Failure injection test fails | Verify the failure was properly injected (check that the simulated failure actually occurred). Review the agent's error handling code path. |
| Test infrastructure issue | If OpenClaw runtime itself is unstable, restart runtime and re-run from smoke tests. |

---

## 10. Monitoring and Observability

### 10.1 Agent Health Dashboard (Concept)

Track the following metrics per agent in a centralized dashboard:

| Metric | lead | voc-analyst | geo-optimizer | reddit-spec | tiktok-director |
|--------|:----:|:-----------:|:-------------:|:-----------:|:---------------:|
| **Status** | alive/dead | alive/dead | alive/dead | alive/dead | alive/dead |
| **Last Heartbeat** | timestamp | timestamp | timestamp | timestamp | timestamp |
| **Active Tasks** | count | count | count | count | count |
| **Tasks Completed (24h)** | count | count | count | count | count |
| **Error Rate (24h)** | % | % | % | % | % |
| **Avg Response Time** | seconds | seconds | seconds | seconds | seconds |
| **Model API Latency** | ms | ms | ms | ms | ms |
| **Token Usage (24h)** | count | count | count | count | count |
| **Estimated Cost (24h)** | RMB | RMB | RMB | RMB | RMB |

**Implementation**: Use a lightweight monitoring script that polls each agent's health endpoint every 60 seconds and writes metrics to a JSON file. Visualize with a simple HTML dashboard or terminal-based tool.

### 10.2 Log Aggregation Strategy

Each agent writes logs to its own workspace. For centralized viewing:

```
Log Sources:
  ~/.openclaw/workspace-lead/logs/agent-activity.log
  ~/.openclaw/workspace-voc/logs/scrape_log.jsonl
  ~/.openclaw/workspace-voc/data/logs/scrape_log.jsonl
  ~/.openclaw/workspace-geo/data/quality-logs/score-history.jsonl
  ~/.openclaw/workspace-reddit/logs/agent-activity.log
  ~/.openclaw/workspace-reddit/data/monitoring/alerts.jsonl
  ~/.openclaw/workspace-tiktok/data/performance-log.json

Aggregation Approach:
  1. Each agent logs in JSONL format (one JSON object per line)
  2. A cron job (every 5 minutes) tails new entries from all log files
  3. Entries are tagged with agent_id and written to a central log:
     ~/.openclaw/logs/aggregated.jsonl
  4. Central log can be queried with jq for debugging:
     cat ~/.openclaw/logs/aggregated.jsonl | jq 'select(.agent=="voc-analyst" and .level=="error")'
```

**Log Format Standard** (all agents should follow):
```json
{
  "timestamp": "2026-03-05T14:30:00+08:00",
  "agent": "voc-analyst",
  "level": "info|warn|error",
  "event": "scrape_complete|task_received|task_completed|error_occurred",
  "message": "Human-readable description",
  "metadata": {
    "request_id": "req_20260305_001",
    "duration_ms": 4200,
    "tool": "decodo/amazon_search"
  }
}
```

### 10.3 Alert Triggers

| Alert | Condition | Severity | Notification Channel | Action |
|-------|-----------|:--------:|:--------------------:|--------|
| Agent down | Health check fails 3 consecutive times | CRITICAL | Feishu + Telegram | Restart agent, investigate root cause |
| Task timeout | Any task exceeds 2x its max acceptable time | HIGH | Feishu | Check agent logs, possible API issue |
| Error rate spike | Agent error rate > 20% in rolling 1-hour window | HIGH | Feishu | Review error logs, check API status |
| Model API error | Model returns 5xx or quota exceeded | HIGH | Feishu + Telegram | Check API dashboard, switch to backup model if available |
| Scrape failure rate | VOC scrape success rate < 70% in 24h | MEDIUM | Feishu | Check platform accessibility, update scrape configs |
| GEO quality drop | Average GEO score < 75 over last 10 outputs | MEDIUM | Feishu | Review rules engine, check citation source availability |
| Reddit account alert | Shadowban detected or moderator action | HIGH | Feishu | Halt account activity, follow recovery protocol |
| TikTok QA failure rate | > 40% of videos fail QA on first attempt | MEDIUM | Feishu | Review storyboard templates, check Seedance output quality |
| Disk space low | < 2 GB free on Mac mini | HIGH | Feishu + Telegram | Clean old video files, archive reports |
| Cost threshold | Daily API cost exceeds budget by 50% | MEDIUM | Feishu | Review token usage, identify expensive operations |

### 10.4 Token/Cost Tracking per Agent per Task

**Tracking Schema** (appended to each task's metadata):
```json
{
  "cost_tracking": {
    "agent": "tiktok-director",
    "task_id": "vid-20260305-camping-cot",
    "model_costs": [
      { "model": "doubao-seed-2.0-code", "tokens_in": 2500, "tokens_out": 1500, "cost_rmb": 0.12 },
      { "model": "nano-banana-pro", "images": 12, "cost_rmb": 0.60 },
      { "model": "seedance-1.5-pro", "segments": 5, "total_seconds": 15, "cost_rmb": 2.50 },
      { "model": "volcengine-vlu", "analyses": 1, "cost_rmb": 0.18 }
    ],
    "skill_costs": [
      { "skill": "decodo", "calls": 3, "cost_usd": 0.15 },
      { "skill": "brave-search", "calls": 5, "cost_usd": 0.05 },
      { "skill": "apify", "calls": 1, "cost_usd": 0.10 }
    ],
    "total_cost_rmb": 3.40,
    "total_cost_usd": 0.30
  }
}
```

**Daily Cost Aggregation** (cron job at 23:59):
```
Report Format:
  Date: 2026-03-05
  Total Tasks: 12
  Total Cost: 45.60 RMB ($6.30 USD)

  By Agent:
    lead:           2.10 RMB (model tokens only)
    voc-analyst:    8.40 RMB (model + scrape APIs)
    geo-optimizer:  5.20 RMB (model + search APIs)
    reddit-spec:    3.80 RMB (model + search APIs)
    tiktok-director: 26.10 RMB (model + image + video gen)

  By Cost Type:
    Model API:      18.50 RMB
    Image Gen:       7.20 RMB
    Video Gen:      15.00 RMB
    Search APIs:     3.50 RMB
    Scraping APIs:   1.40 RMB
```

### 10.5 Basic Monitoring Setup on Mac Mini

**Step 1: Health Check Cron**
```bash
# Add to crontab: runs every 2 minutes
*/2 * * * * ~/.openclaw/scripts/health-check.sh >> ~/.openclaw/logs/health-check.log 2>&1
```

**health-check.sh**:
```bash
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S%z)
for agent in lead voc-analyst geo-optimizer reddit-spec tiktok-director; do
  STATUS=$(openclaw agent ping $agent --timeout 5 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$agent\",\"status\":\"alive\"}"
  else
    echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$agent\",\"status\":\"dead\"}"
    # Send alert if agent is down
    curl -s -X POST "$FEISHU_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"ALERT: Agent $agent is DOWN at $TIMESTAMP\"}}"
  fi
done
```

**Step 2: Log Aggregation Cron**
```bash
# Runs every 5 minutes
*/5 * * * * ~/.openclaw/scripts/aggregate-logs.sh >> /dev/null 2>&1
```

**Step 3: Daily Cost Report Cron**
```bash
# Runs at 23:59 daily
59 23 * * * ~/.openclaw/scripts/daily-cost-report.sh >> ~/.openclaw/logs/cost-reports.log 2>&1
```

**Step 4: Disk Space Monitor**
```bash
# Runs every hour
0 * * * * df -h / | awk 'NR==2{if(int($5)>90) system("curl -s -X POST $FEISHU_WEBHOOK_URL -H \"Content-Type: application/json\" -d \"{\\\"msg_type\\\":\\\"text\\\",\\\"content\\\":{\\\"text\\\":\\\"ALERT: Disk usage at " $5 "\\\"}}\"")}'
```

**Dashboard Access**: Open `~/.openclaw/dashboard/index.html` in a browser to view the health dashboard (a simple HTML page that reads from the JSONL health check log and renders status cards).

---

## Appendix A: Test Data Files

Test payloads should be saved to `/Users/kinghinchan/e-commerce-claw/plans/test-payloads/` and referenced by the test execution scripts. Each test scenario in Sections 2-5 should have a corresponding JSON payload file.

## Appendix B: Glossary

| Term | Definition |
|------|-----------|
| sessions_send | OpenClaw's native Agent-to-Agent async communication protocol |
| Dark Track | Agent-to-agent data exchange via sessions_send (not visible to users) |
| Light Track | Human-visible progress updates via Feishu messages |
| GEO Score | Quality metric (0-100) for AI-search-optimized content |
| QA Composite | Weighted quality score (0-10) for TikTok videos |
| VOCReport | Structured JSON output from VOC analyst containing market analysis data |
| DAG | Directed Acyclic Graph -- task dependency structure used by Lead for orchestration |
| SOP | Standard Operating Procedure -- the 5-week Reddit account nurturing protocol |
| Traffic Hijacking | Commenting on high-ranking old Reddit posts to capture organic search traffic |
| Breathing Movement | Camera notation (BM) -- handheld sway with 2-3 degree oscillation for UGC feel |

# OpenClaw E-Commerce AI Platform - Test Scenarios

> Directory: `~/.openclaw/tests/`
> Platform: Cross-border e-commerce AI (5-agent architecture)
> Last updated: 2026-03-05

---

## Test Index

| Test ID | File | Name | Agents Involved | Est. Time | Description |
|---------|------|------|-----------------|:---------:|-------------|
| T-001 | `test-sessions-send.md` | Agent-to-Agent Communication | All 5 agents | 2-3 min | Validate `sessions_send` routing whitelist, ping/pong all agents |
| T-002 | `test-e2e-camping-cot.md` | End-to-End Camping Cot | All 5 agents | 15-20 min | Full workflow from Feishu trigger to final report (Section 2.7 case) |
| T-003 | `test-price-monitor.md` | Daily Price Monitoring | voc-analyst | 3-5 min | Cron job simulation: price scrape, comparison, alert generation |
| T-004 | `test-voc-quick-query.md` | VOC Quick Query (Reddit-only) | voc-analyst | 1-2 min | Single-platform fast query for "4K TV" on Reddit |

---

## Prerequisites

### API Keys Required

| Environment Variable | Required For | How to Obtain |
|---------------------|-------------|---------------|
| `DECODO_AUTH_TOKEN` | T-002, T-003, T-004 | Register at Decodo, get auth token |
| `BRAVE_API_KEY` | T-002 | Register at Brave Search API (requires overseas credit card) |
| `APIFY_TOKEN` | T-002 | Register at Apify.com, get API token |
| `TAVILY_API_KEY` | T-002 (optional) | Register at Tavily.com (no credit card needed) |
| `FEISHU_WEBHOOK_URL` | T-002, T-003 | Create Feishu incoming webhook in target group |
| `TELEGRAM_BOT_TOKEN` | T-003 (optional) | Create bot via @BotFather on Telegram |
| `TELEGRAM_CHAT_ID` | T-003 (optional) | Get chat ID from Telegram bot updates |

### Skills Required

| Skill | Required For | Installed? |
|-------|-------------|:----------:|
| Decodo Skill | T-002, T-003, T-004 | Check with `ls ~/.openclaw/skills/decodo/` |
| reddit-readonly | T-002, T-004 | Check with `ls ~/.openclaw/skills/reddit-readonly/` |
| Brave Search | T-002 | Check with `ls ~/.openclaw/skills/brave-search/` |
| Apify Skill | T-002 | Check with `ls ~/.openclaw/skills/apify/` |
| Playwright-npx | T-003 | Check with `ls ~/.openclaw/skills/playwright-npx/` |

### Platform Configuration

- `~/.openclaw/openclaw.json` must have all 5 agents configured
- Feishu app credentials must be real (not placeholders) for T-002
- All agent workspaces must be scaffolded (`workspace-lead/`, `workspace-voc/`, etc.)

### Verification Commands

```bash
# Check openclaw.json exists and is valid JSON
python3 -c "import json; json.load(open('$HOME/.openclaw/openclaw.json')); print('openclaw.json: VALID')"

# Check all workspaces exist
for ws in lead voc geo reddit tiktok; do
  test -d "$HOME/.openclaw/workspace-$ws" && echo "workspace-$ws: OK" || echo "workspace-$ws: MISSING"
done

# Check SOUL.md exists for all agents
for ws in lead voc geo reddit tiktok; do
  test -f "$HOME/.openclaw/workspace-$ws/SOUL.md" && echo "SOUL.md ($ws): OK" || echo "SOUL.md ($ws): MISSING"
done

# Check critical environment variables
for var in DECODO_AUTH_TOKEN BRAVE_API_KEY APIFY_TOKEN; do
  [ -n "${!var}" ] && echo "$var: SET" || echo "$var: NOT SET"
done
```

---

## How to Run Each Test

### T-001: Agent-to-Agent Communication

```bash
# Run the test prompt directly via Lead agent
openclaw run \
  --workspace ~/.openclaw/workspace-lead \
  --prompt-file ~/.openclaw/tests/test-sessions-send.md
```

**Expected duration**: 2-3 minutes
**Pass criteria**: All 5 agents respond with their agent ID and status "ok"

### T-002: End-to-End Camping Cot

```bash
# Option A: Trigger via Feishu (production path)
# Send "@Lead Agent" with message: "分析露营折叠床市场，全渠道铺内容" in the Feishu group

# Option B: Trigger via CLI (testing path)
openclaw run \
  --workspace ~/.openclaw/workspace-lead \
  --prompt-file ~/.openclaw/tests/test-e2e-camping-cot.md
```

**Expected duration**: 15-20 minutes
**Pass criteria**: All 6 steps complete; final report contains VOC data, GEO content, TikTok storyboard, and Reddit comment drafts

### T-003: Daily Price Monitoring

```bash
# Step 1: Seed test data
cp ~/.openclaw/tests/test-price-monitor.md /tmp/price-monitor-test.md

# Step 2: Run the price monitor with test seed
openclaw run \
  --workspace ~/.openclaw/workspace-voc \
  --prompt-file ~/.openclaw/tests/test-price-monitor.md
```

**Expected duration**: 3-5 minutes
**Pass criteria**: Price comparison completed, alert generated for changed prices, price_history file created

### T-004: VOC Quick Query (Reddit-only)

```bash
openclaw run \
  --workspace ~/.openclaw/workspace-voc \
  --prompt-file ~/.openclaw/tests/test-voc-quick-query.md
```

**Expected duration**: 1-2 minutes
**Pass criteria**: Report returned within 120 seconds, at least 10 Reddit posts analyzed, confidence marked LOW

---

## Expected Outcomes Summary

| Test ID | Key Output | Success Indicator |
|---------|-----------|-------------------|
| T-001 | 5 pong responses | All agents reply with `{"agent_id": "...", "status": "ok"}` |
| T-002 | VOC report + GEO blog + Amazon listing + TikTok storyboard + Reddit comment drafts + Final summary | All 6 steps complete, final Feishu card sent |
| T-003 | Price alert JSON + updated `price_memory.txt` + `price_history/{date}.json` | At least 1 price change detected, webhook payload valid |
| T-004 | Quick VOC report (JSON + MD) | `confidence: "LOW"`, `posts_analyzed >= 10`, `execution_time <= 120s` |

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| sessions_send returns "agent not found" | Agent ID not in `openclaw.json` `tools.agentToAgent.allow` list | Add agent ID to the allow array |
| sessions_send returns "routing denied" | Sending agent not allowed to message target agent | Check `tools.agentToAgent.routing` in openclaw.json |
| Decodo returns 401 | Invalid or expired `DECODO_AUTH_TOKEN` | Regenerate token at Decodo dashboard |
| reddit-readonly returns empty | Reddit rate-limiting old.reddit.com JSON endpoints | Wait 60s and retry, or switch to Decodo reddit_subreddit |
| Apify Actor timeout | Actor run exceeded 5 min timeout | Check Apify dashboard for actor health, increase timeout |
| Feishu webhook fails | Invalid webhook URL or expired token | Regenerate incoming webhook in Feishu group settings |
| Price monitor finds no changes | All competitor prices unchanged, or scraping failed | Check scrape_log.jsonl for errors; verify competitor URLs are valid |

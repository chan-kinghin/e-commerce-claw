# PLAN: openclaw.json Master Configuration

**Scope**: Complete production-ready configuration that wires together all 5 agents, Feishu channels, cron jobs, skills, and agent-to-agent communication.

**Status**: Complete

---

## 1. Complete openclaw.json (Production-Ready)

```json
{
  "version": "1.0",
  "platform": "openclaw-ecommerce-ai",
  "description": "Cross-border e-commerce AI platform - multi-agent orchestration config",

  "agents": {
    "defaultAgent": "lead",
    "list": [
      {
        "id": "lead",
        "default": true,
        "workspace": "~/.openclaw/workspace-lead",
        "model": "volcengine/doubao-seed-2.0-code",
        "modelConfig": {
          "temperature": 0.4,
          "maxTokens": 8192
        },
        "role": "orchestrator",
        "description": "Lead agent - sole human interface. Decomposes tasks, dispatches via sessions_send, aggregates results."
      },
      {
        "id": "voc-analyst",
        "workspace": "~/.openclaw/workspace-voc",
        "model": "moonshot/kimi-k2.5",
        "modelConfig": {
          "temperature": 0.3,
          "maxTokens": 8192
        },
        "role": "executor",
        "description": "VOC market analyst - multi-platform data scraping, cross-validation, pain point extraction."
      },
      {
        "id": "geo-optimizer",
        "workspace": "~/.openclaw/workspace-geo",
        "model": "volcengine/doubao-seed-2.0-code",
        "modelConfig": {
          "temperature": 0.7,
          "maxTokens": 8192
        },
        "role": "executor",
        "description": "GEO content optimizer - AI-search-engine-optimized content for blogs, Amazon listings, product descriptions."
      },
      {
        "id": "reddit-spec",
        "workspace": "~/.openclaw/workspace-reddit",
        "model": "moonshot/kimi-k2.5",
        "modelConfig": {
          "temperature": 0.7,
          "maxTokens": 4096
        },
        "role": "executor",
        "description": "Reddit marketing specialist - 5-week account nurturing SOP, traffic hijacking, community engagement."
      },
      {
        "id": "tiktok-director",
        "workspace": "~/.openclaw/workspace-tiktok",
        "model": "volcengine/doubao-seed-2.0-code",
        "modelConfig": {
          "temperature": 0.7,
          "maxTokens": 4096
        },
        "role": "executor",
        "description": "TikTok director - 25-grid storyboard system, UGC video production, manga drama, A/B variant generation."
      }
    ]
  },

  "channels": {
    "feishu": {
      "enabled": true,
      "connectionMode": "websocket",
      "dmPolicy": "open",
      "accounts": {
        "lead":   { "appId": "cli_lead_placeholder",   "appSecret": "REPLACE_WITH_ACTUAL_SECRET" },
        "voc":    { "appId": "cli_voc_placeholder",    "appSecret": "REPLACE_WITH_ACTUAL_SECRET" },
        "geo":    { "appId": "cli_geo_placeholder",    "appSecret": "REPLACE_WITH_ACTUAL_SECRET" },
        "reddit": { "appId": "cli_reddit_placeholder", "appSecret": "REPLACE_WITH_ACTUAL_SECRET" },
        "tiktok": { "appId": "cli_tiktok_placeholder", "appSecret": "REPLACE_WITH_ACTUAL_SECRET" }
      }
    }
  },

  "bindings": [
    { "agentId": "lead",            "match": { "channel": "feishu", "accountId": "lead" },   "priority": 1 },
    { "agentId": "voc-analyst",     "match": { "channel": "feishu", "accountId": "voc" },    "priority": 2 },
    { "agentId": "geo-optimizer",   "match": { "channel": "feishu", "accountId": "geo" },    "priority": 2 },
    { "agentId": "reddit-spec",     "match": { "channel": "feishu", "accountId": "reddit" }, "priority": 2 },
    { "agentId": "tiktok-director", "match": { "channel": "feishu", "accountId": "tiktok" }, "priority": 2 }
  ],

  "tools": {
    "agentToAgent": {
      "enabled": true,
      "protocol": "sessions_send",
      "allow": ["lead", "voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"],
      "routing": {
        "lead":            ["voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"],
        "voc-analyst":     ["lead"],
        "geo-optimizer":   ["lead"],
        "reddit-spec":     ["lead"],
        "tiktok-director": ["lead"]
      }
    }
  },

  "cron": {
    "jobs": [
      {
        "id": "price-monitor",
        "schedule": "0 3 * * *",
        "timezone": "Asia/Shanghai",
        "agent": "voc-analyst",
        "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/price_monitor.md",
        "description": "Daily 03:00 AM UTC+8 price monitoring sweep for tracked competitor ASINs"
      },
      {
        "id": "weekly-trend-digest",
        "schedule": "0 4 * * 0",
        "timezone": "Asia/Shanghai",
        "agent": "voc-analyst",
        "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/weekly_digest.md",
        "description": "Sunday 04:00 AM weekly trend aggregation from daily price snapshots"
      },
      {
        "id": "shadowban-check",
        "schedule": "0 10 * * 1",
        "timezone": "Asia/Shanghai",
        "agent": "reddit-spec",
        "promptFile": "~/.openclaw/workspace-reddit/data/monitoring/shadowban-check-prompt.md",
        "description": "Monday 10:00 AM weekly shadowban detection for all active Reddit accounts"
      },
      {
        "id": "weekly-market-scan",
        "schedule": "0 2 * * 1",
        "timezone": "Asia/Shanghai",
        "agent": "voc-analyst",
        "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/weekly_market_scan.md",
        "description": "Monday 02:00 AM broad market scan for trending categories and emerging competitors"
      },
      {
        "id": "reddit-sop-compliance",
        "schedule": "0 9 * * 5",
        "timezone": "Asia/Shanghai",
        "agent": "reddit-spec",
        "promptFile": "~/.openclaw/workspace-reddit/data/nurturing/sop-compliance-prompt.md",
        "description": "Friday 09:00 AM weekly SOP compliance audit for all Reddit accounts"
      }
    ]
  }
}
```

### Key Differences from Current Config

| Item | Current Config | Production Config |
|------|---------------|-------------------|
| `defaultAgent` field | Missing | Added `"defaultAgent": "lead"` |
| `default: true` on lead | Missing | Added to lead agent entry |
| `dmPolicy` | Missing | Added `"open"` to feishu channel |
| VOC Feishu account | Missing | Added `"voc"` account with placeholder credentials |
| VOC Feishu binding | Missing | Added binding for voc-analyst to "voc" accountId |
| Binding priority | Missing | Added `"priority"` field to all bindings |
| Cron: weekly-market-scan | Missing | Added Monday 02:00 AM broad market scan |
| Cron: reddit-sop-compliance | Missing | Added Friday 09:00 AM SOP compliance audit |

---

## 2. Agent Definitions Deep Dive

### 2.1 Lead (Orchestrator)

| Attribute | Value |
|-----------|-------|
| **Agent ID** | `lead` |
| **Model** | `volcengine/doubao-seed-2.0-code` |
| **Workspace** | `~/.openclaw/workspace-lead/` |
| **Role** | `orchestrator` |
| **Default** | `true` (only agent marked default) |
| **Temperature** | 0.4 (lower for reliable task decomposition) |
| **Max Tokens** | 8192 |
| **Can communicate with** | All 4 specialist agents |
| **Receives communication from** | All 4 specialist agents (return results) |

**Why doubao-seed-2.0-code**: The orchestrator needs top-tier reasoning for multi-step task decomposition, DAG planning, and result aggregation. It also needs to understand cross-domain context (when VOC data should route to GEO vs TikTok vs Reddit).

**Critical Files**:
- `SOUL.md` -- orchestrator personality and delegation rules
- `AGENTS.md` -- team directory with each agent's capabilities and sessions_send addresses

### 2.2 VOC Analyst

| Attribute | Value |
|-----------|-------|
| **Agent ID** | `voc-analyst` |
| **Model** | `moonshot/kimi-k2.5` |
| **Workspace** | `~/.openclaw/workspace-voc/` |
| **Role** | `executor` |
| **Default** | `false` |
| **Temperature** | 0.3 (lowest -- for consistent structured JSON output) |
| **Max Tokens** | 8192 (reports can be large) |
| **Can communicate with** | Lead only |
| **Receives tasks from** | Lead only |

**Why Kimi K2.5**: VOC tasks are execution-heavy (data scraping, cleaning, formatting). The low temperature ensures deterministic structured output. Cost savings ~90% vs decision-layer models. The critical capability is tool calling reliability, not creative reasoning.

### 2.3 GEO Optimizer

| Attribute | Value |
|-----------|-------|
| **Agent ID** | `geo-optimizer` |
| **Model** | `volcengine/doubao-seed-2.0-code` |
| **Workspace** | `~/.openclaw/workspace-geo/` |
| **Role** | `executor` |
| **Default** | `false` |
| **Temperature** | 0.7 (higher for natural writing variation) |
| **Max Tokens** | 8192 (blog posts can be 2000+ words) |
| **Can communicate with** | Lead only |
| **Receives tasks from** | Lead only |

**Why doubao-seed-2.0-code**: GEO content requires nuanced understanding of how LLMs extract facts. The agent must write content that is both data-dense and naturally readable. Self-evaluation against the GEO Rules Engine (22 rules across 4 categories) requires top-tier reasoning.

### 2.4 Reddit Specialist

| Attribute | Value |
|-----------|-------|
| **Agent ID** | `reddit-spec` |
| **Model** | `moonshot/kimi-k2.5` |
| **Workspace** | `~/.openclaw/workspace-reddit/` |
| **Role** | `executor` |
| **Default** | `false` |
| **Temperature** | 0.7 (higher for natural, non-robotic comment writing) |
| **Max Tokens** | 4096 (comments are short, 100-250 words) |
| **Can communicate with** | Lead only |
| **Receives tasks from** | Lead only |

**Why Kimi K2.5**: Reddit comment generation is execution-layer work. The higher temperature compensates for the model tier -- comments need to feel genuinely human, not formulaic. The 4096 token limit is sufficient since Reddit comments are short. Account management and SOP compliance are procedural tasks well-suited to this model tier.

### 2.5 TikTok Director

| Attribute | Value |
|-----------|-------|
| **Agent ID** | `tiktok-director` |
| **Model** | `volcengine/doubao-seed-2.0-code` |
| **Workspace** | `~/.openclaw/workspace-tiktok/` |
| **Role** | `executor` |
| **Default** | `false` |
| **Temperature** | 0.7 (for creative storyboard generation) |
| **Max Tokens** | 4096 |
| **Can communicate with** | Lead only |
| **Receives tasks from** | Lead only |

**Why doubao-seed-2.0-code**: The TikTok Director needs multimodal understanding (VLM) for video QA via volcengine-video-understanding. It also needs strong reasoning for 25-grid storyboard design, which maps pain points to camera movements, timing, and emotional beats. Creative prompting for nano-banana-pro and Seedance requires a top-tier model.

---

## 3. Feishu Channel Configuration

### 3.1 Five Feishu App Configs

Each agent gets its own independent Feishu application. This means 5 separate apps created in the Feishu Open Platform console.

| Account Key | Feishu App Name | Agent Bound To | Purpose |
|-------------|----------------|----------------|---------|
| `lead` | openclaw-lead | `lead` | Primary human interface. Users @-mention this bot to trigger tasks. |
| `voc` | openclaw-voc | `voc-analyst` | Direct Feishu access for VOC analyst (optional, primarily for status visibility). |
| `geo` | openclaw-geo | `geo-optimizer` | Direct access for content review and approval. |
| `reddit` | openclaw-reddit | `reddit-spec` | Status updates and alerts (shadowban notifications, weekly reports). |
| `tiktok` | openclaw-tiktok | `tiktok-director` | Video delivery and QA review escalations. |

### 3.2 WebSocket vs Webhook

| Mode | WebSocket | Webhook |
|------|-----------|---------|
| **Connection** | Persistent bidirectional | HTTP POST per event |
| **Latency** | Low (~100ms) | Medium (~500ms-2s) |
| **Reliability** | Requires stable process | More resilient to restarts |
| **Firewall** | Outbound only (no public IP needed) | Requires public endpoint |
| **Recommendation** | **Use this** for Mac mini local deployment | Use for cloud deployment |

**Decision**: `"connectionMode": "websocket"` -- Since this runs on a Mac mini behind a local network, WebSocket is the correct choice. It avoids the need to expose a public HTTP endpoint for webhook callbacks.

### 3.3 dmPolicy Explanation

```json
"dmPolicy": "open"
```

| Policy | Behavior |
|--------|----------|
| `"open"` | Any Feishu user can DM the bot and trigger agent responses |
| `"restricted"` | Only users in approved groups/contacts can interact |
| `"disabled"` | Bot only responds in group chats, not DMs |

**Chosen**: `"open"` -- For the initial deployment phase, all team members should be able to interact freely. Switch to `"restricted"` in production if access control is needed.

### 3.4 Account Naming Conventions

- Account keys in `channels.feishu.accounts` use short lowercase identifiers: `lead`, `voc`, `geo`, `reddit`, `tiktok`
- These keys are referenced in `bindings[].match.accountId`
- Feishu App names use the pattern `openclaw-{agent-short-name}` for consistency

### 3.5 Why VOC Analyst Gets a Feishu Binding

**Previous approach**: The original blog post only showed 4 Feishu accounts (lead, geo, reddit, tiktok), with VOC receiving tasks only via sessions_send.

**Updated approach**: VOC analyst now has its own Feishu binding for two reasons:
1. **Status visibility**: The Lead can post VOC analysis progress cards visible to humans in the Feishu group
2. **Direct queries**: Power users may want to ask VOC directly for quick market checks without going through Lead
3. **Cron alerts**: Price monitoring alerts can be pushed directly through VOC's Feishu app

This is optional -- if you want to keep VOC strictly backend-only, remove the `voc` entry from `channels.feishu.accounts` and the corresponding binding.

---

## 4. Bindings Array

### 4.1 Binding-to-Agent Mapping

```json
"bindings": [
  { "agentId": "lead",            "match": { "channel": "feishu", "accountId": "lead" },   "priority": 1 },
  { "agentId": "voc-analyst",     "match": { "channel": "feishu", "accountId": "voc" },    "priority": 2 },
  { "agentId": "geo-optimizer",   "match": { "channel": "feishu", "accountId": "geo" },    "priority": 2 },
  { "agentId": "reddit-spec",     "match": { "channel": "feishu", "accountId": "reddit" }, "priority": 2 },
  { "agentId": "tiktok-director", "match": { "channel": "feishu", "accountId": "tiktok" }, "priority": 2 }
]
```

### 4.2 How Routing Works

When a Feishu message arrives, OpenClaw evaluates the bindings array in priority order:

1. **Match by accountId**: The `accountId` in the binding must match the Feishu app that received the message
2. **Route to agentId**: The matched binding's `agentId` determines which agent processes the message
3. **Priority**: Lower number = higher priority. If multiple bindings could match (unlikely with distinct accounts), the highest-priority binding wins

### 4.3 Priority Rationale

- **Lead has priority 1**: If any routing ambiguity exists, Lead should be the fallback handler. Lead is the designated human interface and can re-route if needed.
- **All specialists have priority 2**: Equal priority among specialists since they each have a unique accountId -- no ambiguity possible.

### 4.4 VOC Analyst Binding Consideration

The VOC analyst binding is included but optional. Arguments for and against:

| For Binding | Against Binding |
|-------------|-----------------|
| Enables direct human queries to VOC | VOC should only receive tasks from Lead (discipline) |
| Price monitoring alerts can use its own Feishu identity | Adds complexity -- one more Feishu app to manage |
| Status cards show which agent is working | Lead can relay VOC status to Feishu on VOC's behalf |

**Recommendation**: Include the binding. The overhead of one more Feishu app is minimal, and the visibility benefit is significant for debugging and monitoring.

---

## 5. Agent-to-Agent Communication Matrix

### 5.1 Communication Permissions

| From \ To | lead | voc-analyst | geo-optimizer | reddit-spec | tiktok-director |
|-----------|:----:|:-----------:|:-------------:|:-----------:|:---------------:|
| **lead** | -- | SEND | SEND | SEND | SEND |
| **voc-analyst** | REPLY | -- | -- | -- | -- |
| **geo-optimizer** | REPLY | -- | -- | -- | -- |
| **reddit-spec** | REPLY | -- | -- | -- | -- |
| **tiktok-director** | REPLY | -- | -- | -- | -- |

### 5.2 Routing Rules in Config

```json
"routing": {
  "lead":            ["voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"],
  "voc-analyst":     ["lead"],
  "geo-optimizer":   ["lead"],
  "reddit-spec":     ["lead"],
  "tiktok-director": ["lead"]
}
```

### 5.3 Why This Hub-and-Spoke Topology

1. **Lead can send to all**: Lead is the orchestrator. It decomposes user requests into sub-tasks and dispatches them to the appropriate specialist via `sessions_send`. It must reach every agent.

2. **Specialists can only respond to Lead**: Specialists never communicate directly with each other. All inter-specialist data flows through Lead as a relay. This prevents:
   - **Circular dependencies**: VOC sends to GEO, GEO sends to Reddit, Reddit sends back to VOC -- deadlock
   - **Context confusion**: If GEO could directly query VOC, both Lead and GEO might send conflicting requests
   - **Audit trail loss**: Lead logs all dispatches and responses, enabling full task traceability

3. **Why not peer-to-peer (mesh)?**: In a mesh topology, any agent could talk to any other. This creates coordination nightmares:
   - Who resolves conflicting requests?
   - How do you debug when 5 agents are talking to each other simultaneously?
   - Hub-and-spoke is simpler, debuggable, and sufficient for our workflow

### 5.4 Security Considerations

- **API key isolation**: Each agent only has access to the skills and API keys loaded in its workspace. VOC cannot access Reddit's account credentials, and Reddit cannot access VOC's Decodo API token.
- **Workspace isolation**: Sessions_send payloads are the ONLY cross-agent data pathway. An agent cannot read another agent's workspace files.
- **No credential forwarding**: Agents must NEVER include API keys, tokens, or credentials in sessions_send messages.
- **Lead as gatekeeper**: Since all inter-agent communication goes through Lead, Lead can validate, filter, and log all data exchanges.

---

## 6. Cron Job Definitions

### 6.1 Price Monitoring -- Daily 03:00 AM UTC+8

```json
{
  "id": "price-monitor",
  "schedule": "0 3 * * *",
  "timezone": "Asia/Shanghai",
  "agent": "voc-analyst",
  "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/price_monitor.md"
}
```

| Attribute | Value |
|-----------|-------|
| **Agent** | voc-analyst |
| **Schedule** | Daily at 03:00 AM Beijing time |
| **Why 03:00 AM** | Most US Amazon sellers adjust prices overnight. 03:00 AM Beijing = 3:00 PM ET previous day / 12:00 PM PT previous day, capturing late-afternoon US price changes. |
| **What it does** | (1) Load tracked ASINs from `data/price_memory.txt`, (2) scrape current prices via Playwright/web_fetch, (3) compare against yesterday's snapshot, (4) if changes detected, push webhook alert to Feishu, (5) update `price_memory.txt` and append to `price_history/` |
| **Output** | Alert JSON pushed to Feishu webhook (if changes detected), updated price snapshot, history file |
| **Cost** | ~$0.10-0.15/day for 50 tracked ASINs |

### 6.2 Weekly Trend Digest -- Sunday 04:00 AM UTC+8

```json
{
  "id": "weekly-trend-digest",
  "schedule": "0 4 * * 0",
  "timezone": "Asia/Shanghai",
  "agent": "voc-analyst",
  "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/weekly_digest.md"
}
```

| Attribute | Value |
|-----------|-------|
| **Agent** | voc-analyst |
| **Schedule** | Every Sunday at 04:00 AM (1 hour after price monitor) |
| **What it does** | (1) Read 7 daily snapshots from `price_history/`, (2) compute 7-day price trajectories per ASIN (min, max, avg, direction), (3) calculate BSR rank movement, (4) measure review velocity, (5) generate a weekly digest report, (6) send to Lead via sessions_send |
| **Output** | Weekly trend digest report (JSON + Markdown), forwarded to Lead for Feishu distribution |

### 6.3 Shadowban Check -- Monday 10:00 AM UTC+8

```json
{
  "id": "shadowban-check",
  "schedule": "0 10 * * 1",
  "timezone": "Asia/Shanghai",
  "agent": "reddit-spec",
  "promptFile": "~/.openclaw/workspace-reddit/data/monitoring/shadowban-check-prompt.md"
}
```

| Attribute | Value |
|-----------|-------|
| **Agent** | reddit-spec |
| **Schedule** | Every Monday at 10:00 AM |
| **What it does** | (1) Load all active accounts from `account-registry.json`, (2) for each, check profile visibility via logged-out request (Playwright or reddit-readonly), (3) confirm with secondary method if primary fails, (4) update `shadowban-checks.jsonl`, (5) if shadowban detected, trigger 14-day cooldown and alert Lead |
| **Output** | Updated shadowban check results, alert to Lead if any account is compromised |

### 6.4 Weekly Market Scan -- Monday 02:00 AM UTC+8

```json
{
  "id": "weekly-market-scan",
  "schedule": "0 2 * * 1",
  "timezone": "Asia/Shanghai",
  "agent": "voc-analyst",
  "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/weekly_market_scan.md"
}
```

| Attribute | Value |
|-----------|-------|
| **Agent** | voc-analyst |
| **Schedule** | Every Monday at 02:00 AM |
| **What it does** | (1) Scan Amazon BSR movers in tracked categories, (2) search Brave/Tavily for trending product keywords, (3) check Reddit for emerging pain points in target subreddits, (4) generate a market intelligence briefing, (5) send to Lead |
| **Output** | Market scan report with trending categories, emerging competitors, and opportunity signals |

### 6.5 Reddit SOP Compliance -- Friday 09:00 AM UTC+8

```json
{
  "id": "reddit-sop-compliance",
  "schedule": "0 9 * * 5",
  "timezone": "Asia/Shanghai",
  "agent": "reddit-spec",
  "promptFile": "~/.openclaw/workspace-reddit/data/nurturing/sop-compliance-prompt.md"
}
```

| Attribute | Value |
|-----------|-------|
| **Agent** | reddit-spec |
| **Schedule** | Every Friday at 09:00 AM |
| **What it does** | (1) Load SOP progress for all accounts from `sop-progress.json`, (2) check W1-W5 compliance rules against activity logs, (3) verify promotional-to-organic ratios, (4) generate weekly SOP compliance report, (5) send to Lead |
| **Output** | SOP compliance report per account, posted to `weekly-reports/` |

---

## 7. Skills Configuration

### 7.1 Global Skills (`~/.openclaw/skills/`)

Skills installed here are available to ALL agents. Use for shared, cross-agent capabilities.

| Skill | Used By | Install Source | API Key Required |
|-------|---------|---------------|:----------------:|
| `nano-banana-pro` | tiktok-director, geo-optimizer | `clawhub install nano-banana-pro --global` | Google API key |
| `seedance-video` (canghe-seedance-video) | tiktok-director | `clawhub install canghe-seedance-video --global` | Volcengine API (Coding Plan) |
| `canghe-image-gen` | tiktok-director | `clawhub install canghe-image-gen --global` | Google API / third-party |
| `reddit-readonly` | voc-analyst, reddit-spec | `curl https://lobehub.com/skills/...` | None |
| `brave-search` | voc-analyst, geo-optimizer, reddit-spec | `clawhub install brave-search --global` | `BRAVE_API_KEY` |
| `tavily` | voc-analyst, geo-optimizer | `clawhub install tavily --global` | `TAVILY_API_KEY` |
| `exa` | voc-analyst, geo-optimizer | `clawhub install exa --global` | `EXA_API_KEY` |
| `decodo` | voc-analyst, reddit-spec | `clawhub install decodo --global` | `DECODO_AUTH_TOKEN` |
| `firecrawl` | voc-analyst, geo-optimizer | `clawhub install firecrawl --global` | `FIRECRAWL_API_KEY` |
| `playwright-npx` | voc-analyst, geo-optimizer, reddit-spec | `clawhub install playwright-npx --global` | None |
| `apify` | voc-analyst | `clawhub install apify --global` | `APIFY_TOKEN` |

### 7.2 Agent-Specific Skills

Skills installed in an agent's workspace `skills/` directory are only available to that agent.

**workspace-tiktok/skills/**:

| Skill | Purpose | Install Command |
|-------|---------|-----------------|
| `manga-style-video` | 8 manga style presets with professional prompts | `clawhub install manga-style-video --workspace workspace-tiktok` |
| `manga-drama` | Single-image to multi-scene drama pipeline | `clawhub install manga-drama --workspace workspace-tiktok` |
| `volcengine-video-understanding` | Video QA, scene recognition, quality scoring | `clawhub install volcengine-video-understanding --workspace workspace-tiktok` |

**workspace-reddit/skills/**:

| Skill | Purpose | Install Command |
|-------|---------|-----------------|
| `reddit-poster` (private) | Account-specific Reddit posting (if available) | Manual install in workspace |

**workspace-voc/skills/**:

| Skill | Purpose | Install Command |
|-------|---------|-----------------|
| `agent-reach` | yt-dlp, xreach (Twitter), Jina Reader | `clawhub install agent-reach --workspace workspace-voc` |

**workspace-lead/skills/**:

| Skill | Purpose | Install Command |
|-------|---------|-----------------|
| (none agent-specific) | Lead uses only sessions_send and global skills | -- |

**workspace-geo/skills/**:

| Skill | Purpose | Install Command |
|-------|---------|-----------------|
| (none agent-specific) | GEO uses global search and web extraction skills | -- |

### 7.3 Loading Priority Rules

```
1. Agent workspace skills/ directory  (HIGHEST PRIORITY -- overrides global)
2. Global ~/.openclaw/skills/ directory  (FALLBACK)
```

**Why this matters**:
- If `manga-style-video` exists in both global and workspace-tiktok, the workspace version takes precedence
- This allows agent-specific customizations without affecting other agents
- Prevents "tool hallucination" -- an agent cannot accidentally invoke another agent's private skills
- API key isolation -- private skills can use different API keys than global versions

### 7.4 Preventing Tool Hallucination

Tool hallucination occurs when a model "remembers" skills from training data that are not actually installed. Mitigations:

1. **Workspace isolation**: Each agent only sees skills in its own workspace + global. It cannot see other workspaces.
2. **SOUL.md tool lists**: Each agent's SOUL.md explicitly lists the tools it should use, in priority order. Tools not listed should be treated as unavailable.
3. **Skill verification**: Before calling a skill, agents should verify it exists. If a skill call fails, log the error rather than retrying with fabricated parameters.

---

## 8. Environment Variables Checklist

### 8.1 Required Variables

| Variable | Required By | Where to Get | Example Value |
|----------|-------------|-------------|---------------|
| `VOLCENGINE_API_KEY` | lead, geo-optimizer, tiktok-director | Volcengine console (ByteDance) | `vol_xxxxxxxxxxxx` |
| `VOLCENGINE_MODEL_ENDPOINT` | lead, geo-optimizer, tiktok-director | Volcengine model deployment page | `https://ark.cn-beijing.volces.com/api/v3` |
| `MOONSHOT_API_KEY` | voc-analyst, reddit-spec | Moonshot AI console (Kimi) | `sk-xxxxxxxxxxxxxxxxxx` |
| `DECODO_AUTH_TOKEN` | voc-analyst, reddit-spec | Decodo dashboard | `VTAwMDAz...` |
| `BRAVE_API_KEY` | voc-analyst, geo-optimizer, reddit-spec | Brave Search API console | `BSAl2YP5...` |
| `APIFY_TOKEN` | voc-analyst | Apify console | `apify_api_5kIYzp...` |

### 8.2 Feishu App Credentials (5 apps)

| Variable | App | Where to Get |
|----------|-----|-------------|
| `FEISHU_LEAD_APP_ID` | Lead bot | Feishu Open Platform > App > Credentials |
| `FEISHU_LEAD_APP_SECRET` | Lead bot | Same page |
| `FEISHU_VOC_APP_ID` | VOC bot | Same process, different app |
| `FEISHU_VOC_APP_SECRET` | VOC bot | Same page |
| `FEISHU_GEO_APP_ID` | GEO bot | Same process |
| `FEISHU_GEO_APP_SECRET` | GEO bot | Same page |
| `FEISHU_REDDIT_APP_ID` | Reddit bot | Same process |
| `FEISHU_REDDIT_APP_SECRET` | Reddit bot | Same page |
| `FEISHU_TIKTOK_APP_ID` | TikTok bot | Same process |
| `FEISHU_TIKTOK_APP_SECRET` | TikTok bot | Same page |

### 8.3 Optional Enhancement Variables

| Variable | Required By | Where to Get | Example Value |
|----------|-------------|-------------|---------------|
| `TAVILY_API_KEY` | voc-analyst, geo-optimizer | Tavily.com | `tvly-...` |
| `EXA_API_KEY` | voc-analyst, geo-optimizer | Exa.ai | `exa-...` |
| `FIRECRAWL_API_KEY` | voc-analyst, geo-optimizer | Firecrawl.dev | `fc-...` |
| `FEISHU_WEBHOOK_URL` | voc-analyst (price alerts) | Feishu group > Add Bot > Incoming Webhook | `https://open.feishu.cn/open-apis/bot/v2/hook/xxxx` |
| `TELEGRAM_BOT_TOKEN` | voc-analyst (price alerts) | BotFather on Telegram | `123456:ABC-DEF...` |
| `TELEGRAM_CHAT_ID` | voc-analyst (price alerts) | Telegram group/channel ID | `-100123456789` |

### 8.4 Reddit Account Variables (per account)

| Variable | Purpose | Example |
|----------|---------|---------|
| `REDDIT_ACC_001_TOKEN` | OAuth token for account acc-001 | `eyJhbGciOiJSUz...` |
| `REDDIT_ACC_001_SECRET` | OAuth client secret | `xxxxxxxxxxx` |
| `REDDIT_ACC_002_TOKEN` | OAuth token for account acc-002 | `eyJhbGciOiJSUz...` |
| `REDDIT_ACC_002_SECRET` | OAuth client secret | `xxxxxxxxxxx` |

### 8.5 Setting Up Environment Variables

```bash
# Create a .env file (NEVER commit this file)
cat > ~/.openclaw/.env << 'EOF'
# === Model API Keys ===
VOLCENGINE_API_KEY=vol_xxxxxxxxxxxx
VOLCENGINE_MODEL_ENDPOINT=https://ark.cn-beijing.volces.com/api/v3
MOONSHOT_API_KEY=sk-xxxxxxxxxxxxxxxxxx

# === Scraping & Search ===
DECODO_AUTH_TOKEN=VTAwMDAz...
BRAVE_API_KEY=BSAl2YP5...
APIFY_TOKEN=apify_api_5kIYzp...
TAVILY_API_KEY=tvly-...
EXA_API_KEY=exa-...
FIRECRAWL_API_KEY=fc-...

# === Feishu Apps (5) ===
FEISHU_LEAD_APP_ID=cli_xxxxxxxxx
FEISHU_LEAD_APP_SECRET=xxxxxxxxxxxxxxxxxxxxx
FEISHU_VOC_APP_ID=cli_xxxxxxxxx
FEISHU_VOC_APP_SECRET=xxxxxxxxxxxxxxxxxxxxx
FEISHU_GEO_APP_ID=cli_xxxxxxxxx
FEISHU_GEO_APP_SECRET=xxxxxxxxxxxxxxxxxxxxx
FEISHU_REDDIT_APP_ID=cli_xxxxxxxxx
FEISHU_REDDIT_APP_SECRET=xxxxxxxxxxxxxxxxxxxxx
FEISHU_TIKTOK_APP_ID=cli_xxxxxxxxx
FEISHU_TIKTOK_APP_SECRET=xxxxxxxxxxxxxxxxxxxxx

# === Webhooks ===
FEISHU_WEBHOOK_URL=https://open.feishu.cn/open-apis/bot/v2/hook/xxxx
TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
TELEGRAM_CHAT_ID=-100123456789

# === Reddit Accounts ===
REDDIT_ACC_001_TOKEN=eyJhbGciOiJSUz...
REDDIT_ACC_001_SECRET=xxxxxxxxxxx
EOF

# Source in your shell profile
echo 'source ~/.openclaw/.env' >> ~/.zshrc
```

---

## 9. Directory Structure

The complete `~/.openclaw/` directory tree that must exist before `openclaw gateway restart`:

```
~/.openclaw/
├── openclaw.json                          # Master config (this document's Section 1)
├── .env                                   # Environment variables (NEVER commit)
├── skills/                                # Global shared skills
│   ├── nano-banana-pro/                   # Image generation
│   ├── canghe-seedance-video/             # Video generation (Seedance 1.5 Pro)
│   ├── canghe-image-gen/                  # Character image generation
│   ├── reddit-readonly/                   # Free Reddit data access
│   ├── brave-search/                      # Brave Search API
│   ├── tavily/                            # Tavily search (China-direct)
│   ├── exa/                               # Exa intent-based search
│   ├── decodo/                            # Decodo scraping (Amazon, Reddit, YouTube)
│   ├── firecrawl/                         # Remote browser sandbox
│   ├── playwright-npx/                    # Dynamic SPA scraping
│   └── apify/                             # Industrial-grade cloud scraping
│
├── workspace-lead/                        # Lead Agent (Orchestrator)
│   ├── SOUL.md                            # Orchestrator identity and rules
│   ├── AGENTS.md                          # Team directory (all 4 specialists)
│   └── skills/                            # (empty -- Lead uses global skills only)
│
├── workspace-voc/                         # VOC Market Analyst
│   ├── SOUL.md                            # VOC identity and data rules
│   ├── skills/
│   │   └── agent-reach/                   # yt-dlp, xreach, Jina Reader
│   ├── data/
│   │   ├── reports/                       # Finalized analysis reports (JSON + MD)
│   │   ├── raw/                           # Raw scraped data per session
│   │   │   ├── amazon/
│   │   │   ├── reddit/
│   │   │   ├── youtube/
│   │   │   ├── google-maps/
│   │   │   └── tiktok/
│   │   ├── price_memory.txt               # Current price snapshot
│   │   ├── price_history/                 # Daily price snapshots
│   │   └── competitor_profiles/           # Tracked competitor ASINs
│   ├── templates/
│   │   ├── report_template.md
│   │   └── prompt_templates/
│   │       ├── cross_validation.md
│   │       ├── pain_point_extraction.md
│   │       ├── price_monitor.md           # Cron: daily price check
│   │       ├── weekly_digest.md           # Cron: weekly trend report
│   │       └── weekly_market_scan.md      # Cron: weekly market scan
│   └── logs/
│       └── scrape_log.jsonl
│
├── workspace-geo/                         # GEO Content Optimizer
│   ├── SOUL.md                            # GEO identity and content rules
│   ├── skills/                            # (empty -- uses global skills)
│   ├── data/
│   │   ├── input/
│   │   │   └── voc-reports/               # Received pain point data
│   │   ├── output/
│   │   │   ├── blogs/                     # GEO-optimized blog posts (.md)
│   │   │   ├── amazon-listings/           # Amazon listing packages (.json)
│   │   │   └── product-descriptions/      # Product descriptions (.html/.md)
│   │   ├── research/
│   │   │   ├── authority-sources/         # Cached authority citations
│   │   │   └── competitor-content/        # Competitor content analysis
│   │   ├── templates/
│   │   │   ├── blog-template.md
│   │   │   ├── amazon-listing-template.json
│   │   │   └── product-description-template.md
│   │   └── quality-logs/
│   │       └── score-history.jsonl        # GEO quality score log
│   ├── rules/
│   │   └── geo-rules.md                   # GEO Rules Engine (22 rules)
│   └── prompts/
│       ├── blog-system-prompt.md
│       ├── amazon-system-prompt.md
│       └── scoring-prompt.md
│
├── workspace-reddit/                      # Reddit Marketing Specialist
│   ├── SOUL.md                            # Reddit identity and engagement rules
│   ├── skills/
│   │   └── reddit-poster/                 # Private posting skill (if available)
│   ├── data/
│   │   ├── accounts/
│   │   │   ├── account-registry.json      # Master account list
│   │   │   ├── acc-001/                   # Per-account data
│   │   │   │   ├── profile.json
│   │   │   │   ├── activity-log.jsonl
│   │   │   │   ├── cooldown-state.json
│   │   │   │   └── assigned-subs.json
│   │   │   └── acc-NNN/
│   │   ├── nurturing/
│   │   │   ├── sop-progress.json          # W1-W5 progress per account
│   │   │   ├── weekly-reports/            # SOP compliance reports
│   │   │   ├── karma-snapshots.jsonl      # Daily karma tracking
│   │   │   └── sop-compliance-prompt.md   # Cron: SOP audit
│   │   ├── hijacking/
│   │   │   ├── target-posts.json          # High-ranking old posts
│   │   │   ├── comment-drafts/
│   │   │   ├── comment-history.jsonl
│   │   │   └── post-evaluations.jsonl
│   │   ├── content/
│   │   │   ├── subreddit-profiles/        # 6 tone profiles
│   │   │   │   ├── r-BuyItForLife.md
│   │   │   │   ├── r-SkincareAddiction.md
│   │   │   │   ├── r-Camping.md
│   │   │   │   ├── r-CampingGear.md
│   │   │   │   ├── r-HomeImprovement.md
│   │   │   │   └── r-AmazonSeller.md
│   │   │   ├── comment-templates/
│   │   │   └── product-briefs/
│   │   └── monitoring/
│   │       ├── shadowban-checks.jsonl
│   │       ├── shadowban-check-prompt.md  # Cron: weekly shadowban check
│   │       ├── comment-performance.jsonl
│   │       └── alerts.jsonl
│   └── logs/
│       ├── agent-activity.log
│       └── errors.log
│
├── workspace-tiktok/                      # TikTok Director
│   ├── SOUL.md                            # TikTok identity and creative rules
│   ├── skills/
│   │   ├── manga-style-video/             # 8 manga style presets
│   │   ├── manga-drama/                   # Storyboard-to-video pipeline
│   │   └── volcengine-video-understanding/ # Video QA
│   ├── templates/
│   │   ├── storyboard-25grid.json         # 25-grid storyboard template
│   │   ├── storyboard-ugc.json            # UGC video template
│   │   ├── storyboard-manga.json          # Manga drama template
│   │   └── camera-notation.md             # Camera movement reference
│   ├── data/
│   │   ├── projects/                      # Per-product folders
│   │   │   └── {product-slug}/
│   │   │       ├── brief.json
│   │   │       ├── voc-data.json
│   │   │       ├── storyboard.json
│   │   │       ├── images/
│   │   │       ├── videos/
│   │   │       ├── final/
│   │   │       └── qa-report.json
│   │   ├── style-library/                 # 8 manga style guides
│   │   │   ├── japanese.md
│   │   │   ├── ghibli.md
│   │   │   ├── chinese.md
│   │   │   ├── cartoon.md
│   │   │   ├── sketch.md
│   │   │   ├── watercolor.md
│   │   │   ├── manga_comic.md
│   │   │   └── chibi.md
│   │   └── performance-log.json
│   ├── output/
│   │   ├── videos/                        # Delivery-ready videos
│   │   ├── thumbnails/                    # A/B test thumbnails
│   │   └── metadata/                      # Distribution metadata
│   └── config/
│       └── model-config.json
│
├── install-skills.sh                      # Skill installation script
└── tests/
    └── validate-config.sh                 # Config validation script
```

---

## 10. Validation & Startup Checklist

### 10.1 Validate openclaw.json Syntax

```bash
# Step 1: JSON syntax validation
python3 -c "import json; json.load(open('$HOME/.openclaw/openclaw.json')); print('JSON syntax: PASS')"

# Step 2: Structural validation (check required fields)
python3 << 'PYEOF'
import json, sys

with open("$HOME/.openclaw/openclaw.json") as f:
    config = json.load(f)

errors = []

# Check agents
if "agents" not in config or "list" not in config["agents"]:
    errors.append("Missing agents.list")
else:
    agent_ids = [a["id"] for a in config["agents"]["list"]]
    required_agents = ["lead", "voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"]
    for req in required_agents:
        if req not in agent_ids:
            errors.append(f"Missing agent: {req}")

    # Check default agent
    defaults = [a for a in config["agents"]["list"] if a.get("default")]
    if len(defaults) != 1:
        errors.append(f"Expected 1 default agent, found {len(defaults)}")
    elif defaults[0]["id"] != "lead":
        errors.append(f"Default agent should be 'lead', found '{defaults[0]['id']}'")

# Check channels
if "channels" not in config or "feishu" not in config["channels"]:
    errors.append("Missing channels.feishu")
elif not config["channels"]["feishu"].get("enabled"):
    errors.append("Feishu channel not enabled")

# Check bindings
if "bindings" not in config:
    errors.append("Missing bindings array")
else:
    bound_agents = [b["agentId"] for b in config["bindings"]]
    if "lead" not in bound_agents:
        errors.append("Lead agent has no Feishu binding")

# Check tools.agentToAgent
if "tools" not in config or "agentToAgent" not in config["tools"]:
    errors.append("Missing tools.agentToAgent")
elif not config["tools"]["agentToAgent"].get("enabled"):
    errors.append("agentToAgent not enabled")

# Check cron
if "cron" not in config or "jobs" not in config["cron"]:
    errors.append("Missing cron.jobs")

if errors:
    print(f"VALIDATION FAILED: {len(errors)} errors")
    for e in errors:
        print(f"  - {e}")
    sys.exit(1)
else:
    print("VALIDATION PASS: All required fields present")
PYEOF
```

### 10.2 Pre-Flight Checks Before `openclaw gateway restart`

```bash
#!/bin/bash
# Pre-flight checklist for OpenClaw startup

echo "=== OpenClaw Pre-Flight Checks ==="
ERRORS=0

# 1. openclaw.json exists and is valid JSON
echo -n "1. Config file syntax... "
if python3 -c "import json; json.load(open('$HOME/.openclaw/openclaw.json'))" 2>/dev/null; then
    echo "PASS"
else
    echo "FAIL: Invalid JSON"
    ERRORS=$((ERRORS+1))
fi

# 2. All workspace directories exist
echo -n "2. Workspace directories... "
WORKSPACES="workspace-lead workspace-voc workspace-geo workspace-reddit workspace-tiktok"
for ws in $WORKSPACES; do
    if [ ! -d "$HOME/.openclaw/$ws" ]; then
        echo "FAIL: Missing $ws"
        ERRORS=$((ERRORS+1))
    fi
done
echo "PASS"

# 3. SOUL.md exists in each workspace
echo -n "3. SOUL.md files... "
for ws in $WORKSPACES; do
    if [ ! -f "$HOME/.openclaw/$ws/SOUL.md" ]; then
        echo "FAIL: Missing SOUL.md in $ws"
        ERRORS=$((ERRORS+1))
    fi
done
echo "PASS"

# 4. AGENTS.md exists in lead workspace
echo -n "4. AGENTS.md in lead... "
if [ -f "$HOME/.openclaw/workspace-lead/AGENTS.md" ]; then
    echo "PASS"
else
    echo "FAIL: Missing AGENTS.md"
    ERRORS=$((ERRORS+1))
fi

# 5. Global skills directory exists
echo -n "5. Global skills directory... "
if [ -d "$HOME/.openclaw/skills" ]; then
    echo "PASS ($(ls "$HOME/.openclaw/skills" | wc -l | tr -d ' ') skills installed)"
else
    echo "FAIL: Missing skills directory"
    ERRORS=$((ERRORS+1))
fi

# 6. Required environment variables
echo -n "6. Environment variables... "
REQUIRED_VARS="VOLCENGINE_API_KEY MOONSHOT_API_KEY DECODO_AUTH_TOKEN BRAVE_API_KEY"
for var in $REQUIRED_VARS; do
    if [ -z "${!var}" ]; then
        echo "WARN: $var not set"
    fi
done
echo "CHECKED"

# 7. Cron prompt files exist
echo -n "7. Cron prompt files... "
CRON_FILES=(
    "$HOME/.openclaw/workspace-voc/templates/prompt_templates/price_monitor.md"
    "$HOME/.openclaw/workspace-voc/templates/prompt_templates/weekly_digest.md"
    "$HOME/.openclaw/workspace-voc/templates/prompt_templates/weekly_market_scan.md"
    "$HOME/.openclaw/workspace-reddit/data/monitoring/shadowban-check-prompt.md"
    "$HOME/.openclaw/workspace-reddit/data/nurturing/sop-compliance-prompt.md"
)
for f in "${CRON_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "WARN: Missing cron prompt: $f"
    fi
done
echo "CHECKED"

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "=== ALL CHECKS PASSED ==="
    echo "Run: openclaw gateway restart"
else
    echo "=== $ERRORS ERRORS FOUND ==="
    echo "Fix errors before starting the gateway."
fi
```

### 10.3 Common Config Errors and Fixes

| Error | Symptom | Fix |
|-------|---------|-----|
| Missing comma in JSON | `openclaw gateway restart` fails with parse error | Run `python3 -c "import json; json.load(open('openclaw.json'))"` to find the line |
| Agent workspace path wrong | Agent starts but can't find SOUL.md | Verify `~/.openclaw/workspace-{name}/SOUL.md` exists |
| Feishu appSecret is placeholder | Bot connects but Feishu returns 403 | Replace `REPLACE_WITH_ACTUAL_SECRET` with real credentials from Feishu console |
| Missing `default: true` on lead | Messages arrive but no agent handles them | Add `"default": true` to the lead agent entry |
| agentToAgent not enabled | sessions_send calls fail silently | Verify `tools.agentToAgent.enabled = true` |
| Agent not in `allow` list | sessions_send returns permission error | Add the agent ID to `tools.agentToAgent.allow` array |
| Routing mismatch | Agent A can't reach Agent B | Check `tools.agentToAgent.routing` -- does A's list include B? |
| Cron promptFile missing | Cron fires but agent has no task | Create the prompt template file at the path specified in cron config |
| Feishu WebSocket timeout | Bot disconnects every 30 minutes | Check Feishu app permissions: "Long Connection" must be enabled in app settings |
| Wrong timezone in cron | Jobs fire at unexpected times | Use `"timezone": "Asia/Shanghai"` for UTC+8 Beijing time |

### 10.4 Startup Sequence

The OpenClaw gateway initializes in this order:

```
1. Parse openclaw.json
   ├── Validate JSON syntax
   ├── Load agent definitions
   └── Register model endpoints

2. Initialize agent workspaces
   ├── For each agent in agents.list:
   │   ├── Verify workspace directory exists
   │   ├── Load SOUL.md into agent context
   │   ├── Load AGENTS.md if present (lead only)
   │   ├── Scan workspace skills/ directory
   │   └── Initialize model connection (volcengine or moonshot)
   └── Report agent readiness

3. Load global skills
   ├── Scan ~/.openclaw/skills/ directory
   ├── Register each skill with all agents
   └── Verify skill dependencies (API keys, runtimes)

4. Connect Feishu channels
   ├── For each account in channels.feishu.accounts:
   │   ├── Authenticate with appId + appSecret
   │   ├── Establish WebSocket connection
   │   └── Register message handler
   └── Report channel status

5. Apply bindings
   ├── Map each binding's accountId to its agentId
   └── Set up message routing pipeline

6. Enable agent-to-agent communication
   ├── Register sessions_send handlers
   ├── Apply routing whitelist
   └── Verify all agents in allow list are reachable

7. Schedule cron jobs
   ├── For each job in cron.jobs:
   │   ├── Parse cron expression with timezone
   │   ├── Verify promptFile exists
   │   └── Register with scheduler
   └── Report next execution times

8. Gateway ready
   └── "OpenClaw gateway started. 5 agents online. 5 Feishu channels connected."
```

### 10.5 Health Check After Startup

```bash
# Quick health check: Ask Lead to ping all agents
# In Feishu, send: @openclaw-lead check all agent status

# Expected response:
# +-------------------+--------+------------+---------+
# | Agent             | Status | Session ID | Model   |
# +-------------------+--------+------------+---------+
# | lead              | online | xxxxx      | doubao  |
# | voc-analyst       | online | xxxxx      | kimi    |
# | geo-optimizer     | online | xxxxx      | doubao  |
# | reddit-spec       | online | xxxxx      | kimi    |
# | tiktok-director   | online | xxxxx      | doubao  |
# +-------------------+--------+------------+---------+
# 5/5 agents online. System ready.
```

---

## Appendix A: Changes From Current openclaw.json

The current `~/.openclaw/openclaw.json` is already mostly correct. Here is a diff of recommended changes:

### Add to `agents.list[0]` (lead):
```json
"default": true,
```

### Add to `agents`:
```json
"defaultAgent": "lead",
```

### Add to `channels.feishu`:
```json
"dmPolicy": "open",
```

### Add to `channels.feishu.accounts`:
```json
"voc": { "appId": "cli_voc_placeholder", "appSecret": "REPLACE_WITH_ACTUAL_SECRET" },
```

### Add to `bindings[]`:
```json
{ "agentId": "voc-analyst", "match": { "channel": "feishu", "accountId": "voc" }, "priority": 2 }
```

### Add `priority` to all existing bindings.

### Add to `cron.jobs[]`:
```json
{
  "id": "weekly-market-scan",
  "schedule": "0 2 * * 1",
  "timezone": "Asia/Shanghai",
  "agent": "voc-analyst",
  "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/weekly_market_scan.md",
  "description": "Monday 02:00 AM broad market scan for trending categories and emerging competitors"
},
{
  "id": "reddit-sop-compliance",
  "schedule": "0 9 * * 5",
  "timezone": "Asia/Shanghai",
  "agent": "reddit-spec",
  "promptFile": "~/.openclaw/workspace-reddit/data/nurturing/sop-compliance-prompt.md",
  "description": "Friday 09:00 AM weekly SOP compliance audit for all Reddit accounts"
}
```

---

## Appendix B: Feishu App Setup Checklist (Per App)

Repeat these steps 5 times (once per agent):

1. Go to Feishu Open Platform (open.feishu.cn)
2. Create Application > Enterprise Self-Built App
3. Name: `openclaw-{agent-short-name}` (e.g., `openclaw-lead`)
4. Under Capabilities:
   - Enable "Bot" capability
   - Enable "Long Connection" (for WebSocket mode)
5. Under Permissions:
   - `im:message` (send and receive messages)
   - `im:message.group_at_msg` (receive @-mentions in groups)
   - `im:message.p2p_msg` (receive DMs, if dmPolicy=open)
   - `im:resource` (send images/files)
6. Copy App ID and App Secret into `openclaw.json`
7. Create Version > Submit for Review > Publish
8. Add the bot to your Feishu group

**Critical**: Changes to Feishu app permissions require creating a new version and publishing it. Simply saving permissions does NOT make them effective.

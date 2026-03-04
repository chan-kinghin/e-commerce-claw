# 方案：openclaw.json 主配置

**范围**: 完整的生产级配置，将全部 5 个 Agent、飞书通道、Cron 定时任务、Skill 和 Agent 间通信串联起来。

**状态**: Complete

---

## 1. 完整的 openclaw.json（生产级）

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

### 与当前配置的主要差异

| 项目 | 当前配置 | 生产配置 |
|------|---------|---------|
| `defaultAgent` 字段 | 缺失 | 新增 `"defaultAgent": "lead"` |
| lead 的 `default: true` | 缺失 | 已添加到 lead Agent 条目 |
| `dmPolicy` | 缺失 | 新增 `"open"` 到飞书通道 |
| VOC 飞书账号 | 缺失 | 新增 `"voc"` 账号（含占位凭证） |
| VOC 飞书绑定 | 缺失 | 新增 voc-analyst 到 "voc" accountId 的绑定 |
| 绑定优先级 | 缺失 | 所有绑定均添加了 `"priority"` 字段 |
| Cron: weekly-market-scan | 缺失 | 新增每周一 02:00 AM 的广域市场扫描 |
| Cron: reddit-sop-compliance | 缺失 | 新增每周五 09:00 AM 的 SOP 合规审计 |

---

## 2. Agent 定义详解

### 2.1 Lead（调度中枢）

| 属性 | 值 |
|------|---|
| **Agent ID** | `lead` |
| **模型** | `volcengine/doubao-seed-2.0-code` |
| **工作区** | `~/.openclaw/workspace-lead/` |
| **角色** | `orchestrator` |
| **默认 Agent** | `true`（唯一标记为默认的 Agent） |
| **Temperature** | 0.4（较低值以确保可靠的任务拆解） |
| **Max Tokens** | 8192 |
| **可通信对象** | 全部 4 个专业 Agent |
| **接收通信来源** | 全部 4 个专业 Agent（返回结果） |

**选用 doubao-seed-2.0-code 的理由**: 调度中枢需要顶级推理能力来完成多步骤任务拆解、DAG 规划和结果汇总。它还需要理解跨领域上下文（判断 VOC 数据应路由给 GEO、TikTok 还是 Reddit）。

**关键文件**:
- `SOUL.md` -- 调度中枢的人格设定和委派规则
- `AGENTS.md` -- 团队名录，含每个 Agent 的能力和 sessions_send 地址

### 2.2 VOC 分析师

| 属性 | 值 |
|------|---|
| **Agent ID** | `voc-analyst` |
| **模型** | `moonshot/kimi-k2.5` |
| **工作区** | `~/.openclaw/workspace-voc/` |
| **角色** | `executor` |
| **默认 Agent** | `false` |
| **Temperature** | 0.3（最低——确保一致的结构化 JSON 输出） |
| **Max Tokens** | 8192（报告可能较大） |
| **可通信对象** | 仅 Lead |
| **接收任务来源** | 仅 Lead |

**选用 Kimi K2.5 的理由**: VOC 任务属于执行密集型（数据抓取、清洗、格式化）。低温度确保确定性的结构化输出。相比决策层模型，成本节省约 90%。关键能力是工具调用的可靠性，而非创意推理。

### 2.3 GEO 优化师

| 属性 | 值 |
|------|---|
| **Agent ID** | `geo-optimizer` |
| **模型** | `volcengine/doubao-seed-2.0-code` |
| **工作区** | `~/.openclaw/workspace-geo/` |
| **角色** | `executor` |
| **默认 Agent** | `false` |
| **Temperature** | 0.7（较高值以产生自然的写作变化） |
| **Max Tokens** | 8192（博客文章可能 2000+ 词） |
| **可通信对象** | 仅 Lead |
| **接收任务来源** | 仅 Lead |

**选用 doubao-seed-2.0-code 的理由**: GEO 内容需要深入理解 LLM 如何提取事实。该 Agent 必须编写既数据密集又自然可读的内容。使用 GEO 规则引擎（4 大类 22 条规则）进行自评估需要顶级推理能力。

### 2.4 Reddit 专员

| 属性 | 值 |
|------|---|
| **Agent ID** | `reddit-spec` |
| **模型** | `moonshot/kimi-k2.5` |
| **工作区** | `~/.openclaw/workspace-reddit/` |
| **角色** | `executor` |
| **默认 Agent** | `false` |
| **Temperature** | 0.7（较高值以撰写自然、非机器人化的评论） |
| **Max Tokens** | 4096（评论较短，100-250 词） |
| **可通信对象** | 仅 Lead |
| **接收任务来源** | 仅 Lead |

**选用 Kimi K2.5 的理由**: Reddit 评论生成属于执行层工作。较高的温度弥补了模型层级的差异——评论需要给人真实感，而非公式化。4096 token 限制对短评论来说已足够。账号管理和 SOP 合规是程序化任务，适合该模型层级。

### 2.5 TikTok 导演

| 属性 | 值 |
|------|---|
| **Agent ID** | `tiktok-director` |
| **模型** | `volcengine/doubao-seed-2.0-code` |
| **工作区** | `~/.openclaw/workspace-tiktok/` |
| **角色** | `executor` |
| **默认 Agent** | `false` |
| **Temperature** | 0.7（用于创意分镜生成） |
| **Max Tokens** | 4096 |
| **可通信对象** | 仅 Lead |
| **接收任务来源** | 仅 Lead |

**选用 doubao-seed-2.0-code 的理由**: TikTok 导演需要多模态理解能力（VLM）来通过 volcengine-video-understanding 进行视频质检。它还需要强大的推理能力来设计 25 宫格分镜脚本，将痛点映射到运镜、节奏和情感节拍。使用 nano-banana-pro 和 Seedance 进行创意 Prompt 构建需要顶级模型。

---

## 3. 飞书通道配置

### 3.1 五个飞书应用配置

每个 Agent 拥有独立的飞书应用。即在飞书开放平台控制台中创建 5 个独立应用。

| 账号 Key | 飞书应用名 | 绑定的 Agent | 用途 |
|---------|-----------|-------------|------|
| `lead` | openclaw-lead | `lead` | 主要人机接口。用户 @此机器人来触发任务。 |
| `voc` | openclaw-voc | `voc-analyst` | VOC 分析师的直接飞书访问（可选，主要用于状态可见性）。 |
| `geo` | openclaw-geo | `geo-optimizer` | 用于内容审核和批准的直接访问。 |
| `reddit` | openclaw-reddit | `reddit-spec` | 状态更新和告警（影子封禁通知、周报）。 |
| `tiktok` | openclaw-tiktok | `tiktok-director` | 视频交付和质检审核升级。 |

### 3.2 WebSocket 与 Webhook 对比

| 模式 | WebSocket | Webhook |
|------|-----------|---------|
| **连接方式** | 持久双向连接 | 每个事件发送 HTTP POST |
| **延迟** | 低（约 100ms） | 中等（约 500ms-2s） |
| **可靠性** | 需要稳定进程 | 对重启更有弹性 |
| **防火墙** | 仅需出站连接（无需公网 IP） | 需要公网端点 |
| **建议** | **选用此项**——适合 Mac mini 本地部署 | 适合云端部署 |

**决策**: `"connectionMode": "websocket"` -- 由于运行在局域网内的 Mac mini 上，WebSocket 是正确选择。它避免了为 Webhook 回调暴露公网 HTTP 端点的需要。

### 3.3 dmPolicy 说明

```json
"dmPolicy": "open"
```

| 策略 | 行为 |
|------|------|
| `"open"` | 任何飞书用户都可以私聊机器人并触发 Agent 响应 |
| `"restricted"` | 仅获批准的群组/联系人中的用户可以交互 |
| `"disabled"` | 机器人仅在群聊中响应，不响应私聊 |

**已选**: `"open"` -- 初始部署阶段，所有团队成员应能自由交互。如需访问控制，生产环境可切换为 `"restricted"`。

### 3.4 账号命名规范

- `channels.feishu.accounts` 中的账号 key 使用简短小写标识符：`lead`、`voc`、`geo`、`reddit`、`tiktok`
- 这些 key 在 `bindings[].match.accountId` 中被引用
- 飞书应用名使用 `openclaw-{agent-short-name}` 模式以保持一致性

### 3.5 为什么 VOC 分析师也需要飞书绑定

**之前的方案**: 最初的博客文章中仅展示了 4 个飞书账号（lead、geo、reddit、tiktok），VOC 仅通过 sessions_send 接收任务。

**更新后的方案**: VOC 分析师现在拥有自己的飞书绑定，原因有二：
1. **状态可见性**: Lead 可以在飞书群中发布 VOC 分析进度卡片，让人类可见
2. **直接查询**: 高级用户可能希望直接向 VOC 发起快速市场查询，而不经过 Lead
3. **Cron 告警**: 价格监控告警可以直接通过 VOC 的飞书应用推送

这是可选的——如果你希望保持 VOC 严格作为后端服务，可以从 `channels.feishu.accounts` 中移除 `voc` 条目及其对应的绑定。

---

## 4. 绑定数组

### 4.1 绑定到 Agent 的映射

```json
"bindings": [
  { "agentId": "lead",            "match": { "channel": "feishu", "accountId": "lead" },   "priority": 1 },
  { "agentId": "voc-analyst",     "match": { "channel": "feishu", "accountId": "voc" },    "priority": 2 },
  { "agentId": "geo-optimizer",   "match": { "channel": "feishu", "accountId": "geo" },    "priority": 2 },
  { "agentId": "reddit-spec",     "match": { "channel": "feishu", "accountId": "reddit" }, "priority": 2 },
  { "agentId": "tiktok-director", "match": { "channel": "feishu", "accountId": "tiktok" }, "priority": 2 }
]
```

### 4.2 路由工作原理

当飞书消息到达时，OpenClaw 按优先级顺序评估绑定数组：

1. **按 accountId 匹配**: 绑定中的 `accountId` 必须与接收消息的飞书应用匹配
2. **路由到 agentId**: 匹配绑定的 `agentId` 决定由哪个 Agent 处理消息
3. **优先级**: 数字越小优先级越高。如果多个绑定可能匹配（使用不同账号时不太可能），优先级最高的绑定生效

### 4.3 优先级设置理由

- **Lead 优先级为 1**: 如果存在任何路由歧义，Lead 应作为兜底处理器。Lead 是指定的人机接口，必要时可以重新路由。
- **所有专业 Agent 优先级为 2**: 专业 Agent 之间优先级相同，因为它们各自拥有唯一的 accountId——不存在歧义。

### 4.4 VOC 分析师绑定的考量

VOC 分析师的绑定已包含但属于可选项。正反两面的论证：

| 支持绑定 | 反对绑定 |
|---------|---------|
| 允许人类直接向 VOC 发起查询 | VOC 应只从 Lead 接收任务（纪律性） |
| 价格监控告警可使用自己的飞书身份 | 增加复杂度——多管理一个飞书应用 |
| 状态卡片能显示哪个 Agent 在工作 | Lead 可代表 VOC 向飞书转发状态 |

**建议**: 保留绑定。多一个飞书应用的管理开销极小，而可见性方面的收益对调试和监控很有价值。

---

## 5. Agent 间通信矩阵

### 5.1 通信权限

| 发送方 \ 接收方 | lead | voc-analyst | geo-optimizer | reddit-spec | tiktok-director |
|---------------|:----:|:-----------:|:-------------:|:-----------:|:---------------:|
| **lead** | -- | SEND | SEND | SEND | SEND |
| **voc-analyst** | REPLY | -- | -- | -- | -- |
| **geo-optimizer** | REPLY | -- | -- | -- | -- |
| **reddit-spec** | REPLY | -- | -- | -- | -- |
| **tiktok-director** | REPLY | -- | -- | -- | -- |

### 5.2 配置中的路由规则

```json
"routing": {
  "lead":            ["voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"],
  "voc-analyst":     ["lead"],
  "geo-optimizer":   ["lead"],
  "reddit-spec":     ["lead"],
  "tiktok-director": ["lead"]
}
```

### 5.3 为什么采用星型拓扑

1. **Lead 可以发送给所有 Agent**: Lead 是调度中枢。它将用户请求拆解为子任务，并通过 `sessions_send` 分发给对应的专业 Agent。它必须能触达每个 Agent。

2. **专业 Agent 只能回复 Lead**: 专业 Agent 之间从不直接通信。所有跨 Agent 数据流均通过 Lead 中转。这样可以防止：
   - **循环依赖**: VOC 发给 GEO，GEO 发给 Reddit，Reddit 又发回 VOC——死锁
   - **上下文混乱**: 如果 GEO 能直接查询 VOC，Lead 和 GEO 可能同时发送冲突请求
   - **审计轨迹丢失**: Lead 记录所有分发和响应，确保完整的任务可追溯性

3. **为什么不用对等网络（全网状）？**: 在全网状拓扑中，任何 Agent 都能与其他任何 Agent 通信。这会带来协调噩梦：
   - 谁来解决冲突请求？
   - 当 5 个 Agent 同时互相通信时如何调试？
   - 星型拓扑更简单、更易调试，且足以满足我们的工作流需求

### 5.4 安全考量

- **API Key 隔离**: 每个 Agent 只能访问其工作区中加载的 Skill 和 API Key。VOC 无法访问 Reddit 的账号凭证，Reddit 也无法访问 VOC 的 Decodo API token。
- **工作区隔离**: sessions_send 载荷是唯一的跨 Agent 数据通道。Agent 无法读取其他 Agent 的工作区文件。
- **禁止凭证转发**: Agent 在 sessions_send 消息中绝不能包含 API Key、token 或凭证。
- **Lead 作为守门人**: 由于所有 Agent 间通信都经过 Lead，Lead 可以验证、过滤和记录所有数据交换。

---

## 6. Cron 定时任务定义

### 6.1 价格监控——每日 03:00 AM UTC+8

```json
{
  "id": "price-monitor",
  "schedule": "0 3 * * *",
  "timezone": "Asia/Shanghai",
  "agent": "voc-analyst",
  "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/price_monitor.md"
}
```

| 属性 | 值 |
|------|---|
| **Agent** | voc-analyst |
| **时间表** | 每天北京时间 03:00 AM |
| **为什么选 03:00 AM** | 大多数美国亚马逊卖家在夜间调价。北京时间 03:00 AM = 美东时间前一天下午 3:00 / 美西时间前一天中午 12:00，能捕获美国下午的价格变动。 |
| **执行内容** | (1) 从 `data/price_memory.txt` 加载跟踪的 ASIN，(2) 通过 Playwright/web_fetch 抓取当前价格，(3) 与昨天的快照对比，(4) 如检测到变动，推送 webhook 告警到飞书，(5) 更新 `price_memory.txt` 并追加到 `price_history/` |
| **输出** | 告警 JSON 推送到飞书 webhook（如有变动）、更新的价格快照、历史文件 |
| **成本** | 50 个跟踪 ASIN 约 $0.10-0.15/天 |

### 6.2 每周趋势摘要——周日 04:00 AM UTC+8

```json
{
  "id": "weekly-trend-digest",
  "schedule": "0 4 * * 0",
  "timezone": "Asia/Shanghai",
  "agent": "voc-analyst",
  "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/weekly_digest.md"
}
```

| 属性 | 值 |
|------|---|
| **Agent** | voc-analyst |
| **时间表** | 每周日 04:00 AM（价格监控后 1 小时） |
| **执行内容** | (1) 读取 `price_history/` 中的 7 天每日快照，(2) 计算每个 ASIN 的 7 天价格趋势（最低、最高、平均、方向），(3) 计算 BSR 排名变动，(4) 衡量评论增速，(5) 生成每周趋势摘要报告，(6) 通过 sessions_send 发送给 Lead |
| **输出** | 每周趋势摘要报告（JSON + Markdown），转发给 Lead 通过飞书分发 |

### 6.3 影子封禁检测——周一 10:00 AM UTC+8

```json
{
  "id": "shadowban-check",
  "schedule": "0 10 * * 1",
  "timezone": "Asia/Shanghai",
  "agent": "reddit-spec",
  "promptFile": "~/.openclaw/workspace-reddit/data/monitoring/shadowban-check-prompt.md"
}
```

| 属性 | 值 |
|------|---|
| **Agent** | reddit-spec |
| **时间表** | 每周一 10:00 AM |
| **执行内容** | (1) 从 `account-registry.json` 加载所有活跃账号，(2) 对每个账号通过未登录请求（Playwright 或 reddit-readonly）检查个人资料可见性，(3) 主方法失败时使用备用方法确认，(4) 更新 `shadowban-checks.jsonl`，(5) 如检测到影子封禁，触发 14 天冷静期并通知 Lead |
| **输出** | 更新的影子封禁检测结果，如有账号被封禁则向 Lead 发出告警 |

### 6.4 每周市场扫描——周一 02:00 AM UTC+8

```json
{
  "id": "weekly-market-scan",
  "schedule": "0 2 * * 1",
  "timezone": "Asia/Shanghai",
  "agent": "voc-analyst",
  "promptFile": "~/.openclaw/workspace-voc/templates/prompt_templates/weekly_market_scan.md"
}
```

| 属性 | 值 |
|------|---|
| **Agent** | voc-analyst |
| **时间表** | 每周一 02:00 AM |
| **执行内容** | (1) 扫描跟踪类目中的 Amazon BSR 异动，(2) 通过 Brave/Tavily 搜索热门产品关键词，(3) 在目标子版块中检查 Reddit 上的新兴痛点，(4) 生成市场情报简报，(5) 发送给 Lead |
| **输出** | 市场扫描报告，含热门类目、新兴竞品和机会信号 |

### 6.5 Reddit SOP 合规审计——周五 09:00 AM UTC+8

```json
{
  "id": "reddit-sop-compliance",
  "schedule": "0 9 * * 5",
  "timezone": "Asia/Shanghai",
  "agent": "reddit-spec",
  "promptFile": "~/.openclaw/workspace-reddit/data/nurturing/sop-compliance-prompt.md"
}
```

| 属性 | 值 |
|------|---|
| **Agent** | reddit-spec |
| **时间表** | 每周五 09:00 AM |
| **执行内容** | (1) 从 `sop-progress.json` 加载所有账号的 SOP 进度，(2) 根据活动日志检查 W1-W5 合规规则，(3) 验证推广帖与有机帖的比例，(4) 生成每周 SOP 合规报告，(5) 发送给 Lead |
| **输出** | 按账号的 SOP 合规报告，保存到 `weekly-reports/` |

---

## 7. Skill 配置

### 7.1 全局 Skill（`~/.openclaw/skills/`）

安装在此处的 Skill 对所有 Agent 可用。适用于共享的跨 Agent 能力。

| Skill | 使用者 | 安装来源 | 是否需要 API Key |
|-------|--------|---------|:---------------:|
| `nano-banana-pro` | tiktok-director, geo-optimizer | `clawhub install nano-banana-pro --global` | Google API key |
| `seedance-video` (canghe-seedance-video) | tiktok-director | `clawhub install canghe-seedance-video --global` | Volcengine API (Coding Plan) |
| `canghe-image-gen` | tiktok-director | `clawhub install canghe-image-gen --global` | Google API / 第三方 |
| `reddit-readonly` | voc-analyst, reddit-spec | `curl https://lobehub.com/skills/...` | 无 |
| `brave-search` | voc-analyst, geo-optimizer, reddit-spec | `clawhub install brave-search --global` | `BRAVE_API_KEY` |
| `tavily` | voc-analyst, geo-optimizer | `clawhub install tavily --global` | `TAVILY_API_KEY` |
| `exa` | voc-analyst, geo-optimizer | `clawhub install exa --global` | `EXA_API_KEY` |
| `decodo` | voc-analyst, reddit-spec | `clawhub install decodo --global` | `DECODO_AUTH_TOKEN` |
| `firecrawl` | voc-analyst, geo-optimizer | `clawhub install firecrawl --global` | `FIRECRAWL_API_KEY` |
| `playwright-npx` | voc-analyst, geo-optimizer, reddit-spec | `clawhub install playwright-npx --global` | 无 |
| `apify` | voc-analyst | `clawhub install apify --global` | `APIFY_TOKEN` |

### 7.2 Agent 专属 Skill

安装在 Agent 工作区 `skills/` 目录中的 Skill 仅对该 Agent 可用。

**workspace-tiktok/skills/**:

| Skill | 用途 | 安装命令 |
|-------|------|---------|
| `manga-style-video` | 8 种漫画风格预设及专业提示词 | `clawhub install manga-style-video --workspace workspace-tiktok` |
| `manga-drama` | 单图到多场景短剧流水线 | `clawhub install manga-drama --workspace workspace-tiktok` |
| `volcengine-video-understanding` | 视频质检、场景识别、质量评分 | `clawhub install volcengine-video-understanding --workspace workspace-tiktok` |

**workspace-reddit/skills/**:

| Skill | 用途 | 安装命令 |
|-------|------|---------|
| `reddit-poster`（私有） | 账号专属的 Reddit 发帖功能（如可用） | 手动安装到工作区 |

**workspace-voc/skills/**:

| Skill | 用途 | 安装命令 |
|-------|------|---------|
| `agent-reach` | yt-dlp、xreach (Twitter)、Jina Reader | `clawhub install agent-reach --workspace workspace-voc` |

**workspace-lead/skills/**:

| Skill | 用途 | 安装命令 |
|-------|------|---------|
| （无 Agent 专属 Skill） | Lead 仅使用 sessions_send 和全局 Skill | -- |

**workspace-geo/skills/**:

| Skill | 用途 | 安装命令 |
|-------|------|---------|
| （无 Agent 专属 Skill） | GEO 使用全局搜索和网页提取 Skill | -- |

### 7.3 加载优先级规则

```
1. Agent 工作区 skills/ 目录  （最高优先级——覆盖全局）
2. 全局 ~/.openclaw/skills/ 目录  （兜底）
```

**为什么这很重要**:
- 如果 `manga-style-video` 同时存在于全局和 workspace-tiktok 中，工作区版本优先
- 这允许 Agent 进行特定定制而不影响其他 Agent
- 防止"工具幻觉"——Agent 不会意外调用其他 Agent 的私有 Skill
- API Key 隔离——私有 Skill 可使用与全局版本不同的 API Key

### 7.4 防止工具幻觉

工具幻觉是指模型从训练数据中"记住"了实际未安装的 Skill。缓解措施：

1. **工作区隔离**: 每个 Agent 只能看到自己工作区 + 全局的 Skill。它看不到其他工作区。
2. **SOUL.md 工具列表**: 每个 Agent 的 SOUL.md 明确列出应使用的工具及优先顺序。未列出的工具应视为不可用。
3. **Skill 验证**: 调用 Skill 前，Agent 应验证其是否存在。如果 Skill 调用失败，记录错误而非使用伪造参数重试。

---

## 8. 环境变量清单

### 8.1 必需变量

| 变量 | 使用者 | 获取位置 | 示例值 |
|------|--------|---------|--------|
| `VOLCENGINE_API_KEY` | lead, geo-optimizer, tiktok-director | 火山引擎控制台（字节跳动） | `vol_xxxxxxxxxxxx` |
| `VOLCENGINE_MODEL_ENDPOINT` | lead, geo-optimizer, tiktok-director | 火山引擎模型部署页面 | `https://ark.cn-beijing.volces.com/api/v3` |
| `MOONSHOT_API_KEY` | voc-analyst, reddit-spec | Moonshot AI 控制台（Kimi） | `sk-xxxxxxxxxxxxxxxxxx` |
| `DECODO_AUTH_TOKEN` | voc-analyst, reddit-spec | Decodo 仪表盘 | `VTAwMDAz...` |
| `BRAVE_API_KEY` | voc-analyst, geo-optimizer, reddit-spec | Brave Search API 控制台 | `BSAl2YP5...` |
| `APIFY_TOKEN` | voc-analyst | Apify 控制台 | `apify_api_5kIYzp...` |

### 8.2 飞书应用凭证（5 个应用）

| 变量 | 应用 | 获取位置 |
|------|------|---------|
| `FEISHU_LEAD_APP_ID` | Lead 机器人 | 飞书开放平台 > 应用 > 凭证 |
| `FEISHU_LEAD_APP_SECRET` | Lead 机器人 | 同页面 |
| `FEISHU_VOC_APP_ID` | VOC 机器人 | 同流程，不同应用 |
| `FEISHU_VOC_APP_SECRET` | VOC 机器人 | 同页面 |
| `FEISHU_GEO_APP_ID` | GEO 机器人 | 同流程 |
| `FEISHU_GEO_APP_SECRET` | GEO 机器人 | 同页面 |
| `FEISHU_REDDIT_APP_ID` | Reddit 机器人 | 同流程 |
| `FEISHU_REDDIT_APP_SECRET` | Reddit 机器人 | 同页面 |
| `FEISHU_TIKTOK_APP_ID` | TikTok 机器人 | 同流程 |
| `FEISHU_TIKTOK_APP_SECRET` | TikTok 机器人 | 同页面 |

### 8.3 可选增强变量

| 变量 | 使用者 | 获取位置 | 示例值 |
|------|--------|---------|--------|
| `TAVILY_API_KEY` | voc-analyst, geo-optimizer | Tavily.com | `tvly-...` |
| `EXA_API_KEY` | voc-analyst, geo-optimizer | Exa.ai | `exa-...` |
| `FIRECRAWL_API_KEY` | voc-analyst, geo-optimizer | Firecrawl.dev | `fc-...` |
| `FEISHU_WEBHOOK_URL` | voc-analyst（价格告警） | 飞书群 > 添加机器人 > 自定义机器人 | `https://open.feishu.cn/open-apis/bot/v2/hook/xxxx` |
| `TELEGRAM_BOT_TOKEN` | voc-analyst（价格告警） | Telegram BotFather | `123456:ABC-DEF...` |
| `TELEGRAM_CHAT_ID` | voc-analyst（价格告警） | Telegram 群组/频道 ID | `-100123456789` |

### 8.4 Reddit 账号变量（按账号）

| 变量 | 用途 | 示例 |
|------|------|------|
| `REDDIT_ACC_001_TOKEN` | 账号 acc-001 的 OAuth token | `eyJhbGciOiJSUz...` |
| `REDDIT_ACC_001_SECRET` | OAuth client secret | `xxxxxxxxxxx` |
| `REDDIT_ACC_002_TOKEN` | 账号 acc-002 的 OAuth token | `eyJhbGciOiJSUz...` |
| `REDDIT_ACC_002_SECRET` | OAuth client secret | `xxxxxxxxxxx` |

### 8.5 设置环境变量

```bash
# 创建 .env 文件（切勿提交此文件）
cat > ~/.openclaw/.env << 'EOF'
# === 模型 API Key ===
VOLCENGINE_API_KEY=vol_xxxxxxxxxxxx
VOLCENGINE_MODEL_ENDPOINT=https://ark.cn-beijing.volces.com/api/v3
MOONSHOT_API_KEY=sk-xxxxxxxxxxxxxxxxxx

# === 抓取和搜索 ===
DECODO_AUTH_TOKEN=VTAwMDAz...
BRAVE_API_KEY=BSAl2YP5...
APIFY_TOKEN=apify_api_5kIYzp...
TAVILY_API_KEY=tvly-...
EXA_API_KEY=exa-...
FIRECRAWL_API_KEY=fc-...

# === 飞书应用（5 个）===
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

# === Webhook ===
FEISHU_WEBHOOK_URL=https://open.feishu.cn/open-apis/bot/v2/hook/xxxx
TELEGRAM_BOT_TOKEN=123456:ABC-DEF...
TELEGRAM_CHAT_ID=-100123456789

# === Reddit 账号 ===
REDDIT_ACC_001_TOKEN=eyJhbGciOiJSUz...
REDDIT_ACC_001_SECRET=xxxxxxxxxxx
EOF

# 在你的 shell 配置中引用
echo 'source ~/.openclaw/.env' >> ~/.zshrc
```

---

## 9. 目录结构

在执行 `openclaw gateway restart` 之前，`~/.openclaw/` 下必须存在的完整目录树：

```
~/.openclaw/
├── openclaw.json                          # 主配置（本文档第 1 节）
├── .env                                   # 环境变量（切勿提交）
├── skills/                                # 全局共享 Skill
│   ├── nano-banana-pro/                   # 图像生成
│   ├── canghe-seedance-video/             # 视频生成（Seedance 1.5 Pro）
│   ├── canghe-image-gen/                  # 角色图像生成
│   ├── reddit-readonly/                   # 免费 Reddit 数据访问
│   ├── brave-search/                      # Brave Search API
│   ├── tavily/                            # Tavily 搜索（中国直连）
│   ├── exa/                               # Exa 意图搜索
│   ├── decodo/                            # Decodo 抓取（Amazon、Reddit、YouTube）
│   ├── firecrawl/                         # 远程浏览器沙箱
│   ├── playwright-npx/                    # 动态 SPA 抓取
│   └── apify/                             # 工业级云端抓取
│
├── workspace-lead/                        # Lead Agent（调度中枢）
│   ├── SOUL.md                            # 调度中枢身份和规则
│   ├── AGENTS.md                          # 团队名录（全部 4 个专业 Agent）
│   └── skills/                            # （空——Lead 仅使用全局 Skill）
│
├── workspace-voc/                         # VOC 市场分析师
│   ├── SOUL.md                            # VOC 身份和数据规则
│   ├── skills/
│   │   └── agent-reach/                   # yt-dlp、xreach、Jina Reader
│   ├── data/
│   │   ├── reports/                       # 最终分析报告（JSON + MD）
│   │   ├── raw/                           # 每次会话的原始抓取数据
│   │   │   ├── amazon/
│   │   │   ├── reddit/
│   │   │   ├── youtube/
│   │   │   ├── google-maps/
│   │   │   └── tiktok/
│   │   ├── price_memory.txt               # 当前价格快照
│   │   ├── price_history/                 # 每日价格快照
│   │   └── competitor_profiles/           # 跟踪的竞品 ASIN
│   ├── templates/
│   │   ├── report_template.md
│   │   └── prompt_templates/
│   │       ├── cross_validation.md
│   │       ├── pain_point_extraction.md
│   │       ├── price_monitor.md           # Cron: 每日价格检查
│   │       ├── weekly_digest.md           # Cron: 每周趋势报告
│   │       └── weekly_market_scan.md      # Cron: 每周市场扫描
│   └── logs/
│       └── scrape_log.jsonl
│
├── workspace-geo/                         # GEO 内容优化师
│   ├── SOUL.md                            # GEO 身份和内容规则
│   ├── skills/                            # （空——使用全局 Skill）
│   ├── data/
│   │   ├── input/
│   │   │   └── voc-reports/               # 接收的痛点数据
│   │   ├── output/
│   │   │   ├── blogs/                     # GEO 优化后的博客文章（.md）
│   │   │   ├── amazon-listings/           # Amazon listing 包（.json）
│   │   │   └── product-descriptions/      # 产品描述（.html/.md）
│   │   ├── research/
│   │   │   ├── authority-sources/         # 缓存的权威引用
│   │   │   └── competitor-content/        # 竞品内容分析
│   │   ├── templates/
│   │   │   ├── blog-template.md
│   │   │   ├── amazon-listing-template.json
│   │   │   └── product-description-template.md
│   │   └── quality-logs/
│   │       └── score-history.jsonl        # GEO 质量评分日志
│   ├── rules/
│   │   └── geo-rules.md                   # GEO 规则引擎（22 条规则）
│   └── prompts/
│       ├── blog-system-prompt.md
│       ├── amazon-system-prompt.md
│       └── scoring-prompt.md
│
├── workspace-reddit/                      # Reddit 营销专员
│   ├── SOUL.md                            # Reddit 身份和互动规则
│   ├── skills/
│   │   └── reddit-poster/                 # 私有发帖 Skill（如可用）
│   ├── data/
│   │   ├── accounts/
│   │   │   ├── account-registry.json      # 主账号列表
│   │   │   ├── acc-001/                   # 按账号的数据
│   │   │   │   ├── profile.json
│   │   │   │   ├── activity-log.jsonl
│   │   │   │   ├── cooldown-state.json
│   │   │   │   └── assigned-subs.json
│   │   │   └── acc-NNN/
│   │   ├── nurturing/
│   │   │   ├── sop-progress.json          # 每个账号的 W1-W5 进度
│   │   │   ├── weekly-reports/            # SOP 合规报告
│   │   │   ├── karma-snapshots.jsonl      # 每日 karma 跟踪
│   │   │   └── sop-compliance-prompt.md   # Cron: SOP 审计
│   │   ├── hijacking/
│   │   │   ├── target-posts.json          # 高排名旧帖子
│   │   │   ├── comment-drafts/
│   │   │   ├── comment-history.jsonl
│   │   │   └── post-evaluations.jsonl
│   │   ├── content/
│   │   │   ├── subreddit-profiles/        # 6 种语调配置
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
│   │       ├── shadowban-check-prompt.md  # Cron: 每周影子封禁检测
│   │       ├── comment-performance.jsonl
│   │       └── alerts.jsonl
│   └── logs/
│       ├── agent-activity.log
│       └── errors.log
│
├── workspace-tiktok/                      # TikTok 导演
│   ├── SOUL.md                            # TikTok 身份和创意规则
│   ├── skills/
│   │   ├── manga-style-video/             # 8 种漫画风格预设
│   │   ├── manga-drama/                   # 分镜到视频流水线
│   │   └── volcengine-video-understanding/ # 视频质检
│   ├── templates/
│   │   ├── storyboard-25grid.json         # 25 宫格分镜模板
│   │   ├── storyboard-ugc.json            # UGC 视频模板
│   │   ├── storyboard-manga.json          # 漫画短剧模板
│   │   └── camera-notation.md             # 运镜参考手册
│   ├── data/
│   │   ├── projects/                      # 按产品的文件夹
│   │   │   └── {product-slug}/
│   │   │       ├── brief.json
│   │   │       ├── voc-data.json
│   │   │       ├── storyboard.json
│   │   │       ├── images/
│   │   │       ├── videos/
│   │   │       ├── final/
│   │   │       └── qa-report.json
│   │   ├── style-library/                 # 8 种漫画风格指南
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
│   │   ├── videos/                        # 可交付的视频
│   │   ├── thumbnails/                    # A/B 测试缩略图
│   │   └── metadata/                      # 分发元数据
│   └── config/
│       └── model-config.json
│
├── install-skills.sh                      # Skill 安装脚本
└── tests/
    └── validate-config.sh                 # 配置验证脚本
```

---

## 10. 验证与启动清单

### 10.1 验证 openclaw.json 语法

```bash
# 步骤 1：JSON 语法验证
python3 -c "import json; json.load(open('$HOME/.openclaw/openclaw.json')); print('JSON syntax: PASS')"

# 步骤 2：结构验证（检查必需字段）
python3 << 'PYEOF'
import json, sys

with open("$HOME/.openclaw/openclaw.json") as f:
    config = json.load(f)

errors = []

# 检查 agents
if "agents" not in config or "list" not in config["agents"]:
    errors.append("Missing agents.list")
else:
    agent_ids = [a["id"] for a in config["agents"]["list"]]
    required_agents = ["lead", "voc-analyst", "geo-optimizer", "reddit-spec", "tiktok-director"]
    for req in required_agents:
        if req not in agent_ids:
            errors.append(f"Missing agent: {req}")

    # 检查默认 Agent
    defaults = [a for a in config["agents"]["list"] if a.get("default")]
    if len(defaults) != 1:
        errors.append(f"Expected 1 default agent, found {len(defaults)}")
    elif defaults[0]["id"] != "lead":
        errors.append(f"Default agent should be 'lead', found '{defaults[0]['id']}'")

# 检查 channels
if "channels" not in config or "feishu" not in config["channels"]:
    errors.append("Missing channels.feishu")
elif not config["channels"]["feishu"].get("enabled"):
    errors.append("Feishu channel not enabled")

# 检查 bindings
if "bindings" not in config:
    errors.append("Missing bindings array")
else:
    bound_agents = [b["agentId"] for b in config["bindings"]]
    if "lead" not in bound_agents:
        errors.append("Lead agent has no Feishu binding")

# 检查 tools.agentToAgent
if "tools" not in config or "agentToAgent" not in config["tools"]:
    errors.append("Missing tools.agentToAgent")
elif not config["tools"]["agentToAgent"].get("enabled"):
    errors.append("agentToAgent not enabled")

# 检查 cron
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

### 10.2 `openclaw gateway restart` 前的飞行前检查

```bash
#!/bin/bash
# OpenClaw 启动前飞行检查清单

echo "=== OpenClaw Pre-Flight Checks ==="
ERRORS=0

# 1. openclaw.json 存在且为有效 JSON
echo -n "1. Config file syntax... "
if python3 -c "import json; json.load(open('$HOME/.openclaw/openclaw.json'))" 2>/dev/null; then
    echo "PASS"
else
    echo "FAIL: Invalid JSON"
    ERRORS=$((ERRORS+1))
fi

# 2. 所有工作区目录存在
echo -n "2. Workspace directories... "
WORKSPACES="workspace-lead workspace-voc workspace-geo workspace-reddit workspace-tiktok"
for ws in $WORKSPACES; do
    if [ ! -d "$HOME/.openclaw/$ws" ]; then
        echo "FAIL: Missing $ws"
        ERRORS=$((ERRORS+1))
    fi
done
echo "PASS"

# 3. 每个工作区都有 SOUL.md
echo -n "3. SOUL.md files... "
for ws in $WORKSPACES; do
    if [ ! -f "$HOME/.openclaw/$ws/SOUL.md" ]; then
        echo "FAIL: Missing SOUL.md in $ws"
        ERRORS=$((ERRORS+1))
    fi
done
echo "PASS"

# 4. lead 工作区有 AGENTS.md
echo -n "4. AGENTS.md in lead... "
if [ -f "$HOME/.openclaw/workspace-lead/AGENTS.md" ]; then
    echo "PASS"
else
    echo "FAIL: Missing AGENTS.md"
    ERRORS=$((ERRORS+1))
fi

# 5. 全局 skills 目录存在
echo -n "5. Global skills directory... "
if [ -d "$HOME/.openclaw/skills" ]; then
    echo "PASS ($(ls "$HOME/.openclaw/skills" | wc -l | tr -d ' ') skills installed)"
else
    echo "FAIL: Missing skills directory"
    ERRORS=$((ERRORS+1))
fi

# 6. 必需的环境变量
echo -n "6. Environment variables... "
REQUIRED_VARS="VOLCENGINE_API_KEY MOONSHOT_API_KEY DECODO_AUTH_TOKEN BRAVE_API_KEY"
for var in $REQUIRED_VARS; do
    if [ -z "${!var}" ]; then
        echo "WARN: $var not set"
    fi
done
echo "CHECKED"

# 7. Cron 提示词文件存在
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

# 汇总
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "=== ALL CHECKS PASSED ==="
    echo "Run: openclaw gateway restart"
else
    echo "=== $ERRORS ERRORS FOUND ==="
    echo "Fix errors before starting the gateway."
fi
```

### 10.3 常见配置错误及修复

| 错误 | 表现 | 修复方法 |
|------|------|---------|
| JSON 中缺少逗号 | `openclaw gateway restart` 解析报错 | 运行 `python3 -c "import json; json.load(open('openclaw.json'))"` 定位行号 |
| Agent 工作区路径错误 | Agent 启动但找不到 SOUL.md | 确认 `~/.openclaw/workspace-{name}/SOUL.md` 存在 |
| 飞书 appSecret 为占位符 | 机器人连接但飞书返回 403 | 在飞书控制台获取真实凭证替换 `REPLACE_WITH_ACTUAL_SECRET` |
| lead 缺少 `default: true` | 消息到达但没有 Agent 处理 | 在 lead Agent 条目中添加 `"default": true` |
| agentToAgent 未启用 | sessions_send 调用静默失败 | 确认 `tools.agentToAgent.enabled = true` |
| Agent 不在 `allow` 列表中 | sessions_send 返回权限错误 | 将 Agent ID 添加到 `tools.agentToAgent.allow` 数组 |
| 路由不匹配 | Agent A 无法触达 Agent B | 检查 `tools.agentToAgent.routing`——A 的列表中是否包含 B？ |
| Cron promptFile 缺失 | Cron 触发但 Agent 没有任务 | 在 cron 配置指定的路径创建提示词模板文件 |
| 飞书 WebSocket 超时 | 机器人每 30 分钟断开 | 检查飞书应用权限：必须在应用设置中启用"长连接" |
| Cron 时区错误 | 任务在意外时间触发 | 使用 `"timezone": "Asia/Shanghai"` 表示 UTC+8 北京时间 |

### 10.4 启动顺序

OpenClaw 网关按以下顺序初始化：

```
1. 解析 openclaw.json
   ├── 验证 JSON 语法
   ├── 加载 Agent 定义
   └── 注册模型端点

2. 初始化 Agent 工作区
   ├── 对 agents.list 中的每个 Agent：
   │   ├── 验证工作区目录存在
   │   ├── 将 SOUL.md 加载到 Agent 上下文
   │   ├── 加载 AGENTS.md（如存在，仅 lead）
   │   ├── 扫描工作区 skills/ 目录
   │   └── 初始化模型连接（volcengine 或 moonshot）
   └── 报告 Agent 就绪状态

3. 加载全局 Skill
   ├── 扫描 ~/.openclaw/skills/ 目录
   ├── 将每个 Skill 注册给所有 Agent
   └── 验证 Skill 依赖（API Key、运行时）

4. 连接飞书通道
   ├── 对 channels.feishu.accounts 中的每个账号：
   │   ├── 使用 appId + appSecret 认证
   │   ├── 建立 WebSocket 连接
   │   └── 注册消息处理器
   └── 报告通道状态

5. 应用绑定
   ├── 将每个绑定的 accountId 映射到其 agentId
   └── 设置消息路由管道

6. 启用 Agent 间通信
   ├── 注册 sessions_send 处理器
   ├── 应用路由白名单
   └── 验证 allow 列表中的所有 Agent 均可达

7. 调度 Cron 任务
   ├── 对 cron.jobs 中的每个任务：
   │   ├── 解析带时区的 cron 表达式
   │   ├── 验证 promptFile 存在
   │   └── 注册到调度器
   └── 报告下次执行时间

8. 网关就绪
   └── "OpenClaw gateway started. 5 agents online. 5 Feishu channels connected."
```

### 10.5 启动后健康检查

```bash
# 快速健康检查：让 Lead 对所有 Agent 做 ping 测试
# 在飞书中发送：@openclaw-lead check all agent status

# 预期响应：
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

## 附录 A：与当前 openclaw.json 的变更对比

当前 `~/.openclaw/openclaw.json` 已基本正确。以下是建议的变更差异：

### 在 `agents.list[0]`（lead）中添加：
```json
"default": true,
```

### 在 `agents` 中添加：
```json
"defaultAgent": "lead",
```

### 在 `channels.feishu` 中添加：
```json
"dmPolicy": "open",
```

### 在 `channels.feishu.accounts` 中添加：
```json
"voc": { "appId": "cli_voc_placeholder", "appSecret": "REPLACE_WITH_ACTUAL_SECRET" },
```

### 在 `bindings[]` 中添加：
```json
{ "agentId": "voc-analyst", "match": { "channel": "feishu", "accountId": "voc" }, "priority": 2 }
```

### 在所有现有绑定中添加 `priority` 字段。

### 在 `cron.jobs[]` 中添加：
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

## 附录 B：飞书应用设置清单（每个应用重复操作）

以下步骤需要重复 5 次（每个 Agent 一次）：

1. 前往飞书开放平台（open.feishu.cn）
2. 创建应用 > 企业自建应用
3. 名称：`openclaw-{agent-short-name}`（例如 `openclaw-lead`）
4. 在能力配置中：
   - 启用"机器人"能力
   - 启用"长连接"（用于 WebSocket 模式）
5. 在权限管理中：
   - `im:message`（发送和接收消息）
   - `im:message.group_at_msg`（接收群中的 @提及）
   - `im:message.p2p_msg`（接收私聊，如 dmPolicy=open）
   - `im:resource`（发送图片/文件）
6. 将 App ID 和 App Secret 填入 `openclaw.json`
7. 创建版本 > 提交审核 > 发布
8. 将机器人添加到你的飞书群

**重要提示**: 飞书应用权限的变更需要创建新版本并发布。仅保存权限并不会使其生效。

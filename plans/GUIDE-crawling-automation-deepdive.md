# OpenClaw 爬虫与自动化深度解析

> 商业计划书中各项自动化功能在底层的实际工作原理

---

## OpenClaw 爬虫的实际运作方式

OpenClaw 没有内置爬虫。它使用 **Skill** —— 可安装的工具包，赋予 AI Agent 新的能力。以下是运作流程：

```
用户说："搜索 Amazon 上的便携榨汁机"
                    ↓
OpenClaw 将请求路由到 VOC Analyst Agent
                    ↓
Agent 读取 SOUL.md → 知道应使用 Decodo Skill
                    ↓
Agent 调用：amazon_search("portable blender", limit=30)
                    ↓
Decodo Skill → 向 Decodo API 发送请求（由其服务器处理反爬）
                    ↓
返回干净 JSON：[{title, price, rating, ASIN, BSR, reviews}, ...]
                    ↓
Agent 处理数据 → 撰写结构化报告
```

**核心要点**：你永远不需要编写爬虫代码。Skill 处理数据抓取，AI 模型处理逻辑（抓什么、怎么分析、输出什么）。

---

## 三层爬虫架构

### 第一层：结构化 API（最简单、最可靠）

| Skill | 目标平台 | 返回内容 |
|-------|---------|---------|
| Decodo Skill | Amazon、Reddit、YouTube | 干净 JSON —— 无需解析 |
| reddit-readonly | Reddit（免费，无需 API key） | 帖子、评论、搜索结果 |
| Apify Actors | Google Maps、Instagram、TikTok、YouTube（批量） | 结构化 CSV/JSON |
| gh CLI | GitHub 仓库、Issue | 仓库数据、Issue 列表、Star 趋势 |

这些返回干净的结构化数据。无需 HTML 解析，无需 CSS 选择器。有可用时优先使用。

### 第二层：浏览器渲染（用于 JS 重型网站）

| Skill | 使用场景 | 工作原理 |
|-------|---------|---------|
| playwright-npx | 动态 SPA 网站 | AI 编写并运行 Playwright 脚本 |
| stealth-browser | Cloudflare 保护的网站 | 同上但带反检测（User-Agent、WebGL、时区伪装） |
| Firecrawl | 任意网站（远程） | 远程浏览器沙盒，返回干净 Markdown，免费 500 次/月 |

当第一层不覆盖目标网站时使用（如速卖通、自建独立站）。

### 第三层：搜索引擎（用于发现）

| 引擎 | 定位 | 最适合 |
|------|------|--------|
| Tavily | 国内友好，无需信用卡 | 默认搜索，国内使用 |
| Brave Search | 数据质量最佳 | 国际查询，需海外信用卡 |
| Exa | 意图式搜索 | "找到便携榨汁机的真实买家评价" —— 研究类查询 |

用于发现 URL，然后第一/二层进行抓取。把它看作告诉 Agent 去哪里找的"眼睛"。

### 决策树

```
目标有 Decodo/Apify Actor？  → 第一层（结构化 API）
目标使用大量 JavaScript？    → 第二层（playwright-npx）
目标有 Cloudflare？          → 第二层（stealth-browser）
VPS / 低内存？               → 第二层（Firecrawl —— 远程沙盒）
需要先发现 URL？             → 第三层（搜索）→ 然后第一层或第二层
```

---

## 自动化 1：价格监控（定时任务）

最实用的自动化。每天运行，当竞品调价时及时告警。

### 工作原理

```
┌──────────── 每天凌晨 03:00 ────────────┐
│                                         │
│  OpenClaw 定时任务触发 VOC Analyst      │
│  使用预写好的 prompt：                   │
│                                         │
│  "检查这些竞品 URL，与                   │
│   price_memory.txt 对比，有变动则告警"   │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │ 步骤 1：抓取当前价格            │    │
│  │   playwright-npx 或 web_fetch   │    │
│  │   → 访问每个竞品 URL            │    │
│  │   → 从页面提取价格              │    │
│  └──────────┬──────────────────────┘    │
│             ↓                           │
│  ┌─────────────────────────────────┐    │
│  │ 步骤 2：与快照对比              │    │
│  │   读取 price_memory.txt         │    │
│  │   （昨天的价格）                │    │
│  │   逐产品对比差异                │    │
│  └──────────┬──────────────────────┘    │
│             ↓                           │
│  ┌─────────────────────────────────┐    │
│  │ 步骤 3：如有价格变动 →          │    │
│  │   POST webhook 到飞书群         │    │
│  │   包含产品、旧/新价格、变动%    │    │
│  └──────────┬──────────────────────┘    │
│             ↓                           │
│  ┌─────────────────────────────────┐    │
│  │ 步骤 4：更新 price_memory.txt   │    │
│  │   写入今天的快照                │    │
│  └─────────────────────────────────┘    │
│                                         │
└─────────────────────────────────────────┘
```

### 定时任务配置（openclaw.json 中）

```json
{
  "cron": [
    {
      "id": "price-monitor",
      "schedule": "0 3 * * *",
      "agentId": "voc-analyst",
      "prompt": "执行每日价格监控：读取 competitor_urls.txt 中的竞品链接，抓取当前价格，与 price_memory.txt 对比。如有变动，通过 Webhook 推送到飞书。最后更新 price_memory.txt。"
    }
  ]
}
```

### price_memory.txt 格式

```
# Updated: 2026-03-05T03:00:00+08:00
ASIN_B0CX12345 | Portable Blender XYZ | $29.99 | 4.3★ | BSR #45
ASIN_B0CX67890 | Compact Blender ABC  | $24.99 | 4.1★ | BSR #23
ASIN_B0CX11111 | Mini Blender Pro     | $34.99 | 4.5★ | BSR #12
```

### 所需组件

| 组件 | 是否必需？ | 成本 |
|------|-----------|------|
| DECODO_AUTH_TOKEN（用于 Amazon） | 是（若监控 Amazon 价格） | 约 $30/月 |
| playwright-npx（用于任意网站） | Decodo 的替代方案 | 免费（本地 Chromium） |
| 飞书 Webhook URL | 用于告警推送 | 免费 |
| competitor_urls.txt | 你的竞品清单 | 自行创建 |

---

## 自动化 2：多源交叉验证（VOC 工作流）

"杀手级功能" —— 对单个产品抓取 4+ 平台数据并交叉比对。

### 工作原理

```
输入："调研便携榨汁机市场"
                    ↓
    ┌───────────────┼───────────────┐
    ↓               ↓               ↓
┌────────┐    ┌──────────┐    ┌──────────┐
│ Amazon │    │  Reddit  │    │ YouTube  │
│        │    │          │    │          │
│ Decodo │    │ reddit-  │    │ Decodo   │
│ amazon │    │ readonly │    │ youtube  │
│_search │    │          │    │_subtitles│
│        │    │ 搜索     │    │          │
│ 前 50  │    │ r/Juice  │    │ 前 3 个  │
│ 商品   │    │ r/BuyIt  │    │ 评测     │
│ 价格、 │    │ ForLife  │    │ 视频     │
│ 评分   │    │          │    │          │
│ BSR    │    │ 痛点、   │    │ 字幕     │
│        │    │ 投诉     │    │ 文本 →   │
│        │    │          │    │ 提取     │
│        │    │          │    │ 优缺点   │
└───┬────┘    └────┬─────┘    └────┬─────┘
    ↓               ↓               ↓
    └───────────────┼───────────────┘
                    ↓
         ┌──────────────────┐
         │  交叉验证        │
         │                  │
         │ 仅在 3+ 来源     │
         │ 显示正面信号时   │
         │ 推荐"进入市场"  │
         └────────┬─────────┘
                  ↓
         ┌──────────────────┐
         │  输出报告        │
         │                  │
         │ - 痛点           │
         │ - 价格区间       │
         │ - 竞品弱点       │
         │ - 进入判定       │
         └──────────────────┘
```

### 交叉验证逻辑

由 AI 模型（而非代码）做出判断。其 SOUL.md 包含如下规则：

```markdown
## 交叉验证规则
- 仅在 >=3 个数据源显示正面信号时输出"推荐进入"
- 痛点必须在 >=2 个独立来源中出现才算"已确认"
- 价格区间以 Amazon BSR 数据（主要）为准，Reddit 提及验证
- 若 Reddit 对现有产品负面情感 >60% → 机会信号
- 若 YouTube 评测者指出相同投诉 → 高置信度痛点
```

### 触发 Prompt（由 Lead 或定时任务发送）

```
执行多源交叉验证选品调研。目标品类：便携榨汁机。
1. amazon_search 抓前50商品，提取价格带、评分分布、BSR排名
2. reddit-readonly 搜索 r/Juicing r/BuyItForLife，提取买家痛点
3. youtube_subtitles 抓前3评测视频字幕，提炼KOL关注点
4. 四路数据交叉验证，生成结构化选品报告
```

### 所需组件

| 组件 | 是否必需？ | 成本 |
|------|-----------|------|
| DECODO_AUTH_TOKEN | 用于 Amazon + YouTube | 约 $30/月 |
| reddit-readonly Skill | 用于 Reddit | 免费 |
| BRAVE_API_KEY 或 TAVILY_API_KEY | 用于搜索/发现 | 免费至 $5/月 |
| APIFY_TOKEN（可选） | 用于 Google Maps 批发数据 | 免费额度：$5/月 |

---

## 自动化 3：Reddit 账号培育（5 周 SOP）

最细腻的自动化 —— 并非完全自动化。Agent 规划操作，但发布前需人工审核。

### 逐周详解

```
第 1 周：播种
  Agent：订阅 r/BuyItForLife、r/Camping
  Agent：每天浏览，阅读热帖
  人工：无需审核（被动观察阶段）
  Karma 目标：0（仅观察）

第 2 周：互动
  Agent：在热帖下撰写有帮助的评论（不提及产品）
  Agent：针对 50+ 赞的帖子
  人工：发布前审核评论
  Karma 目标：50

第 3 周：建立信誉
  Agent：撰写原创经验分享帖（"我的露营装备之旅"）
  人工：审核并批准发布
  Karma 目标：200

第 4 周：软性种草
  Agent：查找 Google 排名靠前的产品品类旧帖
  Agent：撰写真诚评论，将产品作为解决方案自然提及
  人工：审核语气，批准发布
  Karma 目标：350

第 5 周：持续运营
  Agent：继续互动，回答问题
  Agent：监控评论表现（点赞数、回复数）
  Karma 目标：500+（信誉已建立）
```

### "流量截取"技巧

Agent 使用 Brave/Google 搜索找到在 Google 排名靠前的 Reddit 旧帖：

```
搜索："best camping cot reddit" site:reddit.com

→ 找到一个 r/Camping 中 2 年前的帖子，500 赞
→ 该帖在 Google 搜索"best camping cot"中排名第 3

→ Agent 撰写一条真诚评论：
  "我之前用的旧行军床也塌了，跟你的问题一样。
   后来换了 [产品] —— 承重 450 磅，折叠后只有
   6 英寸厚。用了 8 个月了，很满意。"

→ 评论继承旧帖的 Google 排名
→ 长尾流量持续数月
```

### 帖子评估评分（Agent 用此决定参与还是跳过）

| 标准 | 权重 | 分值范围 |
|------|------|---------|
| Google 排名位置 | 30% | 1-10（越低越好） |
| 帖子年龄（越老 = SEO 权重越高） | 20% | 0-10 |
| 帖子 karma | 15% | 0-10 |
| 评论活跃度（仍在活跃？） | 15% | 0-10 |
| 与产品品类的相关性 | 20% | 0-10 |

评分 >= 7.0 → 参与。评分 < 7.0 → 跳过。

### 所需组件

| 组件 | 是否必需？ | 成本 |
|------|-----------|------|
| reddit-readonly Skill | 用于阅读 Reddit | 免费 |
| Decodo Skill (reddit_post) | 用于结构化 Reddit 数据 | 约 $30/月 |
| BRAVE_API_KEY | 用于查找 Google 高排名帖 | 免费至 $5/月 |
| Reddit 账号凭证 | 用于发布（需人工批准） | 免费 |
| Playwright-npx（可选） | 用于 shadowban 检测 | 免费 |

---

## 自动化 4：TikTok 视频管线

最复杂的自动化 —— 全 AI 生成的产品视频。

### 管线流程

```
VOC 痛点 → 分镜 → 图片 → 视频 → QA
     ↓         ↓        ↓       ↓       ↓
  "承重不够,  25 格    nano-   Seedance  volcengine-
   收纳麻烦"  模板    banana-  2.0 带    video-
                      pro     音频      understanding
```

### 分步详解

```
步骤 1：读取 VOC 数据
  输入：痛点 = ["承重不够", "收纳麻烦"]
  输入：产品 = "行军折叠床，承重 450 磅"

步骤 2：生成 25 格分镜
  第 1-3 格：  HOOK（前 2 秒 —— 呼吸感运镜）
  第 4-8 格：  痛点展示（展现问题）
  第 9-15 格： 产品展示（特写、功能）
  第 16-21 格：场景（产品使用中 —— 露营场景）
  第 22-25 格：CTA（行动号召 —— 购买链接）

步骤 3：生成图片（nano-banana-pro）
  为每一格 → 生成一张高保真图片
  运镜标记：BM（呼吸感运镜）、CU（特写）等

步骤 4：生成视频（Seedance 2.0）
  图片 → 15 秒带旁白音频的视频
  前 2 秒：手持质感，带轻微自然抖动
  第 4 秒：按压床垫特写展示回弹

步骤 5：质量检测（volcengine-video-understanding）
  自动检查：场景转换、音画同步、视觉质量
  评分 >= 7.5/10 → 通过
  评分 < 7.5 → 重新生成问题场景
```

### 8 种漫画风格（manga-drama 变体）

| 风格 | 适合 | 示例产品 |
|------|------|---------|
| japanese（日式治愈系） | 生活方式、美妆 | 护肤品、食品、家居用品 |
| ghibli（吉卜力） | 户外、自然 | 露营装备、环保产品 |
| chinese（国风水墨） | 传统文化 | 茶叶、书法用品、服装 |
| cartoon（美式卡通） | 轻松有趣 | 宠物用品、儿童用品 |
| sketch（铅笔素描） | 科技、极简 | 数码产品、设计品 |
| watercolor（水彩） | 艺术、手工 | 手工艺品、文具、礼品 |
| manga_comic（日式漫画） | 科技、游戏 | 电子产品、游戏配件 |
| chibi（Q 版萌系） | 可爱、俏皮 | 玩具、零食、IP 周边 |

### 所需组件

| 组件 | 是否必需？ | 成本 |
|------|-----------|------|
| nano-banana-pro API key | 图片生成 | 按图计费 |
| Seedance 2.0 API key | 视频生成（带音频） | 按视频计费 |
| manga-style-video Skill | 8 种漫画风格 | 随 Seedance 附赠 |
| manga-drama Skill | 分镜生成 | 随 Seedance 附赠 |
| volcengine-video-understanding | 视频 QA | 按分析计费 |
| canghe-image-gen（可选） | 漫画剧情的角色生成 | 按图计费 |

---

## API 密钥与成本汇总

| 服务 | 环境变量 | 获取方式 | 免费额度 | 付费 |
|------|---------|---------|---------|------|
| **Decodo** | DECODO_AUTH_TOKEN | decodo.com | 7 天试用（1000 次请求） | 约 $30/月 |
| **Brave Search** | BRAVE_API_KEY | brave.com/search/api | 2000 次查询/月 | $5/月 |
| **Tavily** | TAVILY_API_KEY | tavily.com | 1000 次查询/月 | $20/月 |
| **Exa** | EXA_API_KEY | exa.ai | 1000 次查询/月 | $20/月 |
| **Apify** | APIFY_TOKEN | apify.com | $5/月额度 | 按用量计费 |
| **Firecrawl** | FIRECRAWL_API_KEY | firecrawl.dev | 500 次请求/月 | $20/月 |
| **reddit-readonly** | （无需） | lobehub.com/skills | 无限制（免费） | — |
| **Seedance** | SEEDANCE_API_KEY | volcengine.com | 试用额度 | 按视频计费 |
| **nano-banana-pro** | BANANA_API_KEY | Google/volcengine API | 试用额度 | 按图计费 |
| **飞书** | FEISHU_APP_ID/SECRET | open.feishu.cn | 免费（自建应用） | — |

---

## 最小可行自动化（从这里开始）

用最低成本获得实际价值的最简配置：

```
1. 安装 reddit-readonly（免费，无需 API key）
2. 安装 Tavily（免费额度，1000 次查询/月）
3. 为 VOC Analyst 编写 SOUL.md
4. 设置一个定时任务：
   "每周一，搜索 Reddit 上 [你的产品品类]
    的痛点，将报告写入 workspace-voc/data/"
```

**成本：$0。一个 Agent，两个免费 Skill，一个定时任务。**
你将零成本获得自动化的周度市场情报。

### 逐步扩展

```
Level 1：免费          → reddit-readonly + Tavily
Level 2：约 $30/月     → 增加 Decodo（Amazon + YouTube）
Level 3：约 $55/月     → 增加 Brave Search + Apify
Level 4：$100+/月      → 增加 Seedance + nano-banana-pro（视频）
```

每个级别解锁更多自动化，无需更改架构。

---

## 整体连接关系

```
openclaw.json（线路配置）
    ↓
Lead Agent（编排器）
    ├── sessions_send → VOC Analyst
    │                     ├── Decodo（Amazon、Reddit、YouTube）
    │                     ├── reddit-readonly（免费 Reddit）
    │                     ├── Apify（Google Maps、批量）
    │                     ├── Brave/Tavily/Exa（搜索）
    │                     └── 定时任务：价格监控、周度扫描
    │
    ├── sessions_send → GEO Optimizer
    │                     └── 接收 VOC 数据 → 撰写 GEO 优化内容
    │
    ├── sessions_send → Reddit Specialist
    │                     ├── reddit-readonly（读取）
    │                     ├── Decodo reddit_post（结构化数据）
    │                     ├── Brave Search（查找旧帖）
    │                     └── 5 周 SOP 自动化
    │
    └── sessions_send → TikTok Director
                          ├── nano-banana-pro（图片）
                          ├── Seedance 2.0（视频）
                          ├── manga-style-video（8 种风格）
                          ├── manga-drama（分镜）
                          └── volcengine-video-understanding（QA）

飞书（人机接口）
    ├── @Lead 在群中 → 触发任意工作流
    ├── 进度卡片 → 实时状态
    ├── Webhook 告警 → 价格变动、错误
    └── 汇总卡片 → 最终报告
```

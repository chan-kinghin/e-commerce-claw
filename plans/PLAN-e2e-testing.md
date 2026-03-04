# 端到端测试与验证策略

**系统**：跨境电商 AI 平台（OpenClaw 多 Agent 架构）
**受测 Agent**：lead、voc-analyst、geo-optimizer、reddit-spec、tiktok-director
**日期**：2026-03-05
**状态**：未开始

---

## 1. 系统冒烟测试

在运行任何功能测试之前，先验证每个 Agent 是否存活、已连接，并能访问其所需资源。

### 1.1 Agent 健康检查

| Agent | 测试项 | 命令 / 方法 | 预期结果 | 超时 |
|-------|--------|-------------|----------|------|
| `lead` | Agent 响应 ping | `openclaw agent ping lead` | 返回 `{ "status": "alive", "agent": "lead" }` | 10s |
| `lead` | 模型连通性 | `openclaw agent test-model lead` | doubao-seed-2.0-code 返回补全结果 | 30s |
| `lead` | 工作区读写 | 向 `~/.openclaw/workspace-lead/data/test_smoke.txt` 写入后读取 | 文件内容一致 | 5s |
| `lead` | SOUL.md 已加载 | 检查 `~/.openclaw/workspace-lead/SOUL.md` 存在且非空 | 文件大小 > 100 字节 | 5s |
| `lead` | AGENTS.md 已加载 | 检查 `~/.openclaw/workspace-lead/AGENTS.md` 存在 | 文件大小 > 100 字节 | 5s |
| `voc-analyst` | Agent 响应 ping | `openclaw agent ping voc-analyst` | 返回 `{ "status": "alive" }` | 10s |
| `voc-analyst` | 模型连通性 | `openclaw agent test-model voc-analyst` | Kimi K2.5 返回补全结果 | 30s |
| `voc-analyst` | 工作区读写 | 向 `~/.openclaw/workspace-voc/data/test_smoke.txt` 写入后读取 | 文件内容一致 | 5s |
| `voc-analyst` | SOUL.md 已加载 | 检查 `~/.openclaw/workspace-voc/SOUL.md` 存在且非空 | 文件大小 > 100 字节 | 5s |
| `geo-optimizer` | Agent 响应 ping | `openclaw agent ping geo-optimizer` | 返回 `{ "status": "alive" }` | 10s |
| `geo-optimizer` | 模型连通性 | `openclaw agent test-model geo-optimizer` | doubao-seed-2.0-code 返回补全结果 | 30s |
| `geo-optimizer` | 工作区读写 | 向 `~/.openclaw/workspace-geo/data/test_smoke.txt` 写入后读取 | 文件内容一致 | 5s |
| `geo-optimizer` | GEO 规则文件已加载 | 检查 `~/.openclaw/workspace-geo/rules/geo-rules.md` 存在 | 文件大小 > 500 字节 | 5s |
| `reddit-spec` | Agent 响应 ping | `openclaw agent ping reddit-spec` | 返回 `{ "status": "alive" }` | 10s |
| `reddit-spec` | 模型连通性 | `openclaw agent test-model reddit-spec` | Kimi K2.5 返回补全结果 | 30s |
| `reddit-spec` | 工作区读写 | 向 `~/.openclaw/workspace-reddit/data/test_smoke.txt` 写入后读取 | 文件内容一致 | 5s |
| `reddit-spec` | 账号注册表存在 | 检查 `~/.openclaw/workspace-reddit/data/accounts/account-registry.json` | 有效 JSON，包含 `accounts` 数组 | 5s |
| `tiktok-director` | Agent 响应 ping | `openclaw agent ping tiktok-director` | 返回 `{ "status": "alive" }` | 10s |
| `tiktok-director` | 模型连通性 | `openclaw agent test-model tiktok-director` | doubao-seed-2.0-code 返回补全结果 | 30s |
| `tiktok-director` | 工作区读写 | 向 `~/.openclaw/workspace-tiktok/data/test_smoke.txt` 写入后读取 | 文件内容一致 | 5s |
| `tiktok-director` | 分镜模板存在 | 检查 `~/.openclaw/workspace-tiktok/templates/storyboard-25grid.json` | 有效 JSON，包含 `grids` 数组 | 5s |

### 1.2 Skill 验证

| Agent | Skill | 验证命令 | 预期结果 | 超时 |
|-------|-------|---------|----------|------|
| `voc-analyst` | Decodo Skill | `openclaw skill test decodo --workspace workspace-voc` | Skill 返回能力列表 | 15s |
| `voc-analyst` | reddit-readonly | `openclaw skill test reddit-readonly --workspace workspace-voc` | Skill 成功抓取 r/test | 15s |
| `voc-analyst` | Brave Search | `openclaw skill test brave-search --workspace workspace-voc` | 搜索返回测试查询结果 | 15s |
| `voc-analyst` | Apify | `openclaw skill test apify --workspace workspace-voc` | 返回 Apify actor 列表 | 15s |
| `geo-optimizer` | Tavily | `openclaw skill test tavily --workspace workspace-geo` | 搜索返回结果 | 15s |
| `geo-optimizer` | Brave Search | `openclaw skill test brave-search --workspace workspace-geo` | 搜索返回结果 | 15s |
| `geo-optimizer` | Firecrawl | `openclaw skill test firecrawl --workspace workspace-geo` | 测试 URL 爬取成功 | 15s |
| `reddit-spec` | reddit-readonly | `openclaw skill test reddit-readonly --workspace workspace-reddit` | 返回 Subreddit 数据 | 15s |
| `reddit-spec` | Brave Search | `openclaw skill test brave-search --workspace workspace-reddit` | 搜索返回结果 | 15s |
| `tiktok-director` | nano-banana-pro | `openclaw skill test nano-banana-pro` | 确认图像生成能力 | 15s |
| `tiktok-director` | seedance-video | `openclaw skill test seedance-video` | 确认视频生成能力 | 15s |
| `tiktok-director` | manga-style-video | `openclaw skill test manga-style-video --workspace workspace-tiktok` | 返回风格列表（8 种风格） | 15s |
| `tiktok-director` | manga-drama | `openclaw skill test manga-drama --workspace workspace-tiktok` | Skill 响应 | 15s |
| `tiktok-director` | volcengine-video-understanding | `openclaw skill test volcengine-video-understanding --workspace workspace-tiktok` | 确认 QA 分析能力 | 15s |

### 1.3 环境变量验证

| 变量 | 所需 Agent | 检查方法 | 预期 |
|------|-----------|---------|------|
| `DECODO_AUTH_TOKEN` | voc-analyst | `test -n "$DECODO_AUTH_TOKEN"` | 非空字符串，以 `VTAw` 开头 |
| `BRAVE_API_KEY` | voc-analyst、geo-optimizer、reddit-spec | `test -n "$BRAVE_API_KEY"` | 非空字符串，以 `BSA` 开头 |
| `APIFY_TOKEN` | voc-analyst | `test -n "$APIFY_TOKEN"` | 非空字符串，以 `apify_api_` 开头 |
| `TAVILY_API_KEY` | geo-optimizer | `test -n "$TAVILY_API_KEY"` | 非空字符串，以 `tvly-` 开头 |
| `FEISHU_WEBHOOK_URL` | lead、voc-analyst | `test -n "$FEISHU_WEBHOOK_URL"` | 有效 URL |
| 飞书应用凭证 | lead | 检查 `openclaw.json` channels.feishu.accounts.lead | `appId` 和 `appSecret` 为非占位符值 |

### 1.4 sessions_send 连通性

| 发送方 | 接收方 | 测试 | 预期 | 超时 |
|--------|--------|------|------|------|
| lead | voc-analyst | `sessions_send` echo 测试：`{ "type": "ping" }` | voc-analyst 收到消息并回复 `{ "type": "pong" }` | 15s |
| lead | geo-optimizer | `sessions_send` echo 测试 | geo-optimizer 回复 pong | 15s |
| lead | reddit-spec | `sessions_send` echo 测试 | reddit-spec 回复 pong | 15s |
| lead | tiktok-director | `sessions_send` echo 测试 | tiktok-director 回复 pong | 15s |
| voc-analyst | lead | `sessions_send` echo 测试（反向） | lead 收到并回复 | 15s |

---

## 2. Agent 单元测试

这些测试验证各 Agent 的核心功能在隔离环境下的表现。测试用例直接来源于各 Agent 的实施计划。

### 2.1 VOC Analyst 测试（来自 PLAN-voc-analyst.md）

| # | 测试名称 | 验证内容 | 预计耗时 | 依赖 |
|---|----------|---------|:--------:|------|
| V1 | **完整交叉验证分析** | 对"便携榨汁机"在 4 个平台（Amazon、Reddit、YouTube、Google Maps）进行端到端多源品类分析。验证 JSON 报告结构、痛点交叉验证（source_count >= 2）、置信度等级及 Markdown 报告生成。 | 5 分钟 | Decodo、reddit-readonly、Apify、Brave Search |
| V2 | **单平台快速查询** | 仅 Reddit 的"4K 电视"快速情感分析。验证 120 秒内响应，至少分析 10 篇帖子，置信度标记为 LOW（单一来源）。 | 2 分钟 | reddit-readonly 或 Decodo |
| V3 | **价格监控检测** | 使用已知价格预填 price_memory.txt，运行价格监控，检测价格变化并生成告警。验证 price_memory.txt 更新及 price_history 文件创建。 | 3 分钟 | Playwright-npx 或 web_fetch |
| V4 | **平台故障下的优雅降级** | 使用无效 Apify token 进行完整分析。验证报告仍以 3/4 数据源生成，google_maps 状态为"error"，置信度降为 MEDIUM。 | 5 分钟 | Decodo、reddit-readonly（Apify 故意失效） |
| V5 | **竞品追踪添加** | 添加 2 个竞品 ASIN，验证资料 JSON 文件创建、price_memory.txt 条目新增。 | 2 分钟 | Decodo |
| V6 | **空数据处理** | 查询不存在的品类（"量子纠缠狗项圈"）。验证置信度 LOW、判定 INSUFFICIENT_DATA、空 pain_points、无崩溃。 | 2 分钟 | 所有搜索 Skill |

### 2.2 GEO Optimizer 测试（来自 PLAN-geo-optimizer.md）

| # | 测试名称 | 验证内容 | 预计耗时 | 依赖 |
|---|----------|---------|:--------:|------|
| G1 | **行军床博客文章** | 基于 VOC 痛点生成博客。验证 1500-2500 词、6+ 引用、15+ 数据点、FAQ 部分、对比表、GEO 评分 >= 80。 | 8 分钟 | Tavily、Brave Search、Exa |
| G2 | **蓝牙耳机 Amazon Listing** | Amazon Listing 优化。验证标题 < 200 字符含数字参数、5 条卖点大写开头 + 数据、无关键词堆砌（品类词每 500 词最多 3 次）、GEO 评分 >= 80。 | 5 分钟 | Decodo、Brave Search |
| G3 | **升降桌产品描述** | 含专家引用的产品描述。验证 BIFMA/UL 权威引用、所有参数含单位、具名竞品对比、10+ 数据点、GEO 评分 >= 80。 | 4 分钟 | 搜索 Skill |
| G4 | **GEO 规则违规检测** | 规则引擎对预先写好的低质量内容进行检测。验证检出以下违规：C1（关键词堆砌）、C2（模糊修饰词）、C4（通用开头）、A1（无引用）、D1（无 FAQ）。评分 < 40。 | 1 分钟 | 无（仅规则引擎） |
| G5 | **单份 VOC 报告生成多格式输出** | 便携榨汁机的完整内容套件：博客 + Amazon Listing + 产品描述。验证三种格式使用相同 VOC 数据、各格式通过 GEO 规则、排名第一痛点在所有输出中均有体现、跨格式重复率 < 20%。 | 12 分钟 | 所有搜索 Skill |
| G6 | **引用时效性与验证** | 检测无线充电器内容中的过期引用（2022-2023）。验证对超过 18 个月的引用发出警告、建议替代来源。 | 3 分钟 | 搜索 Skill |

### 2.3 Reddit Specialist 测试（来自 PLAN-reddit-specialist.md）

| # | 测试名称 | 验证内容 | 预计耗时 | 依赖 |
|---|----------|---------|:--------:|------|
| R1 | **W2 评论生成** | 行军床帖子的非推广性评论（W2 阶段）。验证：零产品提及、回应 OP 的问题、可操作建议、spam 评分 < 0.1、100-200 词。 | 1 分钟 | 无（仅评论生成） |
| R2 | **W4 软性推荐** | 护肤品讨论中的软性产品推荐（W4 阶段）。验证：产品仅自然提及一次、1+ 替代品提及、坦诚优缺点、使用 subreddit 行话、spam 评分 < 0.2、无直接链接。 | 1 分钟 | 无（仅评论生成） |
| R3 | **流量截取帖子评估** | 对候选帖子进行流量截取评分。验证：按评分体系正确计算分数、7/10 阈值判定、达标则生成评论草稿、评估结果以 JSON 格式记录。 | 2 分钟 | Brave Search |
| R4 | **多账号轮转合规性** | 3 个处于不同 SOP 阶段的账号，各有分配的 subreddit。验证：各 subreddit 使用正确账号、W3 账号排除在推广之外、无 subreddit 重叠、频率限制受遵守。 | 1 分钟 | 无（逻辑验证） |
| R5 | **Shadowban 检测与响应** | 通过 2 种独立方法检测 shadowban、更新注册表、暂停活动、启动恢复。验证：两种检测方法均使用、状态已更新、设定 14 天冷却期、告警已记录、subreddit 分配已重新分配。 | 3 分钟 | Playwright-npx、reddit-readonly |
| R6 | **端到端流量截取** | 从 Google 搜索到发布评论的完整"便携榨汁机"工作流。验证：5+ 候选帖子找到、3 篇已评估、1-2 篇入选（评分 >= 7）、评论回应 VOC 痛点、无直接链接、使用 W5 账号、已设监控计划。 | 5 分钟 | Brave Search、reddit-readonly |

### 2.4 TikTok Director 测试（来自 PLAN-tiktok-director.md）

| # | 测试名称 | 验证内容 | 预计耗时 | 依赖 |
|---|----------|---------|:--------:|------|
| T1 | **标准 UGC 视频 —— 行军床** | 完整 25 格分镜 + 10-12 关键帧 + 15 秒视频 + QA。验证：25 格全部存在（3/5/7/6/4 分布）、前 2 秒有呼吸感运镜、床垫按压演示、QA 综合评分 >= 7.0、视频 < 50MB、时长 15 秒 +/- 0.5 秒。 | 15 分钟 | nano-banana-pro、seedance-video、volcengine-video-understanding |
| T2 | **漫画剧情 —— 武侠茶产品** | 3 个场景的中国水墨风漫画剧情。验证：角色跨场景一致性、水墨风格（有限色板、毛笔笔触）、单场景 QA >= 6.5、连贯的故事流。 | 20 分钟 | canghe-image-gen、manga-style-video、manga-drama、seedance-video、volcengine-video-understanding |
| T3 | **A/B 测试矩阵 —— 便携榨汁机** | 基于 1 个基础分镜生成 4 种开场变体。验证：第 2 秒之后内容完全一致、开场视觉/音频各不同、4 个变体均通过 QA >= 6.5、文件大小相互在 20% 以内。 | 25 分钟 | nano-banana-pro、seedance-video、volcengine-video-understanding |
| T4 | **吉卜力风格视频 —— 竹牙刷** | 10 秒吉卜力风格视频。验证：水彩质感和大地色调、17 格分镜正确缩放、自然环境（非浴室）、volcengine 检测到正面情感、QA >= 7.0。 | 12 分钟 | nano-banana-pro、seedance-video、volcengine-video-understanding |
| T5 | **视频 QA 失败与重新生成** | 故意使用极简 prompt 生成视频以触发 QA 失败。验证：QA 识别出不足之处、重新生成仅针对失败片段、第二次尝试分数提升、循环在 <= 3 次内完成、成本追踪反映多次尝试。 | 20 分钟 | 所有 TikTok Skill |

---

## 3. 集成测试（Agent 间协作）

这些测试验证特定 Agent 对之间的 `sessions_send` 通信，确保数据在系统中正确流转。

### 3.1 Lead -> VOC Analyst：任务派发与结果收集

**输入消息**（Lead 通过 sessions_send 发送）：
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

**预期响应**（VOC 通过 sessions_send 返回）：
- 有效的 VOCReport JSON，`request_id: "int_test_lead_voc_001"`
- `data_sources` 包含每个请求平台的条目
- `pain_points` 数组非空
- `metadata.needs_geo_optimization` 和 `metadata.needs_tiktok_content` 标志存在
- 报告文件保存到 `~/.openclaw/workspace-voc/data/reports/`

**验证标准**：
- [ ] Lead 在 5 分钟内收到响应
- [ ] 响应 JSON 通过 VOCReport schema 验证
- [ ] `request_id` 与发送值匹配
- [ ] `confidence` 为 HIGH 或 MEDIUM（至少 3 个数据源成功）
- [ ] Lead 能解析并提取 `pain_points_summary` 用于下游路由

**超时**：6 分钟

### 3.2 Lead -> GEO Optimizer：内容生成请求与交付

**输入消息**（Lead 通过 sessions_send 发送）：
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

**预期响应**：
- 状态 `completed`，`outputs` 数组包含博客和 Amazon Listing
- 每个输出的 `geo_score >= 80`
- `quality_summary.all_hard_fail_rules_passed: true`
- 文件保存到 `~/.openclaw/workspace-geo/data/output/`

**验证标准**：
- [ ] Lead 在 10 分钟内收到响应
- [ ] 博客输出包含 pain_points_summary 中的量化数据（如"68%"、"450"）
- [ ] Amazon Listing 标题包含数字参数
- [ ] 两个输出的 GEO 评分均 >= 80
- [ ] 无 HARD FAIL 规则违规

**超时**：12 分钟

### 3.3 Lead -> Reddit Specialist：推广任务分配与状态汇报

**输入消息**（Lead 通过 sessions_send 发送）：
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

**预期响应**：
- 状态 `in_progress`，列出符合条件的账号
- 计划包含 target_posts_found 数量、已评估帖子数、入选帖子数
- 提供预估发布时间窗口
- 无阻塞因素（或列出具体阻塞原因）

**验证标准**：
- [ ] Lead 在 2 分钟内收到确认
- [ ] 响应中仅列出 W4+ 账号为符合条件
- [ ] 找到的目标帖子数 > 0
- [ ] 预估发布时间窗口合理（3-7 天）
- [ ] 在发布窗口期内有周报跟进

**超时**：3 分钟（初始确认）

### 3.4 Lead -> TikTok Director：视频生成请求与素材交付

**输入消息**（Lead 通过 sessions_send 发送）：
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

**预期响应**：
- 状态 `completed`，包含 deliverables 对象
- 25 格分镜 JSON
- 图片目录包含 10-12 张 1080x1920 PNG 文件
- 视频文件（MP4，15 秒，9:16）
- QA 报告，综合评分 >= 7.0
- 成本和耗时明细

**验证标准**：
- [ ] Lead 在 15 分钟内收到最终交付物
- [ ] 视频文件存在且可播放（MP4，< 50MB）
- [ ] QA 综合评分 >= 7.0
- [ ] 分镜类别匹配 3/5/7/6/4 分布
- [ ] 成本明细含所有 token 用量

**超时**：18 分钟

### 3.5 VOC -> GEO（经 Lead）：痛点数据流向内容生成

**测试流程**：
1. Lead 向 VOC 派发品类分析
2. VOC 返回痛点报告
3. Lead 提取 pain_points_summary 和 competitive_positioning
4. Lead 将结构化数据转发给 GEO
5. GEO 使用 VOC 数据生成内容

**验证标准**：
- [ ] GEO 内容引用了 VOC 的具体痛点数据（如"68% 的差评"）
- [ ] GEO 博客对比表包含 VOC 报告中的竞品数据
- [ ] GEO 内容未捏造 VOC 数据中不存在的痛点
- [ ] 从 VOCReport 到 GEO 输入的数据转换保持准确
- [ ] 从 VOC 派发到 GEO 输出的端到端时间 < 15 分钟

**超时**：18 分钟

### 3.6 VOC -> TikTok（经 Lead）：痛点数据流向视频生成

**测试流程**：
1. Lead 向 VOC 派发品类分析
2. VOC 返回痛点报告
3. Lead 提取 pain_points_for_script，含视觉演示和秒数标记
4. Lead 将结构化数据转发给 TikTok Director
5. TikTok 生成分镜和视频

**验证标准**：
- [ ] TikTok 分镜中的 pain_point 格（第 4-8 格）引用了实际 VOC 问题
- [ ] 第一个痛点映射到分镜中"第 2-4 秒展示"
- [ ] VOC 数据中的产品参数出现在 CTA 文字叠加中
- [ ] 视频 QA 确认存在痛点展示类别
- [ ] 从 VOC 派发到视频交付的端到端时间 < 20 分钟

**超时**：22 分钟

---

## 4. 端到端场景：行军折叠床（旗舰场景）

这是基于商业计划书参考场景（2.7 节）的完整系统测试，调动全部 5 个 Agent 协同工作。

### 4.1 触发

**用户输入**（飞书群消息）：
```
@Lead "全渠道、全内容推送"
```

**等效英文**: "Analyze the camping folding bed market and push content to all channels"

### 4.2 分步执行

#### 步骤 1：接收用户消息（T+0s）

| 项目 | 详情 |
|------|------|
| 渠道 | 飞书 WebSocket |
| 接收方 | Lead Agent（唯一人机接口） |
| 动作 | Lead 接收自然语言指令 |
| 验证 | Lead 在 5 秒内于飞书群发送确认 |

#### 步骤 2：Lead 拆解任务（T+5s）

| 项目 | 详情 |
|------|------|
| 动作 | Lead 解析意图，生成含 4 个子任务的 DAG 执行计划 |
| 子任务 | (1) VOC 市场分析，(2) Reddit 高排名帖搜索，(3) GEO 内容生成（依赖 VOC），(4) TikTok 视频生成（依赖 VOC），(5) Reddit 评论撰写（依赖 Reddit 搜索 + VOC） |
| DAG 结构 | 任务 1+2 并行执行；任务 3+4+5 在 1+2 完成后执行 |
| 验证 | Lead 在飞书发送进度更新："开始分析，已创建 4 个子任务" |
| 预计耗时 | 约 5 秒 |

#### 步骤 3：VOC + Reddit 搜索并行执行（T+5s 至 T+3min）

**子任务 3A：VOC 市场分析**

| 项目 | 详情 |
|------|------|
| Agent | voc-analyst |
| 输入 | Lead 通过 `sessions_send` 发送：对"行军折叠床"跨 Amazon、Reddit、YouTube、Google Maps 进行 full_analysis |
| 动作 | Amazon BSR 前 50 商品、Reddit subreddit 爬取（r/Camping、r/BuyItForLife）、YouTube 字幕提取（前 3 个评测视频）、Google Maps 批发数据 |
| 预期输出 | 痛点：承重不足（严重度 9.2）、收纳困难（严重度 7.5）；价格区间 $30-80；BSR 前 50 分析；竞品弱点 |
| 耗时 | 约 3 分钟 |

**子任务 3B：Reddit 高排名帖搜索**

| 项目 | 详情 |
|------|------|
| Agent | reddit-spec |
| 输入 | Lead 通过 `sessions_send` 发送：在 r/Camping、r/BuyItForLife 中搜索关于行军床的高排名老帖 |
| 动作 | Brave Search 搜索"best camping cot reddit"，按评分体系（10 分制）评估帖子质量，选取评分 >= 7/10 的帖子 |
| 预期输出 | 3 篇已标注评分、URL 和帖子上下文的高排名老帖 |
| 耗时 | 约 2 分钟 |

**T+3min 检查点**：
- [ ] Lead 收到含痛点和市场数据的 VOC 报告
- [ ] Lead 收到含 3+ 已评估帖子的 Reddit 帖子列表
- [ ] 两个 Agent 均无错误完成
- [ ] Lead 发送飞书更新："市场分析完成。首要痛点：承重不足。"

#### 步骤 4：GEO + Reddit 评论 + TikTok 并行执行（T+3min 至 T+13min）

**子任务 4A：GEO 内容生成**

| 项目 | 详情 |
|------|------|
| Agent | geo-optimizer |
| 输入 | Lead 路由的 VOC 痛点 + 竞品定位数据 |
| 动作 | 研究权威来源（OutdoorGearLab、Wirecutter），撰写含对比表的博客，应用 GEO 规则引擎，自我评估 |
| 预期输出 | 博客含量化数据（"承重可达 450 磅"）、OutdoorGearLab 引用、5+ 条 Q&A 的 FAQ 部分、GEO 评分 >= 80 |
| 耗时 | 约 5-8 分钟 |

**子任务 4B：Reddit 评论撰写**

| 项目 | 详情 |
|------|------|
| Agent | reddit-spec |
| 输入 | 步骤 3B 的 3 个目标帖 + 步骤 3A 的 VOC 痛点 |
| 动作 | 为每个目标帖撰写真诚评论（各 100-250 词），回应 OP 的痛点，自然嵌入产品提及，执行 spam 评分检查 |
| 预期输出 | 2-3 条待发布评论草稿，每条 spam 评分 < 0.2，无直接产品链接 |
| 耗时 | 约 3-5 分钟 |

**子任务 4C：TikTok 视频生成**

| 项目 | 详情 |
|------|------|
| Agent | tiktok-director |
| 输入 | Lead 路由的产品简介 + VOC 痛点 |
| 动作 | 设计 25 格分镜，生成关键帧图片（nano-banana-pro），生成视频片段（Seedance 1.5 Pro），组装最终视频，执行 QA（volcengine） |
| 预期输出 | 15 秒 UGC 视频，前 2 秒含呼吸感运镜，第 4 秒床垫按压特写，QA 综合评分 >= 7.0 |
| 耗时 | 约 10 分钟 |

**T+13min 检查点**：
- [ ] Lead 收到 GEO 博客，GEO 评分 >= 80
- [ ] Lead 收到 Reddit 评论草稿
- [ ] Lead 收到 TikTok 视频 + QA 报告
- [ ] 三个 Agent 均无严重错误完成

#### 步骤 5：Lead 汇总所有输出（T+13min 至 T+15min）

| 项目 | 详情 |
|------|------|
| Agent | lead |
| 动作 | 收集所有输出，验证完整性，格式化飞书汇总卡片 |
| 输出 | 飞书互动卡片消息：市场摘要、核心痛点、博客链接、Amazon Listing 预览、Reddit 推广状态、视频缩略图 + 下载链接 |
| 耗时 | 约 10 秒 |

### 4.3 总时间线

| 阶段 | 耗时 | 活跃 Agent |
|------|:----:|:----------:|
| 消息接收 + 任务拆解 | 约 5 秒 | lead |
| 并行调研（VOC + Reddit 搜索） | 约 3 分钟 | voc-analyst + reddit-spec |
| 并行内容创建（GEO + Reddit 评论 + TikTok） | 约 10 分钟 | geo-optimizer + reddit-spec + tiktok-director |
| 结果汇总 + 飞书报告 | 约 10 秒 | lead |
| **总计** | **约 15-20 分钟** | 全部 5 个 Agent |

### 4.4 成功标准

| # | 标准 | 验证方法 |
|---|------|---------|
| 1 | 5 项交付物全部齐全：VOC 报告、博客文章、Amazon Listing、Reddit 评论、TikTok 视频 | 统计 Lead 收集到的不同交付物类型 |
| 2 | VOC 报告为 HIGH 或 MEDIUM 置信度，>= 3 个数据源 | 检查 VOCReport JSON 中的 `confidence` 和 `data_sources` |
| 3 | GEO 博客通过所有 HARD FAIL 规则（A-D 类） | 对博客输出运行 GEO 规则引擎 |
| 4 | GEO 博客 GEO 评分 >= 80 | 检查输出元数据中的 `geo_score` |
| 5 | Reddit 评论 spam 评分 < 0.2 且无产品链接 | 对每条评论草稿进行内容分析 |
| 6 | TikTok 视频 QA 综合评分 >= 7.0 | 检查 QA 报告 JSON |
| 7 | TikTok 视频 15 秒 +/- 0.5 秒，1080x1920，MP4 | 对输出视频文件执行 ffprobe |
| 8 | TikTok 视频前 2 秒含呼吸感运镜（无静态帧） | volcengine 首 N 帧分析 |
| 9 | 飞书汇总卡片已发送到群组 | 验证飞书群收到卡片消息 |
| 10 | 总执行时间 <= 20 分钟 | 从飞书消息到汇总卡片的挂钟时间 |
| 11 | 所有 Agent 无未处理错误 | 检查 5 个工作区的错误日志 |
| 12 | VOC 痛点数据（"承重"、"收纳"）出现在 GEO 内容和 TikTok 分镜中 | 交叉比对 VOC 输出与下游输出中的 pain_points |

---

## 5. 其他端到端场景

### 5.1 场景：蓝牙耳机（VOC + GEO + Reddit，无 TikTok）

此场景测试不需要 TikTok 视频生成的部分管线。

**触发**（飞书）：
```
@Lead "调研蓝牙耳机市场，写内容，布局 Reddit。不需要视频。"
```

#### 分步执行

| 步骤 | Agent | 动作 | 预期输出 | 耗时 |
|------|-------|------|---------|:----:|
| 1 | Lead | 解析意图，识别 3 个子任务（无 TikTok） | DAG：VOC -> GEO + Reddit | 约 5 秒 |
| 2 | voc-analyst | 完整分析："蓝牙耳机"跨 Amazon、Reddit、YouTube | 痛点：电池耗尽快（34%）、运动时掉落（22%）、降噪差（18%）；价格区间 $20-35 | 约 3 分钟 |
| 3a | geo-optimizer | 使用 VOC 痛点生成博客 + Amazon Listing | 博客："48 小时续航"数据点，4+ 耳机对比表，5+ 条 Q&A 的 FAQ，GEO 评分 >= 80。Amazon：标题含续航时长参数，5 条大写卖点 | 约 8 分钟 |
| 3b | reddit-spec | 搜索 r/headphones、r/BuyItForLife、r/budgetaudiophile 中的高排名帖并撰写评论 | 找到 2-3 个目标帖，评论草稿回应电池/佩戴痛点，无链接 | 约 5 分钟 |
| 4 | Lead | 汇总：VOC 报告 + 博客 + Listing + Reddit 推广状态 | 飞书汇总卡片（无视频部分） | 约 10 秒 |

**成功标准**：

| # | 标准 |
|---|------|
| 1 | TikTok Agent 未被调用（Lead 正确排除） |
| 2 | VOC 报告覆盖至少 3 个平台 |
| 3 | GEO 博客引用 VOC 的电池续航数据（如"34% 的差评提及电池续航"） |
| 4 | Amazon Listing 标题含数字续航参数（如"48-Hour"） |
| 5 | Reddit 评论目标为 r/headphones 或 r/budgetaudiophile（不同于行军床场景的 subreddit） |
| 6 | Reddit 评论在个人经历叙述中自然提及耳机 |
| 7 | 飞书汇总卡片有 3 个板块（VOC + GEO + Reddit），无视频板块 |
| 8 | 总时间 <= 12 分钟 |

### 5.2 场景：便携榨汁机（全管线，不同产品品类）

此场景使用不同产品品类、不同 subreddit 和不同 TikTok 漫画风格来测试完整 5-Agent 管线。

**触发**（飞书）：
```
@Lead "全管线：便携榨汁机市场分析 + 全渠道。TikTok 风格：日式治愈系。"
```

#### 分步执行

| 步骤 | Agent | 动作 | 预期输出 | 耗时 |
|------|-------|------|---------|:----:|
| 1 | Lead | 解析意图，创建 4 个子任务，记录 TikTok 风格偏好（japanese） | DAG：VOC + Reddit 搜索并行，然后 GEO + Reddit 评论 + TikTok 并行 | 约 5 秒 |
| 2a | voc-analyst | 完整分析："便携榨汁机"跨 Amazon、Reddit、YouTube、Google Maps | 痛点：刀片打不碎冰块（38%）、电量太低（29%）、难清洗（21%）；价格 $25-45；BSR 前 50 | 约 3 分钟 |
| 2b | reddit-spec | 搜索 r/BuyItForLife、r/Cooking、r/MealPrepSunday 中的高排名帖 | 3+ 条关于便携榨汁机的候选帖，已评估评分 | 约 2 分钟 |
| 3a | geo-optimizer | 博客 + Amazon Listing + 产品描述（便携榨汁机） | 博客含碎冰测试数据、对比表、FAQ。Amazon Listing 含刀片数量参数。产品描述含 USB-C 充电细节。所有 GEO 评分 >= 80 | 约 10 分钟 |
| 3b | reddit-spec | 使用 VOC 痛点（刀片、电池、清洗）为选中帖子撰写评论 | 2 条回应榨汁机特定痛点的评论，使用 r/Cooking 行话（"mise en place"、"batch prep"） | 约 4 分钟 |
| 3c | tiktok-director | `japanese` 治愈风格 25 格分镜 + 15 秒视频 | 柔和粉彩色调、温暖光线、厨房/生活场景、碎冰演示产品展示、QA 综合评分 >= 7.0 | 约 12 分钟 |
| 4 | Lead | 汇总全部 5 项交付物 | 飞书汇总卡片含所有板块（包括视频缩略图） | 约 10 秒 |

**成功标准**：

| # | 标准 |
|---|------|
| 1 | VOC 报告将碎冰能力识别为首要痛点并附频率数据 |
| 2 | GEO 内容包含碎冰量化数据（如"15 秒内粉碎 10 块冰"） |
| 3 | Reddit 评论目标为不同于行军床场景的 subreddit（r/Cooking、r/MealPrepSunday） |
| 4 | Reddit 评论自然使用烹饪社区行话 |
| 5 | TikTok 视频使用 `japanese` 漫画风格（volcengine 确认柔和粉彩、温暖光线） |
| 6 | TikTok 分镜 pain_point 格展示碎冰演示 |
| 7 | 飞书汇总中包含全部 5 项交付物 |
| 8 | 无与其他测试运行的行军床数据交叉污染 |
| 9 | 总时间 <= 20 分钟 |

---

## 6. 性能基准

| 阶段 | Agent | 目标时间 | 最大可接受 | 说明 |
|------|-------|:-------:|:--------:|------|
| 任务拆解 | lead | 5 秒 | 15 秒 | 解析自然语言，生成 DAG |
| VOC 完整分析（4 平台） | voc-analyst | 3 分钟 | 5 分钟 | Amazon、Reddit、YouTube、Google Maps 并行爬取 |
| VOC 快速查询（1 平台） | voc-analyst | 1 分钟 | 2 分钟 | 单平台情感分析 |
| GEO 博客生成 | geo-optimizer | 5 分钟 | 8 分钟 | 调研 + 草稿 + 规则检查 + 修订 |
| GEO Amazon Listing 生成 | geo-optimizer | 3 分钟 | 5 分钟 | 竞品分析 + 草稿 + 规则检查 |
| GEO 产品描述 | geo-optimizer | 3 分钟 | 4 分钟 | 功能-利益映射 + 草稿 |
| Reddit 帖子搜索（Google 搜索） | reddit-spec | 1 分钟 | 2 分钟 | Brave Search 搜索高排名帖 |
| Reddit 评论撰写（每条） | reddit-spec | 1 分钟 | 2 分钟 | 阅读帖子 + 撰写真诚评论 |
| TikTok 分镜生成 | tiktok-director | 45 秒 | 90 秒 | doubao-seed-2.0-code 脚本生成 |
| TikTok 图片生成（每帧） | tiktok-director | 30 秒 | 60 秒 | nano-banana-pro 单张图片 |
| TikTok 视频生成（每段） | tiktok-director | 90 秒 | 120 秒 | Seedance 1.5 Pro 每 5-10 秒片段 |
| TikTok QA 分析 | tiktok-director | 45 秒 | 60 秒 | volcengine-video-understanding 每个视频 |
| TikTok 全流程（分镜到视频） | tiktok-director | 10 分钟 | 15 分钟 | 单个产品端到端 |
| 结果汇总 | lead | 10 秒 | 30 秒 | 收集输出，格式化飞书卡片 |
| **全管线（全部 5 个 Agent）** | **全部** | **15 分钟** | **20 分钟** | **行军床参考场景** |
| 价格监控周期（20 个 ASIN） | voc-analyst | 2 分钟 | 3 分钟 | 每日定时任务 |

---

## 7. 故障注入测试

这些测试验证单个组件故障时的系统韧性。

### 7.1 VOC Agent 调研中途超时

| 项目 | 详情 |
|------|------|
| **配置** | 触发 full_analysis 任务，在 voc-analyst 开始 Amazon 爬取后但 Reddit 爬取完成前终止其进程 |
| **预期行为** | Lead 在配置的阈值（5 分钟）后检测到 voc-analyst 超时。Lead 汇报超时前已收到的部分结果。Lead 发送飞书消息："VOC 分析超时。部分数据可用。将使用可用结果继续。" |
| **验证** | Lead 不崩溃。若已收到部分 Amazon 数据，则包含在报告中。GEO 和 TikTok 接收可用数据（可能质量降低）。飞书通知包含错误上下文。 |
| **通过标准** | Lead 优雅处理超时、不无限挂起、向用户交付部分报告 |

### 7.2 Reddit 被限流（429）

| 项目 | 详情 |
|------|------|
| **配置** | 配置 reddit-readonly 返回 429 响应（通过设置无效频率限制头或耗尽配额模拟） |
| **预期行为** | reddit-spec 检测到 429，使用指数退避重试（5 秒、15 秒、45 秒）。3 次重试后仍然失败，回退到 Decodo reddit_subreddit。若 Decodo 也失败，回退到 Brave Search 加 `site:reddit.com`。Lead 等待 reddit-spec 的响应或超时。 |
| **验证** | 重试尝试记录在 `scrape_log.jsonl`。回退链按正确顺序执行。若所有 Reddit 来源均失败，reddit-spec 向 Lead 报告包含详情的失败信息。Lead 在无 Reddit 数据情况下继续下游任务。 |
| **通过标准** | Agent 遵循重试/回退策略、不崩溃、报告清晰错误上下文 |

### 7.3 Seedance API 宕机

| 项目 | 详情 |
|------|------|
| **配置** | 阻断到 Seedance API 端点的出站连接（或设置无效 API 凭证） |
| **预期行为** | tiktok-director 在视频生成步骤失败。分镜和图片素材仍成功生成。Agent 向 Lead 报告：`{ "status": "partial_failure", "completed": ["storyboard", "images"], "failed": ["video_generation"], "error": "Seedance API unreachable" }`。Lead 将其他结果（VOC、GEO、Reddit）交付用户（无视频）。飞书卡片包含备注："视频生成不可用。已交付分镜和关键帧。" |
| **验证** | Lead 向用户交付 4/5 交付物。飞书卡片格式正确无视频部分。分镜 JSON 和图片可访问。无级联故障影响其他 Agent。 |
| **通过标准** | 系统交付部分结果、视频故障不阻塞其他 Agent |

### 7.4 飞书 WebSocket 断开

| 项目 | 详情 |
|------|------|
| **配置** | 在管线执行中途断开飞书 WebSocket 连接（Lead 已派发任务但尚未最终汇总） |
| **预期行为** | Lead 检测到 WebSocket 断开。Lead 使用指数退避尝试重连。Agent 管线继续执行（sessions_send 独立于飞书）。WebSocket 重连后，Lead 交付排队的飞书汇总卡片。若 5 次重连均失败，Lead 将完成的结果记录到工作区供手动提取。 |
| **验证** | Agent 间通信（sessions_send）不受飞书断开影响。结果不丢失。排队消息在重连后交付。若重连失败，结果保存到磁盘。 |
| **通过标准** | 飞书断开不影响 Agent 管线执行，重连后消息正常交付 |

### 7.5 VOC 返回坏数据（畸形 JSON）

| 项目 | 详情 |
|------|------|
| **配置** | 在 VOC 的 sessions_send 响应中注入畸形 JSON（如截断 JSON、缺失必需字段、无效数据类型） |
| **预期行为** | Lead 检测到 JSON 解析错误或 schema 验证失败。Lead 不将畸形数据转发给 GEO 或 TikTok。Lead 请求 VOC 重试（一次重试机会）。若重试也失败，Lead 向用户报告："市场分析返回无效数据。请重试。" GEO 和 TikTok 绝不会收到垃圾数据。 |
| **验证** | Lead 在路由前执行输入验证。GEO/TikTok 绝不收到垃圾数据。错误连同畸形载荷一并记录，便于调试。飞书通知清晰且可操作。 |
| **通过标准** | 畸形数据在 Lead 处被拦截、绝不传播到下游 |

### 7.6 全部 Agent 超时

| 项目 | 详情 |
|------|------|
| **配置** | 在 Lead 派发任务后终止全部 4 个工作 Agent（voc-analyst、geo-optimizer、reddit-spec、tiktok-director） |
| **预期行为** | Lead 等待每个 Agent 的配置超时。每个 Agent 超时后，Lead 记录失败。全部 Agent 超时后，Lead 向人类升级：飞书消息"所有 Agent 无响应。未收集到数据。需要人工干预。"Lead 附带诊断信息：哪些 Agent 不可达、时间戳、最后已知状态。 |
| **验证** | Lead 不会永久挂起。超时有上限（所有 Agent 最多 10 分钟）。飞书升级包含可操作的诊断信息。Agent 重启后系统可恢复，无需手动清理。 |
| **通过标准** | Lead 清晰升级、不死锁、提供诊断信息 |

### 7.7 模型 API 配额耗尽

| 项目 | 详情 |
|------|------|
| **配置** | 在任务执行中途耗尽 doubao-seed-2.0-code 或 Kimi K2.5 的 API 配额 |
| **预期行为** | 受影响 Agent 收到 API 错误（429 或配额超限）。Agent 通过 sessions_send 向 Lead 报告具体错误。Lead 进行调整：若执行层模型（Kimi K2.5）宕机，任务无法重新路由（不同模型类型）。Lead 向用户报告哪些能力受到影响。 |
| **验证** | 清晰的错误报告含模型名称和配额详情。无静默失败。用户被告知哪些功能暂时不可用。 |
| **通过标准** | 配额耗尽被清晰报告、不导致崩溃或数据损坏 |

---

## 8. 成功标准矩阵

| 测试类别 | 测试名称 | 通过标准 | 失败标准 | 优先级 |
|---------|---------|---------|---------|:------:|
| **冒烟** | Agent 健康检查（全部 5 个） | 5 个 Agent 全部在 10 秒内返回 alive | 任一 Agent 在 10 秒后无响应 | P0 |
| **冒烟** | Skill 验证 | 所有必需 Skill 响应测试命令 | 任一 P0 Skill 无响应 | P0 |
| **冒烟** | 环境变量 | 所有必需环境变量已设置且非空 | 任一必需环境变量缺失 | P0 |
| **冒烟** | sessions_send 连通性 | 全部 5 对 Agent 完成 echo 测试 | 任一对无法通信 | P0 |
| **单元** | VOC 完整分析（V1） | JSON 报告有效，>= 3 痛点，source_count >= 2，置信度 HIGH/MEDIUM | 无效 JSON、< 3 痛点或 NONE 置信度 | P0 |
| **单元** | VOC 优雅降级（V4） | 报告以 3/4 数据源生成，错误已记录 | Agent 崩溃或无报告生成 | P1 |
| **单元** | VOC 空数据处理（V6） | 判定 INSUFFICIENT_DATA、无崩溃 | 崩溃、捏造数据或挂起 | P1 |
| **单元** | GEO 博客（G1） | GEO 评分 >= 80、6+ 引用、含 FAQ、含对比表 | GEO 评分 < 60 或 HARD FAIL 违规 | P0 |
| **单元** | GEO 规则违规检测（G4） | 全部 5 个故意违规均被检出，评分 < 40 | 任一违规被遗漏 | P1 |
| **单元** | GEO 多格式输出（G5） | 3 种格式生成，全部评分 >= 80，使用相同 VOC 数据 | 任一格式缺失或评分 < 60 | P1 |
| **单元** | Reddit W2 评论（R1） | 零产品提及、spam 评分 < 0.1、100-200 词 | 提及产品或 spam 评分 >= 0.3 | P0 |
| **单元** | Reddit W4 软性推荐（R2） | 产品提及一次、含替代品、spam < 0.2 | 多次提及产品、无替代品或含链接 | P0 |
| **单元** | Reddit 流量截取（R6） | 帖子已找到、已评估、评论已撰写、无链接 | 未找到帖子或评论含直接链接 | P1 |
| **单元** | TikTok UGC 视频（T1） | 25 格、15 秒视频、QA >= 7.0、含呼吸感运镜 | QA < 6.0、时长错误或静态开场 | P0 |
| **单元** | TikTok 漫画剧情（T2） | 角色一致性、风格一致性、单场景 QA >= 6.5 | 角色不一致或风格错误 | P1 |
| **单元** | TikTok QA 失败恢复（T5） | 识别不足、定向重生成、<= 3 次尝试 | 误报 QA、全量重生成而非定向、或 > 3 次尝试 | P1 |
| **集成** | Lead -> VOC 派发（3.1） | 5 分钟内响应、有效 schema、request_id 匹配 | 超时、无效 schema 或错误 request_id | P0 |
| **集成** | Lead -> GEO 派发（3.2） | 10 分钟内响应、GEO 评分 >= 80、无 HARD FAIL | 超时或输出中有 HARD FAIL 违规 | P0 |
| **集成** | Lead -> Reddit 派发（3.3） | 2 分钟内确认、列出符合条件账号 | 超时或无符合条件账号 | P1 |
| **集成** | Lead -> TikTok 派发（3.4） | 15 分钟内交付视频、QA >= 7.0 | 超时或 QA < 6.0 | P0 |
| **集成** | VOC -> GEO 数据流（3.5） | GEO 内容准确引用 VOC 痛点数据 | GEO 捏造 VOC 报告中不存在的数据 | P0 |
| **集成** | VOC -> TikTok 数据流（3.6） | 分镜 pain_point 格引用 VOC 问题 | 分镜忽略 VOC 数据 | P1 |
| **E2E** | 行军床全管线（4） | 5 项交付物齐全、总时间 <= 20 分钟、飞书卡片已发 | 任一交付物缺失或总时间 > 25 分钟 | P0 |
| **E2E** | 蓝牙耳机部分管线（5.1） | 3 项交付物（无 TikTok）、TikTok 被正确排除、总时间 <= 12 分钟 | TikTok 被调用或 > 15 分钟 | P1 |
| **E2E** | 便携榨汁机全管线（5.2） | 5 项交付物齐全、japanese 风格确认、不同 subreddit | 风格错误或与行军床相同 subreddit | P1 |
| **故障** | VOC 超时（7.1） | Lead 报告部分结果、不挂起 | Lead 挂起或崩溃 | P0 |
| **故障** | Reddit 被限流（7.2） | 重试 + 回退链执行、错误已报告 | Agent 因 429 崩溃 | P1 |
| **故障** | Seedance API 宕机（7.3） | 交付 4/5 交付物、视频部分省略 | 所有交付物被视频故障阻塞 | P0 |
| **故障** | 飞书断开（7.4） | 管线继续执行、重连后消息交付 | 管线中断或数据丢失 | P0 |
| **故障** | VOC 坏 JSON（7.5） | 畸形数据在 Lead 处拦截、不转发 | GEO/TikTok 收到垃圾数据 | P0 |
| **故障** | 全部 Agent 超时（7.6） | Lead 向人类升级并附诊断信息、不死锁 | Lead 死锁或发送空报告 | P0 |

---

## 9. 测试执行手册

### 9.1 前置条件检查清单

运行任何测试前，验证以下所有项目：

- [ ] **全部 5 个 Agent 运行中**：`openclaw agent list` 显示 lead、voc-analyst、geo-optimizer、reddit-spec、tiktok-director 均为 `running` 状态
- [ ] **OpenClaw 运行时正常**：`openclaw status` 返回 healthy
- [ ] **openclaw.json 已配置**：所有 Agent 条目存在，工作区路径和模型分配正确
- [ ] **Skill 已安装**：运行 Skill 验证表（1.2 节）—— 所有 P0 Skill 必须通过
- [ ] **API 密钥已配置**：1.3 节所有环境变量已配置有效（非占位符）值
- [ ] **飞书应用已连接**：至少 Lead 飞书应用有有效（非占位符）的 appId 和 appSecret；WebSocket 连接已建立
- [ ] **工作区目录存在**：`~/.openclaw/` 下全部 5 个工作区目录存在且包含 SOUL.md 文件
- [ ] **磁盘空间**：至少 5 GB 可用（TikTok 视频生成需要临时存储）
- [ ] **网络连通性**：可出站访问 Volcengine（Seedance、doubao）、Moonshot（Kimi K2.5）、Brave Search、Reddit、Amazon API
- [ ] **测试隔离**：工作区 `data/` 目录中无生产数据（或已备份）

### 9.2 测试执行顺序

测试必须按此顺序执行，因为后续阶段依赖前置阶段通过：

```
阶段 1：冒烟测试（5 分钟）
  1.1 Agent 健康检查（全部 5 个 Agent）
  1.2 Skill 验证（所有必需 Skill）
  1.3 环境变量验证
  1.4 sessions_send 连通性测试
  --> 任一 P0 冒烟测试失败则停止。修复后再继续。

阶段 2：单元测试（60-90 分钟）
  2.1 VOC Analyst 测试（V1-V6）—— 约 20 分钟
  2.2 GEO Optimizer 测试（G1-G6）—— 约 35 分钟
  2.3 Reddit Specialist 测试（R1-R6）—— 约 15 分钟
  2.4 TikTok Director 测试（T1-T5）—— 约 90 分钟（最耗时）
  --> VOC + Reddit 可并行运行（不同 Agent，无依赖）
  --> GEO 在 VOC V1 通过后运行（GEO 需要 VOC 格式数据）
  --> TikTok 测试独立运行（耗时最长）
  --> 任一 P0 单元测试失败则停止。修复后再继续。

阶段 3：集成测试（30-40 分钟）
  3.1 Lead -> VOC 派发测试
  3.2 Lead -> GEO 派发测试
  3.3 Lead -> Reddit 派发测试
  3.4 Lead -> TikTok 派发测试
  3.5 VOC -> GEO 数据流测试（需 3.1 + 3.2 通过）
  3.6 VOC -> TikTok 数据流测试（需 3.1 + 3.4 通过）
  --> 3.1-3.4 按顺序执行（均经过 Lead）
  --> 3.5 和 3.6 在依赖通过后执行
  --> 任一 P0 集成测试失败则停止。修复后再继续。

阶段 4：E2E 场景（40-60 分钟）
  4.1 行军床全管线（旗舰场景）—— 约 20 分钟
  4.2 蓝牙耳机部分管线 —— 约 12 分钟
  4.3 便携榨汁机全管线 —— 约 20 分钟
  --> 按顺序运行以避免资源争用

阶段 5：故障注入测试（30-40 分钟）
  5.1 VOC 超时测试
  5.2 Reddit 限流测试
  5.3 Seedance API 宕机测试
  5.4 飞书断开测试
  5.5 VOC 坏 JSON 测试
  5.6 全部 Agent 超时测试
  --> 按顺序运行；每个测试会修改系统状态
  --> 每个测试后恢复系统到正常状态
```

**总预计耗时**：完整套件 3-4 小时

### 9.3 各测试类别执行方法

#### 冒烟测试
```bash
# 运行全部冒烟测试
openclaw test smoke --config ~/.openclaw/openclaw.json --verbose

# 或逐个运行
openclaw agent ping lead
openclaw agent ping voc-analyst
openclaw agent ping geo-optimizer
openclaw agent ping reddit-spec
openclaw agent ping tiktok-director

# Skill 验证
for skill in decodo reddit-readonly brave-search apify tavily firecrawl \
            nano-banana-pro seedance-video manga-style-video manga-drama \
            volcengine-video-understanding; do
  openclaw skill test $skill && echo "$skill: PASS" || echo "$skill: FAIL"
done

# 环境变量检查
for var in DECODO_AUTH_TOKEN BRAVE_API_KEY APIFY_TOKEN TAVILY_API_KEY \
           FEISHU_WEBHOOK_URL; do
  test -n "${!var}" && echo "$var: SET" || echo "$var: MISSING"
done
```

#### 单元测试
```bash
# VOC 测试 —— 通过 sessions_send 发送测试载荷
openclaw test unit --agent voc-analyst --test-suite plans/test-payloads/voc-tests.json

# GEO 测试
openclaw test unit --agent geo-optimizer --test-suite plans/test-payloads/geo-tests.json

# Reddit 测试
openclaw test unit --agent reddit-spec --test-suite plans/test-payloads/reddit-tests.json

# TikTok 测试
openclaw test unit --agent tiktok-director --test-suite plans/test-payloads/tiktok-tests.json
```

#### 集成测试
```bash
# 运行集成测试套件（通过 Lead 发送消息，验证往返通信）
openclaw test integration --config ~/.openclaw/openclaw.json \
  --test-suite plans/test-payloads/integration-tests.json \
  --timeout 1200  # 20 分钟超时
```

#### E2E 测试
```bash
# 行军床场景
openclaw test e2e --scenario "camping-cot" \
  --trigger "Feishu message" \
  --message "分析行军折叠床市场，全渠道内容推送" \
  --timeout 1200

# 蓝牙耳机场景
openclaw test e2e --scenario "bluetooth-earbuds" \
  --trigger "Feishu message" \
  --message "调研蓝牙耳机，写内容，布局 Reddit，不需要视频" \
  --timeout 900

# 便携榨汁机场景
openclaw test e2e --scenario "portable-blender" \
  --trigger "Feishu message" \
  --message "全管线：便携榨汁机，全渠道，TikTok 风格 japanese" \
  --timeout 1200
```

#### 故障注入测试
```bash
# 每个故障测试需要配置、执行和清理
# 使用故障注入框架运行
openclaw test failure --test voc-timeout --setup "kill voc-analyst after 30s"
openclaw test failure --test reddit-429 --setup "mock reddit-readonly to return 429"
openclaw test failure --test seedance-down --setup "block seedance API endpoint"
openclaw test failure --test feishu-disconnect --setup "disconnect WebSocket after dispatch"
openclaw test failure --test bad-voc-json --setup "inject malformed JSON in voc-analyst response"
openclaw test failure --test all-timeout --setup "kill all worker agents after dispatch"
```

### 9.4 结果收集与审查方法

**日志位置**：
```
~/.openclaw/workspace-lead/logs/          # Lead Agent 日志
~/.openclaw/workspace-voc/logs/           # VOC Agent 日志 + scrape_log.jsonl
~/.openclaw/workspace-geo/data/quality-logs/  # GEO 质量评分历史
~/.openclaw/workspace-reddit/logs/        # Reddit Agent 日志
~/.openclaw/workspace-reddit/data/monitoring/  # Shadowban 检查、评论表现
~/.openclaw/workspace-tiktok/data/performance-log.json  # TikTok QA 评分、渲染耗时
```

**结果收集脚本**：
```bash
#!/bin/bash
# 将所有测试结果收集到单个目录
RESULTS_DIR="test-results/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RESULTS_DIR"

# 复制 Agent 日志
for ws in workspace-lead workspace-voc workspace-geo workspace-reddit workspace-tiktok; do
  mkdir -p "$RESULTS_DIR/$ws"
  cp -r ~/.openclaw/$ws/logs/* "$RESULTS_DIR/$ws/" 2>/dev/null
done

# 复制 GEO 质量日志
cp ~/.openclaw/workspace-geo/data/quality-logs/score-history.jsonl "$RESULTS_DIR/geo-scores.jsonl" 2>/dev/null

# 复制 TikTok 性能日志
cp ~/.openclaw/workspace-tiktok/data/performance-log.json "$RESULTS_DIR/tiktok-performance.json" 2>/dev/null

# 复制 VOC 爬取日志
cp ~/.openclaw/workspace-voc/data/logs/scrape_log.jsonl "$RESULTS_DIR/voc-scrape-log.jsonl" 2>/dev/null

# 生成摘要
echo "Test run completed at $(date)" > "$RESULTS_DIR/SUMMARY.md"
echo "Results directory: $RESULTS_DIR"
```

**审查清单**：
1. 检查 `SUMMARY.md` 了解总体通过/失败数
2. 审查所有 FAIL 结果 —— 查看具体 Agent 日志了解错误详情
3. GEO 测试：检查 `geo-scores.jsonl` 了解评分分布
4. TikTok 测试：检查 `tiktok-performance.json` 了解 QA 评分和渲染耗时
5. VOC 测试：检查 `voc-scrape-log.jsonl` 了解爬取成功率
6. 交叉比对时间戳验证耗时基准
7. 检查错误日志中是否有未处理异常

### 9.5 测试运行中故障处理方法

| 故障类型 | 处理方式 |
|---------|---------|
| P0 冒烟测试失败 | 停止所有测试。修复根因（Agent 宕机、Skill 缺失、环境变量未设置）。重新运行冒烟套件。 |
| P0 单元测试失败 | 停止该 Agent 的测试。使用 Agent 日志调试。修复并重新运行该特定测试。继续其他 Agent。 |
| P1 单元测试失败 | 记录故障。继续剩余测试。在所有 P0 测试通过后再处理。 |
| 集成测试失败 | 检查发送方和接收方 Agent 日志。验证 sessions_send 正常（重新运行连通性冒烟测试）。检查消息载荷中的 schema 不匹配。 |
| E2E 测试失败 | 从 Lead 的汇总日志中识别失败步骤。单独运行失败步骤的集成测试。检查时间问题（若接近阈值则增加超时）。 |
| 故障注入测试失败 | 验证故障已正确注入（确认模拟的故障确实发生了）。审查 Agent 的错误处理代码路径。 |
| 测试基础设施问题 | 若 OpenClaw 运行时本身不稳定，重启运行时并从冒烟测试重新开始。 |

---

## 10. 监控与可观测性

### 10.1 Agent 健康仪表盘（概念）

为每个 Agent 在集中仪表盘中跟踪以下指标：

| 指标 | lead | voc-analyst | geo-optimizer | reddit-spec | tiktok-director |
|------|:----:|:-----------:|:-------------:|:-----------:|:---------------:|
| **状态** | alive/dead | alive/dead | alive/dead | alive/dead | alive/dead |
| **最后心跳** | 时间戳 | 时间戳 | 时间戳 | 时间戳 | 时间戳 |
| **活跃任务数** | 数量 | 数量 | 数量 | 数量 | 数量 |
| **已完成任务（24h）** | 数量 | 数量 | 数量 | 数量 | 数量 |
| **错误率（24h）** | % | % | % | % | % |
| **平均响应时间** | 秒 | 秒 | 秒 | 秒 | 秒 |
| **模型 API 延迟** | 毫秒 | 毫秒 | 毫秒 | 毫秒 | 毫秒 |
| **Token 用量（24h）** | 数量 | 数量 | 数量 | 数量 | 数量 |
| **预估成本（24h）** | 元 | 元 | 元 | 元 | 元 |

**实现方式**：使用轻量监控脚本每 60 秒轮询各 Agent 健康端点并将指标写入 JSON 文件。使用简单 HTML 仪表盘或终端工具可视化。

### 10.2 日志聚合策略

每个 Agent 将日志写入自己的工作区。集中查看方式：

```
日志来源：
  ~/.openclaw/workspace-lead/logs/agent-activity.log
  ~/.openclaw/workspace-voc/logs/scrape_log.jsonl
  ~/.openclaw/workspace-voc/data/logs/scrape_log.jsonl
  ~/.openclaw/workspace-geo/data/quality-logs/score-history.jsonl
  ~/.openclaw/workspace-reddit/logs/agent-activity.log
  ~/.openclaw/workspace-reddit/data/monitoring/alerts.jsonl
  ~/.openclaw/workspace-tiktok/data/performance-log.json

聚合方案：
  1. 每个 Agent 以 JSONL 格式记录日志（每行一个 JSON 对象）
  2. 定时任务（每 5 分钟）从所有日志文件中追尾新条目
  3. 条目打上 agent_id 标签后写入中央日志：
     ~/.openclaw/logs/aggregated.jsonl
  4. 中央日志可使用 jq 查询调试：
     cat ~/.openclaw/logs/aggregated.jsonl | jq 'select(.agent=="voc-analyst" and .level=="error")'
```

**日志格式标准**（所有 Agent 应遵循）：
```json
{
  "timestamp": "2026-03-05T14:30:00+08:00",
  "agent": "voc-analyst",
  "level": "info|warn|error",
  "event": "scrape_complete|task_received|task_completed|error_occurred",
  "message": "人类可读描述",
  "metadata": {
    "request_id": "req_20260305_001",
    "duration_ms": 4200,
    "tool": "decodo/amazon_search"
  }
}
```

### 10.3 告警触发条件

| 告警 | 条件 | 严重级别 | 通知渠道 | 处理方式 |
|------|------|:-------:|:------:|---------|
| Agent 宕机 | 健康检查连续 3 次失败 | 严重 | 飞书 + Telegram | 重启 Agent，排查根因 |
| 任务超时 | 任一任务超过最大可接受时间 2 倍 | 高 | 飞书 | 检查 Agent 日志，可能 API 问题 |
| 错误率飙升 | Agent 滚动 1 小时错误率 > 20% | 高 | 飞书 | 审查错误日志，检查 API 状态 |
| 模型 API 错误 | 模型返回 5xx 或配额超限 | 高 | 飞书 + Telegram | 检查 API 仪表盘，切换备用模型（如有） |
| 爬取失败率 | VOC 24 小时爬取成功率 < 70% | 中 | 飞书 | 检查平台可访问性，更新爬取配置 |
| GEO 质量下降 | 最近 10 篇输出平均 GEO 评分 < 75 | 中 | 飞书 | 审查规则引擎，检查引用来源可用性 |
| Reddit 账号告警 | 检测到 shadowban 或版主操作 | 高 | 飞书 | 暂停账号活动，执行恢复协议 |
| TikTok QA 失败率 | > 40% 的视频首次 QA 失败 | 中 | 飞书 | 审查分镜模板，检查 Seedance 输出质量 |
| 磁盘空间不足 | Mac Mini 可用空间 < 2 GB | 高 | 飞书 + Telegram | 清理旧视频文件，归档报告 |
| 成本超限 | 日 API 成本超预算 50% | 中 | 飞书 | 审查 token 用量，识别高开销操作 |

### 10.4 每 Agent 每任务的 Token/成本追踪

**追踪 Schema**（附加到每个任务的元数据中）：
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

**每日成本汇总**（定时任务于 23:59 执行）：
```
报告格式：
  日期：2026-03-05
  总任务数：12
  总成本：45.60 元（$6.30 USD）

  按 Agent：
    lead：           2.10 元（仅模型 token）
    voc-analyst：    8.40 元（模型 + 爬取 API）
    geo-optimizer：  5.20 元（模型 + 搜索 API）
    reddit-spec：    3.80 元（模型 + 搜索 API）
    tiktok-director：26.10 元（模型 + 图片 + 视频生成）

  按成本类型：
    模型 API：      18.50 元
    图片生成：       7.20 元
    视频生成：      15.00 元
    搜索 API：       3.50 元
    爬取 API：       1.40 元
```

### 10.5 Mac Mini 基础监控配置

**步骤一：健康检查定时任务**
```bash
# 添加到 crontab：每 2 分钟运行
*/2 * * * * ~/.openclaw/scripts/health-check.sh >> ~/.openclaw/logs/health-check.log 2>&1
```

**health-check.sh**：
```bash
#!/bin/bash
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S%z)
for agent in lead voc-analyst geo-optimizer reddit-spec tiktok-director; do
  STATUS=$(openclaw agent ping $agent --timeout 5 2>/dev/null)
  if [ $? -eq 0 ]; then
    echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$agent\",\"status\":\"alive\"}"
  else
    echo "{\"timestamp\":\"$TIMESTAMP\",\"agent\":\"$agent\",\"status\":\"dead\"}"
    # Agent 宕机时发送告警
    curl -s -X POST "$FEISHU_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"ALERT: Agent $agent is DOWN at $TIMESTAMP\"}}"
  fi
done
```

**步骤二：日志聚合定时任务**
```bash
# 每 5 分钟运行
*/5 * * * * ~/.openclaw/scripts/aggregate-logs.sh >> /dev/null 2>&1
```

**步骤三：每日成本报告定时任务**
```bash
# 每日 23:59 运行
59 23 * * * ~/.openclaw/scripts/daily-cost-report.sh >> ~/.openclaw/logs/cost-reports.log 2>&1
```

**步骤四：磁盘空间监控**
```bash
# 每小时运行
0 * * * * df -h / | awk 'NR==2{if(int($5)>90) system("curl -s -X POST $FEISHU_WEBHOOK_URL -H \"Content-Type: application/json\" -d \"{\\\"msg_type\\\":\\\"text\\\",\\\"content\\\":{\\\"text\\\":\\\"ALERT: Disk usage at " $5 "\\\"}}\"")}'
```

**仪表盘访问**：在浏览器中打开 `~/.openclaw/dashboard/index.html` 查看健康仪表盘（一个简单的 HTML 页面，读取 JSONL 健康检查日志并渲染状态卡片）。

---

## 附录 A：测试数据文件

测试载荷应保存到 `/Users/kinghinchan/e-commerce-claw/plans/test-payloads/`，并被测试执行脚本引用。第 2-5 节中的每个测试场景应有对应的 JSON 载荷文件。

## 附录 B：术语表

| 术语 | 定义 |
|------|------|
| sessions_send | OpenClaw 原生的 Agent 间异步通信协议 |
| 暗通道（Dark Track） | 通过 sessions_send 进行的 Agent 间数据交换（用户不可见） |
| 明通道（Light Track） | 通过飞书消息发送的人类可见进度更新 |
| GEO Score | AI 搜索优化内容的质量指标（0-100） |
| QA Composite | TikTok 视频的加权质量评分（0-10） |
| VOCReport | VOC Analyst 输出的结构化 JSON 市场分析数据 |
| DAG | 有向无环图 —— Lead 用于编排的任务依赖结构 |
| SOP | 标准操作流程 —— Reddit 账号 5 周培育协议 |
| 流量截取（Traffic Hijacking） | 在 Google 高排名的 Reddit 旧帖下评论，截取自然搜索流量 |
| 呼吸感运镜（Breathing Movement） | 运镜标记（BM）—— 手持式 2-3 度摆动，营造 UGC 质感 |

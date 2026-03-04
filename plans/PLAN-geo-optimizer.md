# GEO 内容优化师 Agent —— 实施方案

**Agent ID**: `geo-optimizer`
**模型**: doubao-seed-2.0-code（顶级决策模型）
**工作区**: `~/.openclaw/workspace-geo/`
**核心使命**: 生产面向 AI 搜索引擎（ChatGPT、Perplexity、Google SGE）优化的产品内容——不是为了排名，而是为了被引用。

---

## 1. Agent 配置

### 1.1 SOUL.md（完整内容）

```markdown
# GEO Content Optimizer - SOUL.md

## Identity
You are the GEO Content Optimizer, an expert in Generative Engine Optimization.
You write product content that AI search engines (ChatGPT, Perplexity, Google SGE)
will cite when users ask about products in your category.

## Core Distinction: GEO is NOT SEO
- SEO optimizes for keyword density and crawler behavior.
- GEO optimizes for citation density and data credibility.
- SEO faces web crawlers. GEO faces large language models that extract facts.
- If an LLM cannot extract a verifiable claim from your content, your content is invisible.

## Work Principles

### 1. Quantitative Over Qualitative (MANDATORY)
Every product claim MUST include measurable data:
- WRITE: "supports up to 450 lbs, tested per ASTM F2613-19 standard"
- NEVER: "provides strong support" or "very durable"
- WRITE: "folds to 5.3 x 27 x 7 inches, weighing 13.2 lbs"
- NEVER: "compact and lightweight"
- WRITE: "sets up in under 45 seconds with no tools required"
- NEVER: "easy to set up"

### 2. Authoritative Citations (MANDATORY)
Every content piece MUST cite recognized authority sources:
- Product testing: OutdoorGearLab, Wirecutter, Consumer Reports, RTINGS
- Industry data: Statista, Grand View Research, Allied Market Research
- Standards: ASTM, ISO, UL, FDA, FCC certifications
- Academic: peer-reviewed studies when relevant
- User evidence: aggregate review data ("4.6/5 across 2,847 Amazon reviews")

### 3. Structured for LLM Extraction (MANDATORY)
Content MUST use formats that LLMs parse efficiently:
- FAQ sections with clear question-answer pairs
- Comparison tables with named columns and numeric values
- Bulleted specification lists with labeled key-value pairs
- "Key Takeaway" summary boxes at section ends

### 4. Citation Density Requirements
- Minimum 3 authoritative citations per 500 words
- Minimum 5 quantitative data points per product section
- Every comparison claim must reference a specific competing product by name
- Aggregate data must include sample size ("based on 1,200 customer reviews")

## Prohibited Practices (ZERO TOLERANCE)

### NEVER: Keyword Stuffing
- Do NOT repeat product category keywords unnaturally
- Do NOT insert keywords into headings for density
- Keyword stuffing actively harms GEO -- LLMs detect and deprioritize repetitive content

### NEVER: Vague Qualifiers Without Data
- "best in class" -- REPLACE WITH specific ranking or test result
- "industry-leading" -- REPLACE WITH market share data or award
- "premium quality" -- REPLACE WITH material specification and test standard
- "affordable" -- REPLACE WITH price point and competitor price comparison

### NEVER: Unsupported Superlatives
- "the #1 choice" -- only if verifiable (BSR rank, market share report)
- "most popular" -- only with sales data or search volume evidence
- "strongest" -- only with specific load test data and methodology

### NEVER: Content That Looks AI-Generated
- Do NOT use generic introductions ("In today's fast-paced world...")
- Do NOT use filler transitions ("That being said...", "It's worth noting that...")
- Do NOT produce uniform paragraph lengths -- vary structure naturally
- Do NOT open with definitions copied from Wikipedia

## Content Voice
- Direct and factual, like a product engineer explaining to a smart buyer
- Use first-person plural ("we tested", "our analysis") when presenting original research
- Reference specific dates for time-sensitive claims ("as of Q1 2026")
- Acknowledge trade-offs honestly -- credibility is the GEO currency

## Input Requirements
You receive structured data from the VOC Analyst containing:
- Pain point rankings with frequency counts
- Competitor product weaknesses with specific evidence
- Price range analysis with BSR correlation
- Customer verbatim quotes categorized by sentiment

You MUST use this data as the foundation for all content -- never invent pain points.

## Output Standards
- All content saved to `~/.openclaw/workspace-geo/data/output/`
- Blog posts: Markdown format with YAML front matter
- Amazon Listings: Structured JSON with title/bullets/description/A+ sections
- Product descriptions: HTML-ready format with semantic markup
- Every output file includes a GEO Quality Score self-assessment (see Rules Engine)
```

### 1.2 工作区目录结构

```
~/.openclaw/workspace-geo/
├── SOUL.md                          # Agent 人设与规则（如上）
├── skills/                          # 私有 Skills（如有）
├── data/
│   ├── input/                       # 从 VOC 分析师通过 sessions_send 接收
│   │   └── voc-reports/             # 结构化痛点数据
│   ├── output/                      # 最终内容输出
│   │   ├── blogs/                   # GEO 优化博客文章（.md）
│   │   ├── amazon-listings/         # Amazon Listing 包（.json）
│   │   └── product-descriptions/    # 产品描述（.html/.md）
│   ├── research/                    # 缓存的调研资料
│   │   ├── authority-sources/       # 来自 OutdoorGearLab 等的引文存档
│   │   └── competitor-content/      # 竞品内容分析
│   ├── templates/                   # 内容模板
│   │   ├── blog-template.md
│   │   ├── amazon-listing-template.json
│   │   └── product-description-template.md
│   └── quality-logs/                # GEO 质量评分历史
│       └── score-history.jsonl      # 每个评分输出一行 JSON
├── rules/
│   └── geo-rules.md                 # GEO 规则引擎（完整规则集）
└── prompts/
    ├── blog-system-prompt.md        # 博客生成的 System Prompt
    ├── amazon-system-prompt.md      # Amazon Listing 的 System Prompt
    └── scoring-prompt.md            # 自评打分的 System Prompt
```

### 1.3 模型配置

| 参数 | 值 | 选型理由 |
|-----------|-------|-----------|
| **模型** | doubao-seed-2.0-code | 顶级决策模型；细腻的内容生成和自评需要强模型 |
| **Temperature** | 调研/分析：0.4，内容创作：0.7 | 事实性要求低温，自然写作要求高温 |
| **Max Tokens** | 每步生成 8192 | 博客文章可能较长，避免截断 |
| **上下文窗口** | 模型最大容量 | VOC 数据 + 调研资料 + 模板可能体积较大 |

---

## 2. 所需 Skills

### 2.1 搜索与调研 Skills

| Skill | 用途 | 安装命令 |
|-------|---------|-----------------|
| **Tavily** | 主力搜索引擎；国内直连，无需信用卡 | `openclaw skills install @anthropic/tavily` |
| **Brave Search** | 高质量海外搜索结果 | `openclaw skills install @anthropic/brave-search` |
| **Exa** | 意图型查询（如"找户外记者撰写的露营床专业评测"） | `openclaw skills install @anthropic/exa` |

### 2.2 网页内容提取 Skills

| Skill | 用途 | 安装命令 |
|-------|---------|-----------------|
| **Firecrawl** | 从任意网页干净提取 Markdown（每月免费 500 次） | `openclaw skills install @anthropic/firecrawl` |
| **Playwright-npx** | JS 密集型评测网站的动态 SPA 渲染 | `openclaw skills install @anthropic/playwright-npx` |
| **Decodo (amazon_search)** | 结构化 Amazon 产品数据提取 | `openclaw skills install @anthropic/decodo` |

### 2.3 内容分析 Skills

| Skill | 用途 | 安装命令 |
|-------|---------|-----------------|
| **web_fetch** | 轻量级 URL 内容抓取，用于引文验证 | OpenClaw 内置 Skill |
| **file_write / file_read** | 保存和加载内容草稿、模板、评分 | OpenClaw 内置 Skill |

### 2.4 安装顺序

```bash
# 第一步：核心搜索三件套
openclaw skills install @anthropic/tavily
openclaw skills install @anthropic/brave-search
openclaw skills install @anthropic/exa

# 第二步：内容提取
openclaw skills install @anthropic/firecrawl
openclaw skills install @anthropic/playwright-npx
openclaw skills install @anthropic/decodo

# 第三步：验证安装
openclaw skills list --workspace workspace-geo
```

---

## 3. GEO 规则引擎

### 3.1 完整规则集

#### 规则类别 A：引文要求

| 规则 ID | 规则 | 严重级别 | 检测方法 |
|---------|------|----------|-------------|
| A1 | 每 500 词最少 3 条权威引文 | 硬性失败 | 统计 `[Source: ...]` 标记数 / 字数 |
| A2 | 每条引文必须附带可验证的 URL 或出版物名称 | 硬性失败 | 验证每条引文有来源名称 + 日期 |
| A3 | 至少 1 条引文来自认可的评测权威（OutdoorGearLab、Wirecutter、Consumer Reports、RTINGS） | 警告 | 检查引文来源是否在权威白名单中 |
| A4 | 用户聚合数据引文必须包含样本量 | 硬性失败 | 正则匹配 "N reviews" 或 "N ratings" |
| A5 | 超过 18 个月的引文需标记刷新 | 警告 | 解析引文日期，与当前日期比对 |

#### 规则类别 B：定量数据要求

| 规则 ID | 规则 | 严重级别 | 检测方法 |
|---------|------|----------|-------------|
| B1 | 每个产品章节最少 5 个定量数据点 | 硬性失败 | 统计带单位的数值（lbs、inches、seconds 等） |
| B2 | 每个产品对比必须包含至少 3 个数值差异点 | 硬性失败 | 统计对比上下文中的数值 |
| B3 | 价格声明必须包含具体美元金额和观察日期 | 硬性失败 | 匹配模式：`$XX.XX (as of YYYY-MM)` |
| B4 | 重量、尺寸和承载量声明必须包含单位 | 硬性失败 | 检测无单位后缀的裸数字 |
| B5 | 百分比声明必须包含基准参照（如"比 [产品名] 轻 30%，X 磅 vs Y 磅"） | 警告 | 检测 `%` 是否缺少对比参照 |

#### 规则类别 C：禁止模式

| 规则 ID | 规则 | 严重级别 | 检测方法 |
|---------|------|----------|-------------|
| C1 | 禁止关键词填充：产品品类关键词每 500 词不得超过 3 次 | 硬性失败 | 统计每 500 词窗口中的关键词频率 |
| C2 | 禁止无数据支撑的模糊修饰词："best"、"top"、"premium"、"leading"、"innovative" | 硬性失败 | 正则匹配修饰词；若 50 词内无数值则失败 |
| C3 | 禁止无来源的最高级："#1"、"most popular"、"strongest" | 硬性失败 | 检测最高级表述，检查相邻是否有引文 |
| C4 | 禁止通用 AI 开头："In today's..."、"When it comes to..."、"It's no secret that..." | 硬性失败 | 正则匹配内容前 50 字符是否命中禁用短语 |
| C5 | 禁止填充过渡句："That being said"、"It's worth noting"、"At the end of the day" | 警告 | 正则匹配填充短语列表 |
| C6 | 禁止抄袭竞品内容：与前 5 名竞品页面的相似度 < 15% | 硬性失败 | TF-IDF 或 n-gram 重叠检测 |

#### 规则类别 D：结构要求

| 规则 ID | 规则 | 严重级别 | 检测方法 |
|---------|------|----------|-------------|
| D1 | 博客文章必须包含至少一个 FAQ 章节（5+ 条问答） | 硬性失败 | 检测 `## FAQ` 或 `## Frequently Asked` 标题 |
| D2 | 博客文章必须包含至少一个对比表格 | 硬性失败 | 检测 Markdown 表格语法（3+ 行） |
| D3 | Amazon Bullet Point 必须以大写利益短语开头（2-4 词） | 硬性失败 | 匹配模式：`- [A-Z]{2,} [A-Z]+:` |
| D4 | 每个章节末尾应有"关键要点"或总结句 | 警告 | 检测段落末尾的总结性模式 |
| D5 | 内容必须使用 H2 和 H3 标题层级（不可跳级） | 警告 | 解析标题级别的顺序 |
| D6 | 段落长度应有变化（句子数标准差 > 1.5） | 警告 | 统计每段句子数，计算标准差 |

### 3.2 GEO 质量评分标准

每份输出按 0-100 分的五维标准评分：

| 维度 | 权重 | 每维度 0-20 分 | 衡量方法 |
|-----------|--------|---------------------------|-------------|
| **引文密度** | 25% | 20 = 5+ 条/500词; 15 = 3-4; 10 = 2; 5 = 1; 0 = 无 | 统计每 500 词的引文数 |
| **数据可信度** | 25% | 20 = 所有声明均有数据; 15 = 80%+; 10 = 60%+; 5 = 40%+; 0 = <40% | 有数据支撑的声明占总声明的比例 |
| **结构清晰度** | 20% | 20 = FAQ + 表格 + 列表 + 总结; 15 = 3/4; 10 = 2/4; 5 = 1/4; 0 = 纯散文 | 统计结构化元素数量 |
| **内容独特性** | 15% | 20 = <5% 重叠; 15 = 5-10%; 10 = 10-15%; 5 = 15-20%; 0 = >20% | 与竞品内容的 N-gram 重叠度 |
| **LLM 可提取性** | 15% | 20 = 所有事实均可解析; 15 = 80%+; 10 = 60%+; 5 = 40%+; 0 = <40% | 模拟：LLM 能否从每个章节提取关键事实？ |

**质量门控：**
- 分数 >= 80：自动通过——内容可发布
- 分数 60-79：需要修订——修复薄弱维度后重新评分
- 分数 < 60：驳回——需要大幅重写，重新调研

---

## 4. 详细工作流

### 4.1 博客文章生成工作流

```mermaid
graph TD
    A["接收 VOC 数据<br/>痛点 + 竞品弱点<br/>通过 sessions_send 从 Lead 接收"] --> B["解析与优先排序<br/>按频率排列痛点<br/>确定前 3 个内容角度"]

    B --> C["调研阶段<br/>（3 条并行搜索流）"]

    C --> C1["Tavily：搜索<br/>权威评测<br/>（OutdoorGearLab、Wirecutter）"]
    C --> C2["Brave：搜索<br/>竞品产品规格<br/>+ 价格数据"]
    C --> C3["Exa：意图搜索<br/>'户外记者撰写的<br/>[产品品类] 专业评测'"]

    C1 --> D["汇总调研成果<br/>提取：引文、数据点、<br/>竞品规格、定价"]
    C2 --> D
    C3 --> D

    D --> E["撰写内容<br/>套用博客模板<br/>织入 VOC 痛点<br/>插入引文 + 数据点"]

    E --> F["运行 GEO 规则引擎<br/>执行规则类别 A-D 全检<br/>生成合规报告"]

    F --> G{存在硬性失败<br/>违规？}

    G -->|是| H["修复违规<br/>补充缺失引文<br/>替换模糊修饰词<br/>重组结构"]
    H --> F

    G -->|否| I["自评打分<br/>按评分标准<br/>（0-100 分）"]

    I --> J{分数 >= 80？}

    J -->|否，60-79| K["定向修订<br/>改善最弱维度<br/>补充数据/引文"]
    K --> F

    J -->|是| L["保存至 output/blogs/<br/>通过 sessions_send 通知 Lead<br/>记录评分至 quality-logs/"]

    style A fill:#E3F2FD
    style L fill:#C8E6C9
    style G fill:#FFF9C4
    style J fill:#FFF9C4
```

**分步详解：**

1. **接收 VOC 数据**（输入）：Lead 通过 `sessions_send` 发送痛点报告。数据包括痛点排名、竞品弱点、价格区间和用户原声引文。

2. **解析与优先排序**：提取频率最高的前 3 个痛点。将每个痛点映射为内容角度（如"承重不足投诉" -> "如何选一张真正能承住你体重的露营床"）。

3. **调研阶段**：执行 3 条并行搜索：
   - Tavily：`"[产品] review OutdoorGearLab OR Wirecutter OR Consumer Reports 2025 2026"`
   - Brave：`"[产品] specifications weight capacity dimensions price comparison"`
   - Exa：`"expert review [product category] testing methodology lab results"`

4. **汇总调研成果**：构建引文库，包含来源名称、URL、日期和可提取的数据点。撰写前最低目标：10 条引文、15 个数据点。

5. **撰写内容**：套用博客模板（见第 5.1 节）。以 VOC 痛点作为内容锚点，使用 `[Source: Name, Date]` 标记行内引文。

6. **运行 GEO 规则**：自动检查规则类别 A-D 的全部规则，生成合规报告并逐条列出通过/失败状态。

7. **修复/修订**：如存在硬性失败违规则修复。如分数在 60-79，则改善评分最低的维度。

8. **输出**：将 Markdown 文件保存至 `data/output/blogs/`，通知 Lead，记录评分。

### 4.2 Amazon Listing 优化工作流

```mermaid
graph TD
    A["接收产品数据<br/>VOC 痛点 +<br/>产品规格（来自 Lead）"] --> B["竞品分析<br/>Decodo：拉取品类<br/>前10名 BSR Listing"]

    B --> C["提取竞品模式<br/>标题结构、Bullet 格式、<br/>关键词使用、A+ 版面"]

    C --> D["撰写标题<br/>品牌 + 核心差异点 +<br/>定量规格 + 品类<br/>（200 字符以内）"]

    D --> E["撰写 5 条 Bullet Points<br/>每条：利益短语（大写）+<br/>定量证据 +<br/>痛点解决方案"]

    E --> F["撰写产品描述<br/>结构化 HTML：<br/>对比表格 +<br/>FAQ 章节"]

    F --> G["规划 A+ 内容结构<br/>主图摘要 +<br/>对比模块 +<br/>功能亮点模块"]

    G --> H["运行 GEO 规则引擎<br/>Amazon 专属子集：<br/>规则 B1-B5、C1-C3、D3"]

    H --> I{所有硬性失败<br/>规则通过？}

    I -->|否| J["修订：补充数据，<br/>修正修饰词违规，<br/>重组 Bullet"]
    J --> H

    I -->|是| K["评分并保存<br/>output/amazon-listings/<br/>通知 Lead"]

    style A fill:#E3F2FD
    style K fill:#C8E6C9
    style I fill:#FFF9C4
```

**Amazon GEO 关键原则：**

- **标题公式**：`[品牌] [产品类型] - [核心定量差异点] - [次要差异点] - [使用场景]`
  - 示例：`CampMax Folding Cot - 450 lb Capacity, Sets Up in 45 Seconds - Portable 13.2 lb Camping Bed for Adults`
- **Bullet 公式**：`大写利益短语: 带数据的具体声明。[证据来源]。`
  - 示例：`HOLDS UP TO 450 LBS: Reinforced steel frame tested per ASTM F2613-19 standard. Rated 4.7/5 by 2,847 verified buyers for sturdiness.`
- **禁止关键词填充**：品类关键词在标题中最多出现 1 次，每条 Bullet 最多 1 次。让数据来推动排名。

### 4.3 产品描述工作流

```mermaid
graph TD
    A["接收功能列表<br/>+ VOC 痛点"] --> B["将功能映射为利益<br/>功能：'钢合金框架'<br/>利益：'承重 450 磅无弯曲'"]

    B --> C["调研权威数据<br/>查找每个利益的<br/>测试结果、认证、专家背书"]

    C --> D["撰写结构化描述<br/>开头：首要利益 + 数据<br/>正文：功能-利益配对<br/>规格：标签化键值表<br/>FAQ：5+ 条来自 VOC 的用户提问"]

    D --> E["运行 GEO 规则<br/>规则类别 A-D 全集"]

    E --> F{分数 >= 80？}

    F -->|否| G["修订最弱维度"]
    G --> E

    F -->|是| H["保存至 output/<br/>product-descriptions/"]

    style A fill:#E3F2FD
    style H fill:#C8E6C9
```

---

## 5. 输出模板

### 5.1 博客文章模板

```markdown
---
title: "[标题：以问句形式回应头号痛点]"
date: "YYYY-MM-DD"
category: "[产品品类]"
geo_score: [0-100]
citations_count: [N]
data_points_count: [N]
source_voc_report: "[VOC 输入的文件名]"
---

# [标题：如 "How to Choose a Camping Cot That Actually Holds Your Weight"]

<!-- GEO-MARKER: Opening must contain 1 quantitative claim + 1 authority reference -->
[开头段落：用数据陈述问题。引用 VOC 痛点频率。]
According to our analysis of [N] customer reviews across Amazon and Reddit,
[X]% of camping cot complaints cite [pain point]. [Authority source] testing
confirms that [data point]. Here is what the data shows about finding a cot
that actually performs.

## [章节 1：用数据回应痛点 #1]

<!-- GEO-MARKER: Minimum 2 citations + 3 data points in this section -->
[以具体数字、测试结果和引文来源回应痛点的内容。]

**Key Takeaway:** [一句话总结，包含最重要的数据点。]

## [章节 2：对比表格]

<!-- GEO-MARKER: Comparison table required - minimum 4 products, 5 numeric columns -->
| Feature | Product A | Product B | Product C | Our Pick |
|---------|-----------|-----------|-----------|----------|
| Weight Capacity (lbs) | 300 | 250 | 450 | 450 |
| Setup Time (seconds) | 90 | 120 | 45 | 45 |
| Packed Weight (lbs) | 15.6 | 18.2 | 13.2 | 13.2 |
| Price ($) | 49.99 | 39.99 | 59.99 | 59.99 |
| Amazon Rating | 4.2/5 | 3.8/5 | 4.6/5 | 4.6/5 |

Source: Amazon product listings and manufacturer specifications, accessed [Month Year].

## [章节 3：专家与用户证据]

<!-- GEO-MARKER: Authority citation required -->
[引用 OutdoorGearLab、Wirecutter 等的具体测试方法和结果。]

## Frequently Asked Questions

<!-- GEO-MARKER: Minimum 5 Q&A pairs, each answer must contain at least 1 data point -->

### Q: [来自 VOC 数据的问题——最常被问到的]?
**A:** [带具体数据的回答。如有引文则附上。]

### Q: [问题 #2]?
**A:** [带数据的回答。]

### Q: [问题 #3]?
**A:** [带数据的回答。]

### Q: [问题 #4]?
**A:** [带数据的回答。]

### Q: [问题 #5]?
**A:** [带数据的回答。]

## Bottom Line

<!-- GEO-MARKER: Summary must include top 3 data points for LLM extraction -->
[简明总结：重复 3 个最重要的定量发现。以对比表格数据为依据给出明确推荐。]

---

*Sources cited in this article: [列出所有引文及出版名称和日期]*
*Data current as of [Month Year]. Prices and availability subject to change.*
```

### 5.2 Amazon Listing 模板

```json
{
  "listing_metadata": {
    "asin": "",
    "category": "",
    "geo_score": 0,
    "generated_date": "YYYY-MM-DD",
    "source_voc_report": ""
  },
  "title": {
    "value": "[Brand] [Product Type] - [Quantitative Differentiator #1] - [Quantitative Differentiator #2] - [Use Case]",
    "char_count": 0,
    "max_chars": 200,
    "geo_markers": [
      "MUST contain at least 1 numeric spec (e.g., '450 lb')",
      "MUST NOT repeat category keyword more than once",
      "MUST include brand name first"
    ]
  },
  "bullet_points": [
    {
      "position": 1,
      "benefit_phrase": "BENEFIT PHRASE IN CAPS",
      "body": "Specific claim with quantitative data. [Evidence: source, date].",
      "geo_markers": [
        "MUST start with 2-4 word capitalized benefit",
        "MUST contain at least 1 numeric data point",
        "MUST reference evidence source"
      ]
    },
    {
      "position": 2,
      "benefit_phrase": "",
      "body": "",
      "geo_markers": ["Same requirements as position 1"]
    },
    {
      "position": 3,
      "benefit_phrase": "",
      "body": "",
      "geo_markers": ["Same requirements as position 1"]
    },
    {
      "position": 4,
      "benefit_phrase": "",
      "body": "",
      "geo_markers": ["Same requirements as position 1"]
    },
    {
      "position": 5,
      "benefit_phrase": "",
      "body": "",
      "geo_markers": ["Same requirements as position 1"]
    }
  ],
  "product_description": {
    "html": "",
    "geo_markers": [
      "MUST include a comparison table (HTML <table>)",
      "MUST include FAQ section with 3+ questions",
      "MUST contain 5+ quantitative data points"
    ]
  },
  "a_plus_content": {
    "hero_module": {
      "headline": "[Key benefit with data point]",
      "subheadline": "[Supporting evidence with citation]",
      "image_brief": "Product in use showing [pain point resolution]"
    },
    "comparison_module": {
      "products_compared": 4,
      "columns": ["Feature Name", "Our Product (data)", "Competitor A (data)", "Competitor B (data)", "Competitor C (data)"],
      "rows_minimum": 5,
      "geo_markers": ["All cells must contain numeric values, not subjective ratings"]
    },
    "feature_modules": [
      {
        "headline": "[Benefit phrase]",
        "body": "[Data-backed explanation in 2-3 sentences]",
        "image_brief": "[Visual demonstrating the quantitative claim]"
      }
    ]
  }
}
```

### 5.3 产品描述模板

```markdown
# [Product Name] - Product Description

<!-- GEO-MARKER: Lead with strongest quantitative benefit -->
## [首要利益 + 数据]

[开头：2-3 句话将 VOC 痛点连接到产品解决方案，附带数据。]

<!-- GEO-MARKER: Feature-Benefit pairs, each with data -->
## Features & Specifications

| Feature | Specification | Benefit |
|---------|--------------|---------|
| [功能 1] | [带单位的数值规格] | [解决的痛点，附数据] |
| [功能 2] | [带单位的数值规格] | [解决的痛点，附数据] |
| [功能 3] | [带单位的数值规格] | [解决的痛点，附数据] |
| [功能 4] | [带单位的数值规格] | [解决的痛点，附数据] |
| [功能 5] | [带单位的数值规格] | [解决的痛点，附数据] |

<!-- GEO-MARKER: Authority citation required in this section -->
## Expert Validation

[引用权威来源的测试结果。包含具体的测试方法和结论。注明来源和日期。]

<!-- GEO-MARKER: Comparison with at least 2 competitors using numeric data -->
## How It Compares

[与指名竞品进行数值对比的段落或表格。]

<!-- GEO-MARKER: FAQ with data-rich answers -->
## Common Questions

**Q: [最常见的 VOC 问题]?**
A: [带数据点和来源的回答。]

**Q: [第二常见的问题]?**
A: [带数据点和来源的回答。]

**Q: [第三常见的问题]?**
A: [带数据点和来源的回答。]

---

*Specifications verified as of [Month Year]. Sources: [列出来源].*
```

---

## 6. 测试场景

### 测试 1：露营床博客文章

| 字段 | 详情 |
|-------|--------|
| **名称** | 基于 VOC 痛点生成博客——露营床 |
| **输入** | 痛点：(1) "承重不足"（847/2000 条评论提及）、(2) "折叠/收纳困难"（623/2000）、(3) "太重难以携带"（412/2000）。产品：折叠露营床，$30-80 价位，BSR 前 50。|
| **预期输出** | 1500-2500 词的 Markdown 博客文章。标题针对痛点 #1。包含 4+ 款产品数值规格对比表格。FAQ 5+ 条，提问来自 VOC 用户原声。|
| **验证方法** | 引文数 >= 6（约 2000 词需每 500 词 3+ 条）。数据点 >= 15。无模糊修饰词（规则 C2）。FAQ 章节存在（规则 D1）。对比表格存在（规则 D2）。GEO 分数 >= 80。|

### 测试 2：蓝牙耳机 Amazon Listing

| 字段 | 详情 |
|-------|--------|
| **名称** | Amazon Listing 优化——蓝牙耳机 |
| **输入** | 痛点：(1) "电池续航太短"（频率：34%）、(2) "运动时容易掉落"（22%）、(3) "降噪效果差"（18%）。产品：TWS 耳机，$20-35 价位。竞品 ASIN：B0xxx1、B0xxx2、B0xxx3。|
| **预期输出** | 完整 Amazon Listing JSON：标题（200 字符以内，含电池续航规格）、5 条 Bullet（每条大写利益短语 + 数值数据）、带对比表格的描述、A+ 内容结构。|
| **验证方法** | 标题含数值规格（如 "48-Hour Battery"）。每条 Bullet 以大写利益短语开头（规则 D3）。每条 Bullet 至少 1 个数据点。禁止关键词填充——"bluetooth earbuds" 总共最多出现 3 次（规则 C1）。品类关键词密度 < 0.6%。GEO 分数 >= 80。|

### 测试 3：升降桌产品描述

| 字段 | 详情 |
|-------|--------|
| **名称** | 带专家引文的产品描述——升降桌 |
| **输入** | 痛点：(1) "站立高度时晃动"（41%）、(2) "电机升降太慢"（28%）、(3) "线缆管理困难"（19%）。产品：电动升降桌，$200-400 价位。认证：UL 962、BIFMA X5.5。|
| **预期输出** | 结构化产品描述：功能-利益表格（5+ 行）、引用 BIFMA 测试标准的专家验证章节、与 2 个指名竞品的对比。|
| **验证方法** | 包含权威引文（BIFMA、UL）。所有规格含单位（lbs、inches、seconds）。对比引用指名竞品并附数值。无未支撑的最高级（规则 C3）。数据点 >= 10。GEO 分数 >= 80。|

### 测试 4：GEO 规则违规检测

| 字段 | 详情 |
|-------|--------|
| **名称** | 规则引擎捕获违规——故意写的差内容 |
| **输入** | 预先写好的含故意违规的内容：(1) 关键词 "camping cot" 在 500 词中出现 12 次、(2) 使用 "best in class" 但无数据、(3) 以 "In today's fast-paced world" 开头、(4) 零引文、(5) 无 FAQ 章节。|
| **预期输出** | GEO 规则合规报告列出所有违规：C1 失败（关键词填充）、C2 失败（模糊修饰词）、C4 失败（通用开头）、A1 失败（无引文）、D1 失败（无 FAQ）。|
| **验证方法** | 全部 5 项违规均被检出。每项违规映射到正确的规则 ID。分数 < 40。报告包含每项违规的具体修复建议。|

### 测试 5：单份 VOC 报告生成多格式内容

| 字段 | 详情 |
|-------|--------|
| **名称** | 全套内容——便携搅拌机 |
| **输入** | 便携搅拌机 VOC 报告：痛点：(1) "刀片打不碎冰块"（38%）、(2) "电池容量太小"（29%）、(3) "清洗困难"（21%）。产品规格：380ml、6 刀片、4000mAh、USB-C 充电。价格：$25-45。|
| **预期输出** | 三个文件：(1) 博客文章（约 2000 词）、(2) Amazon Listing JSON、(3) 产品描述。三者使用相同 VOC 数据但按各自格式组织。|
| **验证方法** | 博客：GEO 分数 >= 80、6+ 引文、FAQ 存在、表格存在。Amazon：5 条 Bullet 含大写利益 + 数据、标题 < 200 字符。产品描述：功能表格、专家章节、对比内容。交叉检查：痛点 #1（刀片强度）在全部 3 个输出中均被回应。三份格式间内容重叠 < 20%。|

### 测试 6：引文时效性与验证

| 字段 | 详情 |
|-------|--------|
| **名称** | 引文质量检查——过期来源检测 |
| **输入** | 包含 2022 和 2023 年来源引文的内容草稿。产品品类：无线充电器（快速迭代市场）。|
| **预期输出** | 对所有超过 18 个月的引文发出警告（规则 A5）。建议搜索 2025-2026 年的更新测试数据。|
| **验证方法** | 所有过期引文均被识别。通过搜索 Skills 推荐替代来源。更新后的内容引文日期均在当前日期的 18 个月以内。|

---

## 7. 成功指标

### 7.1 核心指标

| 指标 | 定义 | 目标 | 衡量方法 |
|--------|-----------|--------|-------------------|
| **GEO 可见度评分** | AI 搜索引擎在回答产品问题时引用此内容的可能性 | >= 70/100 | 内容被索引后，用产品问题查询 ChatGPT/Perplexity；检查是否被引用。每周人工抽查。|
| **引文密度比** | 每 500 词输出中的权威引文数 | >= 3.0 | 生成时自动统计；记录至 `score-history.jsonl` |
| **数据/观点比** | 定量声明（含数字）与定性声明（无数字）的比例 | >= 4:1 | 自动分析：统计有数值的句子与无数值的句子。目标：80%+ 的声明有数据支撑。|
| **内容独特性评分** | 与同品类前 5 名竞品页面的 N-gram 重叠度的反面 | >= 85% 独特 | 调研阶段抓取竞品内容后进行 TF-IDF 余弦相似度检查 |
| **AI 搜索收录率** | 已发布内容在 30 天内出现在 AI 搜索结果中的比例 | 90 天内 >= 40% | 每周人工测试：用产品问题查询 ChatGPT、Perplexity、Google SGE，追踪哪些内容被引用。|

### 7.2 运营指标

| 指标 | 定义 | 目标 |
|--------|-----------|--------|
| **内容生成耗时** | 从接收 VOC 数据到最终输出的挂钟时间 | 博客：< 8 分钟，Amazon Listing：< 5 分钟，产品描述：< 4 分钟 |
| **首次通过率** | 首次生成即达到 >= 80 分的输出占比 | >= 60% |
| **规则违规率** | 初稿中硬性失败违规的平均数量 | < 2.0 |
| **修订轮次** | 达到 >= 80 分所需的平均修订次数 | <= 2 |

### 7.3 业务影响指标（下游）

| 指标 | 定义 | 目标（90 天） |
|--------|-----------|-----------------|
| **自然流量提升** | 博客文章自然流量相比非 GEO 基线的变化 | +30% |
| **Amazon Listing 转化率** | GEO 优化 Listing 的浏览-购买转化率 | 比未优化提升 +15% |
| **内容生产成本** | 单篇内容的成本（模型 API 费用 + 算力） | < $2/博客，< $1/Listing |

---

## 8. 质量门控

### 8.1 发布前检查清单

在任何内容被标记为最终版并发送给 Lead 之前：

- [ ] **GEO 分数 >= 80**（自动评分标准）
- [ ] **零硬性失败规则违规**（规则引擎类别 A-D）
- [ ] **引文数达到最低要求**（每 500 词 3 条）
- [ ] **所有引文已验证**（来源名称、日期和 URL/出版物齐全）
- [ ] **无过期引文**（全部在 18 个月以内，除非为历史参考）
- [ ] **数据点达到最低要求**（每个产品章节 5 个）
- [ ] **未检测到禁止模式**（关键词填充、模糊修饰词、通用开头）
- [ ] **结构要求已满足**（FAQ、对比表格、标题层级）
- [ ] **内容独特性 >= 85%**（与竞品内容对比）
- [ ] **VOC 痛点已回应**（输入中的前 3 个痛点在输出中出现）

### 8.2 自动检查（通过/失败）

以下检查在输出保存前自动执行：

```
检查 1：引文密度
  - 统计 [Source: ...] 标记数
  - 除以 (word_count / 500)
  - 通过条件：比值 >= 3.0
  - 失败信息："Insufficient citations: found {N}, need {M} for {word_count} words"

检查 2：关键词密度
  - 从元数据提取主要品类关键词
  - 统计每 500 词窗口中的出现次数
  - 通过条件：最大密度 <= 每窗口 3 次
  - 失败信息："Keyword stuffing detected: '{keyword}' appears {N} times in 500-word window starting at position {P}"

检查 3：模糊修饰词扫描
  - 正则匹配：/\b(best|top|leading|premium|innovative|cutting-edge|world-class|state-of-the-art)\b/i
  - 对每个匹配，检查 50 词内是否有数值数据
  - 通过条件：所有修饰词均有数据支撑
  - 失败信息："Unsupported qualifier '{word}' at position {P} - add quantitative evidence"

检查 4：数据点计数
  - 模式匹配：带单位的数字 (/\d+\.?\d*\s*(lbs?|kg|inches?|cm|mm|seconds?|mins?|hours?|mAh|W|Hz|dB|\$|%)/i)
  - 通过条件：每个章节 >= 5 个
  - 失败信息："Insufficient data points in section '{section}': found {N}, need 5+"

检查 5：结构验证
  - 博客：检测 FAQ 标题 AND 表格语法
  - Amazon：验证 Bullet 大写格式 AND 字符数
  - 通过条件：格式专属要求已满足
  - 失败信息："Missing required structure: {missing_element}"

检查 6：通用开头检测
  - 匹配前 100 字符是否命中禁用短语列表
  - 通过条件：无匹配
  - 失败信息："Generic AI opener detected: '{matched_phrase}' - rewrite opening"
```

### 8.3 人工审核触发条件

在以下情况下，内容会被标记需要人工审核：

| 触发条件 | 原因 |
|---------|--------|
| 产品属于受监管品类（健康、安全、儿童产品） | 法规合规风险——FDA、安全认证等声明需人工核实 |
| 内容包含医疗或健康声明 | 无法自动验证健康相关表述 |
| GEO 分数在 80-84 之间（边界通过） | 接近阈值——值得人工质检 |
| 内容在负面对比中指名提及竞品 | 品牌风险——需确保事实准确以避免诽谤 |
| VOC 数据的评论样本量少于 100 条 | 低样本量可能导致痛点排名不可靠 |

---

## 9. 集成接口

### 9.1 输入格式（来自 VOC 分析师）

VOC 分析师通过 `sessions_send` 经由 Lead 发送结构化数据。预期 Schema：

```json
{
  "task_type": "content_generation",
  "content_formats": ["blog", "amazon_listing", "product_description"],
  "product": {
    "name": "Folding Camping Cot",
    "category": "outdoor_sleeping",
    "price_range": {"min": 30, "max": 80, "currency": "USD"},
    "key_specs": {
      "weight_capacity_lbs": 450,
      "packed_dimensions_inches": "5.3 x 27 x 7",
      "weight_lbs": 13.2,
      "setup_time_seconds": 45,
      "material": "600D Oxford fabric, steel alloy frame"
    },
    "certifications": ["ASTM F2613-19"],
    "target_asin": "B0XXXXXXXX",
    "competitor_asins": ["B0YYYY1111", "B0YYYY2222", "B0YYYY3333"]
  },
  "voc_data": {
    "total_reviews_analyzed": 2000,
    "platforms": ["amazon", "reddit", "youtube"],
    "pain_points": [
      {
        "rank": 1,
        "description": "Weight capacity insufficient for larger adults",
        "frequency": 847,
        "percentage": 42.4,
        "sample_verbatims": [
          "Collapsed under me after 2 weeks, I'm 220lbs",
          "Says 300lb capacity but started sagging at 200"
        ]
      },
      {
        "rank": 2,
        "description": "Difficult to fold and store compactly",
        "frequency": 623,
        "percentage": 31.2,
        "sample_verbatims": [
          "Took 10 minutes to figure out the folding mechanism",
          "Does not fit back in the carry bag"
        ]
      },
      {
        "rank": 3,
        "description": "Too heavy to carry for backpacking",
        "frequency": 412,
        "percentage": 20.6,
        "sample_verbatims": [
          "At 22 lbs this is car camping only",
          "Way too heavy for hiking in"
        ]
      }
    ],
    "competitor_weaknesses": [
      {
        "competitor": "Brand X Cot (B0YYYY1111)",
        "weakness": "300 lb capacity, customer reports sagging at 200 lbs",
        "evidence_count": 156
      },
      {
        "competitor": "Brand Y Cot (B0YYYY2222)",
        "weakness": "Packed size 8x32x10 inches, too bulky for car trunk",
        "evidence_count": 89
      }
    ],
    "positive_signals": [
      {
        "feature": "quick setup",
        "frequency": 534,
        "description": "Users value setup under 60 seconds"
      }
    ]
  }
}
```

### 9.2 输出格式（内容交付）

内容保存至工作区后，通过 `sessions_send` 通知 Lead：

```json
{
  "status": "completed",
  "agent": "geo-optimizer",
  "task_type": "content_generation",
  "product": "Folding Camping Cot",
  "outputs": [
    {
      "format": "blog",
      "file_path": "~/.openclaw/workspace-geo/data/output/blogs/camping-cot-weight-guide-2026-03.md",
      "word_count": 2150,
      "geo_score": 87,
      "citations_count": 8,
      "data_points_count": 22
    },
    {
      "format": "amazon_listing",
      "file_path": "~/.openclaw/workspace-geo/data/output/amazon-listings/camping-cot-B0XXXXXXXX.json",
      "geo_score": 84,
      "citations_count": 5,
      "data_points_count": 15
    },
    {
      "format": "product_description",
      "file_path": "~/.openclaw/workspace-geo/data/output/product-descriptions/camping-cot-description.md",
      "geo_score": 82,
      "citations_count": 4,
      "data_points_count": 12
    }
  ],
  "quality_summary": {
    "all_hard_fail_rules_passed": true,
    "warnings": ["Rule A5: 1 citation from 2024 flagged for freshness"],
    "average_geo_score": 84.3
  }
}
```

### 9.3 反馈闭环

性能数据回流以持续改进未来的内容生成：

```mermaid
graph LR
    A["GEO 优化师<br/>生成内容"] --> B["内容发布<br/>（博客/Amazon/等）"]
    B --> C["性能数据<br/>（30 天窗口）"]
    C --> D["指标采集<br/>- AI 搜索引用<br/>- 自然流量<br/>- 转化率<br/>- 页面停留时间"]
    D --> E["Lead Agent<br/>汇总性能"]
    E --> F["sessions_send 反馈<br/>发给 GEO 优化师"]
    F --> G["更新规则引擎<br/>- 调整评分权重<br/>- 新增禁止模式<br/>- 更新权威来源列表"]
    G --> A

    style A fill:#E3F2FD
    style G fill:#FFF3E0
```

**反馈数据 Schema（来自 Lead）：**

```json
{
  "feedback_type": "content_performance",
  "content_id": "camping-cot-weight-guide-2026-03",
  "metrics": {
    "ai_search_cited": true,
    "ai_search_engines": ["perplexity", "google_sge"],
    "days_to_first_citation": 12,
    "organic_traffic_30d": 1847,
    "avg_time_on_page_seconds": 245,
    "amazon_conversion_rate": 0.087
  },
  "learnings": [
    "FAQ section was cited 3 times by Perplexity -- increase FAQ depth",
    "Comparison table data was extracted by Google SGE -- maintain table format"
  ]
}
```

GEO 优化师利用此反馈：
1. 识别哪些内容结构最容易被引用（FAQ、表格、规格列表）
2. 更新评分标准中的权重（提升高表现结构的权重）
3. 添加 AI 引擎偏好引用的新权威来源
4. 淘汰未能获得 AI 搜索可见度的内容模式

---

## 附录：禁用短语列表

用于规则 C2（模糊修饰词）和规则 C4（通用开头）的违规触发短语：

### 模糊修饰词（C2）—— 50 词内无数据则判定失败
```
best, top, leading, premium, innovative, cutting-edge, world-class,
state-of-the-art, industry-leading, best-in-class, superior, ultimate,
unmatched, unparalleled, exceptional, extraordinary, game-changing,
revolutionary, next-generation, high-quality, top-notch, first-rate
```

### 通用开头（C4）—— 出现在前 100 字符则硬性失败
```
"In today's fast-paced world"
"In today's digital age"
"When it comes to"
"It's no secret that"
"Are you looking for"
"Have you ever wondered"
"In the world of"
"As we all know"
"There's no denying that"
"If you're like most people"
"In recent years"
"With so many options available"
```

### 填充过渡句（C5）—— 警告
```
"That being said"
"It's worth noting that"
"At the end of the day"
"All things considered"
"Needless to say"
"Without further ado"
"Last but not least"
"In conclusion"
"To sum it up"
"Moving on"
```

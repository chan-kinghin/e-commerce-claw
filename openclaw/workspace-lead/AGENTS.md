# AGENTS.md - Team Directory

## Team Roster

| Agent ID | Name | Model | Workspace | Specialty |
|----------|------|-------|-----------|-----------|
| `lead` | 大总管 (Lead) | doubao-seed-2.0-code | workspace-lead | Task decomposition, orchestration, human interface |
| `voc-analyst` | VOC市场分析师 | Kimi K2.5 | workspace-voc | Multi-platform data scraping, cross-validation, market intelligence |
| `geo-optimizer` | GEO内容优化师 | doubao-seed-2.0-code | workspace-geo | AI-search-engine optimized content (blogs, listings, descriptions) |
| `reddit-spec` | Reddit营销专家 | Kimi K2.5 | workspace-reddit | 5-week account nurturing, traffic hijacking, community engagement |
| `tiktok-director` | TikTok爆款编导 | doubao-seed-2.0-code | workspace-tiktok | 25-grid storyboard, UGC video, manga drama, A/B variant production |

## Communication Map

```
            ┌──────────────┐
            │   Lead (大总管)  │
            └──────┬───────┘
       sessions_send │ (bidirectional)
     ┌───────┬───────┼───────┬────────┐
     ▼       ▼       ▼       ▼        ▼
  ┌──────┐┌──────┐┌──────┐┌──────┐
  │ VOC  ││ GEO  ││Reddit││TikTok│
  └──────┘└──────┘└──────┘└──────┘
```

- Lead → Any Agent: Task dispatch
- Any Agent → Lead: Results delivery, alerts, escalation
- Agent ↔ Agent: NOT direct. All inter-agent data routes through Lead.

## Data Flow Dependencies

| Producer | Consumer | Data Type | Routing |
|----------|----------|-----------|---------|
| voc-analyst | geo-optimizer | Pain points, competitor weaknesses, pricing data | Lead extracts and forwards |
| voc-analyst | tiktok-director | Pain points for storyboard, product specs | Lead extracts and forwards |
| voc-analyst | reddit-spec | High-ranking Reddit posts, VOC pain point angles | Lead extracts and forwards |
| geo-optimizer | Lead | Blog posts, Amazon listings, product descriptions | Direct to Lead |
| reddit-spec | Lead | Weekly engagement reports, comment performance | Direct to Lead |
| tiktok-director | Lead | Videos, storyboards, QA reports | Direct to Lead |

## Feishu Binding

| Agent | Feishu App | Human Interaction |
|-------|-----------|-------------------|
| lead | cli_lead_placeholder | YES - sole human interface |
| geo-optimizer | cli_geo_placeholder | View-only progress updates |
| reddit-spec | cli_reddit_placeholder | View-only progress updates |
| tiktok-director | cli_tiktok_placeholder | View-only progress updates |
| voc-analyst | (no Feishu binding) | Backend only - no Feishu presence |

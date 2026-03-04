# API Keys Required

## REQUIRED (core functionality)

| Variable | Service | Used By | Sign Up |
|---|---|---|---|
| `DECODO_AUTH_TOKEN` | Decodo - structured web scraping | voc-analyst, geo-optimizer, reddit-spec | dashboard.decodo.com |
| `BRAVE_API_KEY` | Brave Search - overseas web search | voc-analyst, geo-optimizer, reddit-spec | api.search.brave.com |
| `APIFY_TOKEN` | Apify - cloud scraping (Google Maps, TikTok, Instagram) | voc-analyst | console.apify.com |
| `VOLCENGINE_MODEL_API_KEY` | Volcengine (ByteDance) - doubao-seed-2.0-code | lead, geo-optimizer, tiktok-director | volcengine.com |
| `MOONSHOT_API_KEY` | Moonshot AI - Kimi K2.5 | voc-analyst, reddit-spec | platform.moonshot.cn |

## OPTIONAL (enhanced capabilities)

| Variable | Service | Used By |
|---|---|---|
| `TAVILY_API_KEY` | Tavily - China-domestic search, no VPN | voc-analyst, geo-optimizer, reddit-spec |
| `EXA_API_KEY` | Exa - semantic search | voc-analyst, geo-optimizer, reddit-spec |
| `FIRECRAWL_API_KEY` | Firecrawl - sandbox browser (500 free/mo) | voc-analyst, geo-optimizer |
| `VOLCENGINE_API_KEY` | Volcengine - Seedance video gen & VLM | tiktok-director |
| `GOOGLE_API_KEY` | Google - image generation | tiktok-director |
| `TELEGRAM_BOT_TOKEN` | Telegram Bot - alternative alerts | price monitoring |
| `TELEGRAM_CHAT_ID` | Telegram Chat ID | price monitoring |

## PRODUCTION (deployment & human interface)

### Feishu Apps (4 apps needed)

| Variable | Agent |
|---|---|
| `FEISHU_LEAD_APP_ID` + `FEISHU_LEAD_APP_SECRET` | Lead |
| `FEISHU_GEO_APP_ID` + `FEISHU_GEO_APP_SECRET` | GEO Optimizer |
| `FEISHU_REDDIT_APP_ID` + `FEISHU_REDDIT_APP_SECRET` | Reddit Specialist |
| `FEISHU_TIKTOK_APP_ID` + `FEISHU_TIKTOK_APP_SECRET` | TikTok Director |
| `FEISHU_WEBHOOK_URL` | Price alert webhook |

### Reddit Accounts (3 minimum)

| Variable | Account |
|---|---|
| `REDDIT_ACC_001_TOKEN` + `_SECRET` + `_USERNAME` | Account 1 |
| `REDDIT_ACC_002_TOKEN` + `_SECRET` + `_USERNAME` | Account 2 |
| `REDDIT_ACC_003_TOKEN` + `_SECRET` + `_USERNAME` | Account 3 |

## Summary

- **5 keys** to get started (Required tier)
- **7 keys** for full search/scraping coverage (+ Optional)
- **30 variables** total for full production deployment

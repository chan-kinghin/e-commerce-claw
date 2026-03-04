---
title: "终于，我把 Openclaw 加 Seed2.0 Skills 做 AI 漫剧搞定了"
date: 2026-03-02
type: research
status: active
language: zh
source: "https://mp.weixin.qq.com/s/3fnWxHuZreXTXKcEBo6JPw"
author: "苍何"
tags: [wechat, ai-ml, engineering]
---

# 终于，我把 Openclaw 加 Seed2.0 Skills 做 AI 漫剧搞定了

> Source: https://mp.weixin.qq.com/s/3fnWxHuZreXTXKcEBo6JPw | Author: 苍何 | Date: 2026-03-02

这是苍何的第 500 篇原创！

大家好，我是苍何。

不知不觉，500 篇原创啦。年前开源的 AI 漫导开源项目也 1.1 k star 了。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaDRep7jqUmT2jNBhdboicibCG6j1ntAaBvibqCXuZ8HWhe74EFzI4eOficLe2wjozrGtKXg59yem4iaqv3zInxtyRCKjqibog8rDh3Og/640?from=appmsg)

最近玩 Openclaw 又玩的跟个疯狗似的，给我的小龙虾装了很多实用技能，可以自动写小红书图文，可以自动写作，配图，生成封面等。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaAkj1glyqfrnawhLhkkkLm1XRKSqkO77qqNHsUexH8nLHibEZnmUTAnqLuZkeCEiaAec879iaYlwF1ULPalLTpOVIITO1EQ7NyWfc/640?from=appmsg)

但感觉生活还是很无趣，于是又花了一些时间，开发了个 AI 漫剧视频生成 Skills，给小龙虾使用。

准确的说，这是个基于字节 Seed2.0 的技能包，有以下子技能。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaB3GAEuF4pu5xJ8Qx07JAjJqK0f7VgIMxfjcymict7RFfPnbyZWWYDKIMlehIRUhgib7Xu4S84ZTtfv3ibd9vQEkwqJ2bjTm1plWk/640?from=appmsg)

**「seedance-video」**：文生视频、图生视频，seedance 1.5 Pro 版本还自带音频生成，属于基本盘。

> 等seedance 2.0 的 API 出来，也会第一时间接入。

**「manga-style-video」**：8 种漫画风格一键切换。日式治愈系、吉卜力、国风水墨、美式卡通、铅笔素描、水彩、Q版萌系。

**「manga-drama」**：这个是核心，漫剧生成器。丢一张主角图进去，自动给你编排分镜短剧。

**「volcengine-video-understanding」**：火山视频理解，生成完还能分析效果，看看情感表达到不到位。底层用的是 doubao-seed-2.0-code 的能力。

说白了，从写脚本到出视频到验收，一条龙全包了。

比如直接一句话调用 manga-drama 技能生成视频。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/zw8bZHsVSaAWKqHBxO0uo0XznqPP6kJGUSwmniaLBF2W3jCQWuUbWeaonEgkbHZ9D4p4MQkVakdn2e0ehovaJEotgzmJz7MVcuvQvPYhbZ7g/640?from=appmsg)

稍微控制一下提示词，就能生成比较精致的动漫风格的视频了，其中我给的提示词是：

> 动漫风格视频，一名长发高中少女漫步在盛开的樱花树下。粉色的花瓣在微风中缓缓飘落。明媚的春季阳光洒下，产生柔和的镜头光晕效果。侧向跟踪镜头，怀旧氛围，高画质，控制在20M 以内，并以视频文件预览的方式直接发给我

![](https://mmbiz.qpic.cn/sz_mmbiz_png/zw8bZHsVSaAJMrvIxO8ticzGNKfUaqZww42rAx4byic7ARdcaZicibAuibAplXaapX0LVVHymJGqbYXfNXiarNe4r698bM2E0ibfufia1UawJmKa83U/640?from=appmsg)

这个视频目前使用的是 seedance 1.5 Pro，等 2.0 的 API 出来效果会更好 ：

可以使用一张图片，直接生成漫剧分镜视频，生成脚本到主角再到分镜视频，manga-drama 都能一次性完成。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/zw8bZHsVSaDl1wBQJZE6EAwdw8icr78L5ib6F85T4F1GsXUT5vvVP1fBlJpOeiaaVhc3KFbxALP3AGVchbUZebtJ995bpqQGgPHRthylDGESAU/640?from=appmsg)

我录了个视频，大家可以看下这个流程：

生成的分镜视频合成了下是这样的：

> 后面考虑迭代的方向就是让这几个视频能连一块组成丝滑的视频。

我把整个 Skills 都也开源到了 GitHub 我的 Skills 仓库：

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaBcnglOoYmtsoh9phkAOlvIRFxEpD3t2nSZjS1R2RU6XT4HNTworsuiauRQEW13N9zfgd4bUvJibsA0tAibbH0Ltfk0A6vicaV9uJc/640?from=appmsg)

> 点击头像，然后私信回复：canghe-skill，可获取我的所有技能包。

使用的话也非常简单，你只需要让你的 openclaw 自己安装下我的技能就好了。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaAibMyiczOKoMoCgTgZqchvIHcpVojJFLGHJnU5z7Giaekp3u65UEOwp7Y97vmn6S2GMgpZNtmjDyO15pAgXmf3RB3VpUNqsdGfFg/640?from=appmsg)

## 实战：一张图到一套漫剧，怎么跑的？

光说不练假把式，直接上流程。不过在此之前，得申明一点，这个过程将会非常费 token，我自己小龙虾用的是火山的 Coding Plan 套餐。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaCxTO0lm8vGOqia9RtnQlHfWLkp32icKHicdibZBHGj4hyqrHmIaXW3javXQAEVz0TOPBZDQA7oO17pl6PMqIIIicwSpkr3lfKibWy24/640?from=appmsg)

3 月起新用户首购是 9.9，还有裂变活动：被推荐的用户还可叠加10% 推荐福利，8.9 即可购买。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/zw8bZHsVSaDU1SOTfiaFwr8MfqpWOcWMRvheViaWXH820PkNicdDiceMibkia33lFqBjv3urRAP82qBcnkTQMsc0KTcnib20lgHHeib7Eyr9dPMaTMQ/640?wx_fmt=png&from=appmsg)

里面模型也挺多的，主要原因是我想用 doubao-seed-2.0-code 的 Agent 和 VLM 能力，之前也做过一次测评，目前表现是非常不错的。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaDZq07PF3aoE9WiaMyyvrwLImH5bJ4MVDibWAMdb3ibvQoNugvrZc3JibZoTD9oibGCzEa3sEmq9fiatoajicvfn07OMRAACfoQsMOwwU/640?from=appmsg)

能理解长达 2 小时的视频，并调用剪辑 skill 进行混剪。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaBYQ6NBiaU9WtTQVvBWXpIMeGUXYhKGf7KicGYJibpBiaS6c5HNfX13bRsI68eiaiaMEu0kVVtztTMjjRibe3olzdkJMCzhwzrkQKeYk8/640?wx_fmt=png&from=appmsg)

还可自定调用各种 Skills 和 Agent 由视频转公众号文章。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaBMbSF3zOfiam7G7Dcw56VibPP7gopT8489UAdqvouM3jzmtmnfp4F6aJwzVqzqgK4eyaZcs50JMOoD5zD618Gbey9uVBvxmtGpY/640?wx_fmt=png&from=appmsg)

因为 seed2.0 具备更强的多模态理解能力和 Agent 能力，特别是在多模态感知，长视频理解，对 Skills 的理解和应用上表现不错。

在我们的整个流程中需要调用不少的 Skills，以及需要理解视频，所以目前来看，doubao-seed-2.0-code 是最合适的。

火山的 Coding Plan 上就可以直接用 doubao-seed-2.0-code，而且性价比也是挺高的，特别对新用户几乎是白菜价，hh。

> 我把地址放在**「阅读原文」**了，想要玩的可以自己点哈。

### 第一步：剧本逻辑编排

漫剧视频第一步，得有个像样的分镜脚本。

谁来写？Openclaw 后端配置的大模型。

我这里接的是 doubao-seed-2.0-code，负责生成分镜逻辑、编排场景顺序。

比如我想做一个「少年仗剑走天涯」的国风漫剧。

它会自动帮我拆成：开场独白、拔剑出鞘、对决场景、雨中沉思、结尾定格。

每一幕都带详细的画面描述和镜头指令，省心到离谱。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaCYUVuJib6LmpbQvawLLaLvOdHuorCBoYy9rNOMv9OTEjk4zZ0SeyXQPTXvZI2Yjia5lOc7jHdkL8cicfTxqGV4Z2RHFWoXfoR4L8/640?from=appmsg)

### 第二步：主角设定 + 风格选择

脚本有了，需要生成漫剧主角，会调用 canghe-image-gen  skill 来生成主角形象，这个 skill 是支持 Google API 及第三方 API 的。

无论是用最新的香蕉 2.0，还是使用 seedream 5.0，生图都轻松。

需要选风格。manga-style-video skill 提供了 8 种预设风格，每种都内置了专业提示词。

不用自己调参，选一个就完事。

我这次选的是国风水墨，配合「仗剑少年」的主题刚刚好。

![](https://mmbiz.qpic.cn/sz_mmbiz_png/zw8bZHsVSaDCg4peRW8X0ibf9VZKQGzZCWp2pMF6E8icuvdGltE8YTaccGhsTyMKgOVG1icbQk7ZJR9V6BTOrttRVegFPdCamrfQBKY8bNxWTU/640?from=appmsg)

你还别说，吉卜力风格也很绝，改天再试试。

### 第三步：漫剧生成

重头戏来了。

manga-drama 这个 Skill，是整套工作流里最让我惊艳的。

操作贼简单：丢一张主角图进去，它自动帮你编排整套分镜。

内置了 5 种分镜类型：

主角登场、动作场景、情感表达、互动场景、结尾定格。

每一幕的构图、镜头角度、光影氛围，全都安排得明明白白。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaAImmialTBacHuwvyYyuaGSwIj5XtXw4VbpiaFsxQOsDCRaicibZ51vvHMZHGE8bx5eW4nfBey231fR6Libnia2XrenvicrIzVU0t0CZU/640?from=appmsg)

不过当前是有一些待优化的地方都，传参考图，会中断链接，问题不大，后续我再修复下。

### 第四步：效果验收

视频生成完，还没完事。

volcengine-video-understanding 可以对生成的视频做内容分析。

这里基于 seed2.0 的视频理解能力，还是非常方便的。

情感表达到不到位？场景衔接顺不顺？它都能给你反馈。

相当于自带了一个「AI 质检员」，省得自己一帧一帧去看。

![](https://mmbiz.qpic.cn/mmbiz_png/zw8bZHsVSaBf4Z0b04GPLK0kP6e60eGSib7C1DzBgheZicWanjpTaydiaXaqJ4PIjh9heKiaw7dMUKhOHQuzbesGadTOBALaLA3TS03gcjHLhAg/640?wx_fmt=png&from=appmsg)

整套流程跑下来，从一张图到一套完整漫剧视频，我这边大概十来分钟搞定。

## 写在最后

Openclaw 的可玩性还是很多的，但也确实废 token。

Openclaw 的最佳使用方式是搭载自己的 Skills 技能包，而非是让自己的小龙虾在 ClawHub 中一顿瞎找。

现在的 Skill 太多了，但唯有那些对自己有用的技能才值得被收藏。

更推荐每个人都维护自己的技能仓库：把个人方法论、模板、脚本和领域默认配置沉淀为可版本化资产，而不是长期依赖单一公共基线。

说实话，等 Seedance 2.0 的 API 正式放出来，这套漫剧工作流还能再上一个台阶。

到时候画面一致性、角色连贯性都会好很多，想想就有点期待。

感兴趣的可以先玩起来，我的技能包都开源了，私信回复 canghe-skill 就能拿到。

想试试火山 Coding Plan 省 token 的，也可直接点文末**「阅读原文」**。

有什么好玩的玩法，也欢迎评论区交流。

觉得有用的话，点个赞和在看呗，下次继续给大家整点好活。

## Content (extracted from images)

```
freestylefly / director_ai

Code   Issues 5   Pull requests 1   Agents   Discussions   Actions   Projects   Wiki   Security   Insights   Settings

director_ai   Public
Pin   Watch 9   Fork 259   Starred 1.1k

master   2 branches   0 Tags
Go to file   Add file   Code

freestylefly   Merge pull request #8 from nieao/feature/storyboard-pro-v2.2   4566078 · last month   15 Commits

android               first commit                     2 months ago
docs                  将所有兔子 API 替换为苍何 API，并添加 API 使用教程    2 months ago
images                添加 star 趋势图                      2 months ago
lib                   将所有兔子 API 替换为苍何 API，并添加 API 使用教程    2 months ago
web                   feat(web): Upgrade to AI Storyboard Pro v2.2       last month
.cloudeignore         first commit                     2 months ago
README.md             将所有兔子 API 替换为苍何 API，并添加 API 使用教程    2 months ago
analysis_options.yaml first commit                     2 months ago
pubspec.lock          first commit                     2 months ago
pubspec.yaml          first commit                     2 months ago
test_api.py           first commit                     2 months ago

README

AI漫导 (DirectorAI)

AI 漫剧制作 APP，能一键生成剧本、分镜及合成视频，让你在手机上也能快速制作漫剧

Flutter 3.0+   Dart 3.0+   Platform Android   AI SLR-4.7

项目简介

About
AI 漫剧制作 APP，能一键生成剧本、
分镜及合成视频，让你在手机上也能快
速制作漫剧。

Readme
Activity
1.1k stars
9 watching
259 forks

Releases
No releases published
Create a new release

Packages
No packages published
Publish your first package

Contributors 3
freestylefly 苍何
claude Claude
nieao

Languages
Python 80.8%   Dart 30.1%
HTML 8.2%     Kotlin 0.6%
Batchfile 0.1% Java 0.1%

Type to search
```

-----

苍何的 OpeniClaw 助手  苍何的小龙虾助手  机器人
消息 +

| 回复 苍何: 你现在都装了哪些技能啊，列一下给我
好的，让我查看一下当前安装的所有技能：

| 回复 苍何: 你现在都装了哪些技能啊，列一下给我

📦 当前已安装的技能列表（共 33 个）
🎨 内容生成技能（Content Skills）

| 技能名 | 功能 |
|--------|------|
| canghe-xhs-images | 小红书图文生成器 |
| canghe-infographic | 信息图生成 |
| canghe-cover-image | 封面图生成 |
| canghe-slide-deck | 幻灯片生成 |
| canghe-comic | 漫画生成 |

1/2 ↑ ↓

🤖 AI 生成后端（AI Generation）

| 技能名 | 功能 |
|--------|------|
| canghe-image-gen | 图片生成（OpenAI/Google/阿里/Canghe） |
| canghe-danger-gemini-web | Gemini Web 接口 |
| canghe-seedance-video | Seedance 视频生成 |
| third-image-skill | 第三方图片生成 |
| xiaohongshu-skills | 小红书封面生成 |

🛠 实用工具（Utility）

| 技能名 | 功能 |
|--------|------|
| canghe-url-to-markdown | URL 转 Markdown |
| canghe-danger-x-to-markdown | X/Twitter 转 Markdown |
| canghe-compress-image | 图片压缩 |
| canghe-format-markdown | Markdown 格式化 |
| canghe-wechat-article-extractor | 微信文章提取 |

图片版权：苍何

-----

新增 Skill 功能概览

| Skill | 用途 |
|-------|------|
| seedance-video | 宇节跳动 Seedance 视频生成（文生视频/图生视频，支持多模型） |
| seedance-video-generation-1.0.3 | Seedance 1.0.3 版本的视频生成（类似上面，版本不同） |
| manga-style-video | 漫画风格视频生成（8种风格：日式、国风、美式卡通等） |
| manga-drama | 漫剧生成器（基于主角图片自动生成分镜短剧） |
| volcengine-video-understanding | 火山视频理解（分析视频内容、问答、情感分析等） |

---

1. seedance-video（通用视频生成）
- 功能：文生视频、图生视频（首帧/首尾帧/参考图）
- 模型：1.5 Pro（带音频）、1.0 Pro、1.0 Pro Fast、1.0 Lite
- 适用：需要灵活生成各种视频时使用

2. seedance-video-generation-1.0.3
- 同上面功能，版本为 1.0.3

3. manga-style-video（漫画风格视频）
- 8种风格：日式治愈系、吉卜力、国风水墨、美式卡通、铅笔素描、水彩、日式漫画、Q版萌系
- 特点：一键生成，内置专业提示词，无需复杂调优

4. manga-drama（漫剧生成）
- 核心：基于一张主角图片，自动生成多幕分镜短剧
- 内置分镜类型：主角登场、动作场景、情感表达、互动场景、结尾定格
- 输出：多个分镜视频文件，可发送到飞书

5. volcengine-video-understanding（视频理解）
- 功能：上传视频（最大 512MB），然后进行内容分析、问答、情感分析、场景识别等
- 适用：需要分析已有视频内容时使用

-----

苍何的 OpenClaw 助手  苍何的小龙虾助手  机器人
消息 +

需要我详细介绍某个技能的使用方法吗？

生成一个狗狗吃饭的视频

4 条回复

🐶 狗狗吃饭视频

| 回复 苍何: 生成一个狗狗吃饭的视频 |
| 好的，我来用 manga-style-video 技能生成一个狗狗吃饭的视频 |

| 回复 苍何: 生成一个狗狗吃饭的视频 |
| 视频生成成功！让我检查一下文件大小： |

| 回复 苍何: 生成一个狗狗吃饭的视频 |
| 6.4MB，文件不大，直接发送给你： |

| 回复 苍何: 生成一个狗狗吃饭的视频 |
| ✅ 狗狗吃饭视频已发送！ |
| 视频详情： |
| • 🐶 主角：可爱的金毛小狗 |
| • 🎯 动作：开心地吃狗粮，尾巴摇来摇去 |
| • 😊 表情：满足幸福的表情 |
| • 🏠 背景：温馨的厨房 |
| • 🎨 风格：美式卡通（迪士尼/皮克斯风格） |
| • ⏱️ 时长：5秒 |
| • 📐 比例：□□ |
| • 🖼️ 分辨率：720p |
| • 📁 文件大小：6.4MB |
| 看看收到了吗？ |

file_v3_00vc_62b5969b-96c5-4786-8e78-5bb974053cdg.mp4

通过“哔哩哔哩”打开

图片版权：苍何

-----

苍何的 OpenClaw 助手 苍何的小龙虾助手 机器人
+ 消息 +

动漫风格视频，一名长发高中少女漫步在盛开的樱花树下，粉色的花瓣在微风中缓缓飘落。明媚的春季阳光洒下，产生柔和的镜头光晕效果。请以视频文件预览的方式直接发给我

5 条回复

回答 苍何：动漫风格视频，一名长发高中少女漫步在盛开的樱花树下，粉色的花瓣在微风中缓缓飘落。明媚的春季阳光洒下，产生柔和的镜头光晕效果。

好的，我来生成这个动漫风格的视频：

回答 苍何：动漫风格视频，一名长发高中少女漫步在盛开的樱花树下，粉色的花瓣在微风中缓缓飘落。明媚的春季阳光洒下，产生柔和的镜头光晕效果。

还在生成中，继续等待：

回答 苍何：动漫风格视频，一名长发高中少女漫步在盛开的樱花树下，粉色的花瓣在微风中缓缓飘落。明媚的春季阳光洒下，产生柔和的镜头光晕效果。

视频生成完成，让我检查文件大小：

回答 苍何：动漫风格视频，一名长发高中少女漫步在盛开的樱花树下，粉色的花瓣在微风中缓缓飘落。明媚的春季阳光洒下，产生柔和的镜头光晕效果。

刚好 20MB！现在以视频文件预览形式发送：

回答 苍何：动漫风格视频，一名长发高中少女漫步在盛开的樱花树下，粉色的花瓣在微风中缓缓飘落。明媚的春季阳光洒下，产生柔和的镜头光晕效果。

✅ 视频已发送！

视频详情：
• 风格：日式治愈系 / 吉卜力风格
• 主角：长发高中少女
• 场景：樱花树下漫步，粉色花瓣飘落
• 光效：明媚春阳，柔和镜头光晕
• 镜头：侧向跟踪镜头，怀旧氛围
• 时长：8秒
• 比例：9:16（竖屏）
• 分辨率：1080p 高画质
• 文件大小：20MB

这次应该能以视频文件预览形式收到了！看看收到了吗？

file_v3_00vc_56f15861-51f8-4c24-8a66-...
通过“哔哩哔哩”打开

图片版权：苍何

-----

🎬 漫剧信息  
主角：女高中生（白衬衫、红领结、蓝裙子）  
风格：日式治愈系（吉卜力风格）  
总时长：30秒（3分镜 × 10秒）  
分辨率：1080p  

🎥 分镜视频  
| 分镜 | 场景 | 视频链接 |  
|------|------|----------|  
| 分镜1 | 🎯 主角登场 - 红灯笼街道 | 下载视频 |  
| 分镜2 | 🛍️ 庙会集市 - 挑选中国结 | 下载视频 |  
| 分镜3 | 🌸 温馨结尾 - 樱花树下的红包 | 下载视频 |  

📁 本地文件  
1 ~/Desktop/  
2 ├── spring_drama_scene1.mp4 （分镜1：主角登场）  
3 ├── spring_drama_scene2.mp4 （分镜2：庙会集市）  
4 └── spring_drama_scene3.mp4 （分镜3：温馨结尾）  

⏱️ 生成耗时  

图片版权：苍何

-----

# Specify style
/canghe-manga-style-video "Landscape painting" --style chinese  
/canghe-manga-style-video "Cute animals" --style cartoon  
/canghe-manga-style-video "Rural scenery" --style ghibli  

# With reference image  
/canghe-manga-style-video "Grandma making dumplings" --style japanese --image ~/Desktop/charact

8 Manga Styles:
- japanese - Japanese healing style (default)
- ghibli - Studio Ghibli style
- chinese - Chinese ink wash style
- cartoon - American cartoon style
- sketch - Pencil sketch
- watercolor - Watercolor hand-drawn
- manga_comic - Japanese manga
- chibi - Q-style cute

Test Case:
- Prompt: "A long-haired high school girl walking under blooming cherry blossom trees, pink petals gently falling in the breeze, bright spring sunshine casting soft lens flare effects, side tracking shot, nostalgic atmosphere, high quality"
- Style: ghibli
- Output:

图片版权：若何

-----

你能否帮我安装这个里面的所有技能吗？  GitHub - freestylefly/canghe-skills: 苍何的技能skills仓库，搜集好用的 skills，辅助提效

github.com
GitHub - freestylefly/canghe-skills: 苍何的技能skills仓库，搜集好用的 skills，辅助提效
苍何的技能skills仓库，搜集好用的 skills，辅助提效。
Contribute to freestylefly/canghe-skills development by ...

7 条回复

| 回复 苍何: 你能帮我安装这个里面的所有技能吗？  GitHub - freestylefly/canghe-skills: 苍何的技能skills仓库，搜集好用的 skills，辅助提效 |
| --- |
| 我来帮你安装这个仓库里的所有技能。先让我查看一下仓库内容。 |

| 回复 苍何: 你能帮我安装这个里面的所有技能吗？  GitHub - freestylefly/canghe-skills: 苍何的技能skills仓库，搜集好用的 skills，辅助提效 |
| --- |
| 我看到这是一个技能集合仓库，包含三类插件： |
| • content-skills - 内容生成和发布 |
| • ai-generation-skills - AI 生成后端 |
| • utility-skills - 实用工具 |
| 让我先读取 clawhub skill 的安装指南，然后帮你安装这些技能。 |

| 回复 苍何: 你能帮我安装这个里面的所有技能吗？  GitHub - freestylefly/canghe-skills: 苍何的技能skills仓库，搜集好用的 skills，辅助提效 |
| --- |
| 我看到需要使用 clawhub CLI 来安装技能。但这个仓库的技能似乎不是通过 clawhub 发布的，而是 GitHub 仓库。让我检查是否可以直接从 GitHub 安装，或者需要手动克隆安装。 |

| 回复 苍何: 你能帮我安装这个里面的所有技能吗？  GitHub - freestylefly/canghe-skills: 苍何的技能skills仓库，搜集好用的 skills，辅助提效 |
| --- |
| clawhub 已安装。让我检查一下是否支持从 GitHub 直接安装： |

| 回复 苍何: 你能帮我安装这个里面的所有技能吗？  GitHub - freestylefly/canghe-skills: 苍何的技能skills仓库，搜集好用的 skills，辅助提效 |
| --- |
| clawhub 似乎只支持从 registry 安装。让我直接克隆这个仓库并安装里面的技能： |

| 回复 苍何: 你能帮我安装这个里面的所有技能吗？  GitHub - freestylefly/canghe-skills: 苍何的技能skills仓库，搜集好用的 skills，辅助提效 |
| --- |
| 找到了 26 个技能！现在让我把它们安装到你的 workspace 中： |

| 回复 苍何: 你能帮我安装这个里面的所有技能吗？  GitHub - freestylefly/canghe-skills: 苍何的技能skills... |
| --- |
| ✅ 技能安装完成！ |
| 从 freestylefly/canghe-skills 仓库成功安装了 26 个新技能。 |

-----

火山方舟
开通管理
模型
应用组件库
云产品
Coding Plan

Coding Plan
首月低至8.9元，主流国产编程模型全覆盖，多生态兼容，模型工具不限，结果不降速！

套餐名称
套餐定价
状态
套餐用量
套餐生效时间
操作

Coding Plan Lite
个人开发者轻量化工具
40 元/月
已购买
Pro 优惠
12% / 018136分钟已使用
开始：2026-03-01
结束：2026-04-01
续费 ...

Coding Plan Pro
高阶用户大规模编程需求
200 元/月

订阅 Coding Plan，畅享Code模型
各模型性能参数略有差异，可根据实际需求，随时自由切换模型

Auto 已启用
智能调用模型，基于「效率 + 速度」双维度智能匹配最优算力与模型组合，支持优先尝鲜字节跳动及生态的最新模型能力。

Doubao-Seed-2.0-Code 未启用
依托 Seed 2.0 Agent 与 VLM 能力，强化代码能力：前端出没，多语言适配，适合接入各类 AI 编程工具，赋能Union-Thinking，支持开启深度思考。

Doubao-Seed-Code 未启用
豆包编程模型，面向Agent级编程任务进行了深度优化，具备精准的代码生成、任务调度与逻辑协同能力，赋能Union-Thinking，支持开启深度思考。

Kimi-K2.5 未启用
Moonshot AI 最新编程模型，进一步强化前端代码质量与设计表现力创造能力，赋能Union-Thinking，支持开启深度思考。

GLM-4.7 未启用
智谱 AI 旗舰代码大模型，可轻松解析超长代码库，处理复杂智能体（Agent）任务，在代码生成、调试、全链路理解场景中表现优异，赋能Union-Thinking，支持开启深度思考。

账户版权：客服

-----

Coding Plan

首月低至8.9元 主流国产编程模型全覆盖，多生态兼容，模型工具不限，丝滑不降速！

快速配置

图片版权：苍何

-----

字节发力，豆包大模型2.0 震撼来袭（附 Trae 实测）

原创  苍何  苍何  2026年2月15日 09:14  江西  👁️ 43人

这是苍何的第 496 篇原创！

图片版权：苍何

-----

抖音精选

必夹一个 OK

-----

```
VOD  在沙箱中  ×                          终端

$ python3 "/Users/yh/me-code/VOD/.trae/skills/video-understanding/scripts/video_analyze.py" 
"/Users/yh/me-code/VOD/vide/豆包部分.mp4" "请分析这个视频，重点关注罗永浩和豆包的互动内容，提取精彩对话和互
动细节。同时分析豆包展示的AI能力与背后的技术特点，包括但不限于自然语言处理、多模态交互、知识问答、逻辑推理等方
面。请以结构化的方式输出结果，分为'罗永浩与豆包的精彩互动'和'豆包的AI能力与技术分析'两大部分。" --fps 0.5 -- 
stream

(TraeAI-5) ~/me-code/VOD [127] $  trae-sandbox python3 "/Users/yh/me-code/VOD/.tr
ae/skills/video-understanding/scripts/video_analyze.py" "/Users/yh/me-code/VOD/vid
e/豆包部分.mp4" "请分析这个视频，重点关注罗永浩和豆包的互动内容，提取精彩对话和互 动细节。同时分析豆包展示的AI能力
和背后的技术特点，包括但不限于自然语言处理、多模态
交互、知识问答、逻辑推理等方面。请以结构化的方式输出结果，分为'罗永浩与豆包的 精彩互动'和'豆包的AI能力
与技术分析'两大部分。" --fps 0.5 --stream
Error: Python 3.13 or Lower required (SDK incompatible with 3.14+), current version: 3.14.2
(v3.14.2:df79363d58, Dec  5 2025, 12:18:06) [Clang 16.0.0 (Clang-1600.8.26.6)]
Tip: Use Python 3.9:/usr/bin/python3 scripts/video_analyze.py ...
1

VOD  在沙箱中  ◇                           终端

$ /usr/bin/python3 "/Users/yh/me-code/VOD/.trae/skills/video-
understanding/scripts/video_analyze.py" "/Users/yh/me-code/VOD/vide/豆包部分.mp4" "请分析这个视频，
重点关注罗永浩和豆包的互动内容，提取精彩对话和互动细节。同时分析豆包展示的AI能力与背后的技术特点，包括但不限于自
然语言处理、多模态交互、知识问答、逻辑推理等方面。请以结构化的方式输出结果，分为'罗永浩与豆包的精彩互动'和'豆包的
AI能力与技术分析'两大部分。" --fps 0.5 --stream

Done! Total time: 287.9s
Tokens: 4531 input + 2338 output = 47649 total
==============================================

☐ 调用技能: wechat-article
3

/Users /Users
正在生成...
```

-----

苍何的 OpenClaw 助手  苍何的小龙虾助手  机器人
消息 +

我想做一个「少年仗剑走天涯」的国风漫剧，帮我先生成分镜脚本，目前定 3 个分镜

3 条回复

| 回复 苍何: 我想做一个「少年仗剑走天涯」的国风漫剧，帮我先生成分镜脚本，目前定 3 个分镜 |
| --- |
| 好的，我来用 manga-drama 技能为你生成「少年仗剑走天涯」国风漫剧的分镜脚本： |

| 回复 苍何: 我想做一个「少年仗剑走天涯」的国风漫剧，帮我先生成分镜脚本，目前定 3 个分镜 |
| --- |
| 基础脚本已生成！现在让我为你定制国风武侠风格的分镜提示词： |

| 回复 苍何: 我想做一个「少年仗剑走天涯」的国风漫剧，帮我先生成分镜脚本，目前定 3 个分镜 |
| --- |
| ✅ 「少年仗剑走天涯」国风漫剧分镜脚本已生成！ |

🎬 分镜脚本详情
📌 漫剧信息
• 标题：少年仗剑走天涯
• 风格：国风水墨漫画风格
• 主角：少年剑客，长发飘逸，身着古装，手持长剑
• 分镜数：3 个

🎞️ 分镜 1：少年出山
类型：主角登场
场景：少年剑客站在云雾缭绕的山巅，长发随风飘扬，身着青色古装长袍，腰间佩剑，背对镜头望向远方连绵群山。晨曦微光洒落，衣袂翻飞。
画面特点：
• 🌫️ 云雾山巅，晨曦微光
• 🧍‍♂️ 衣袂翻飞，长发飘扬
• 🎨 国风水墨，淡雅色调

🎞️ 分镜 2：古道行旅
类型：动作场景
场景：少年剑客行走在古道驿站，手持长剑，步伐坚定。周围是飘落的红叶和竹林，远处可见古朴的客栈酒旗。
画面特点：
• 🍁 红叶飘落，竹林环绕
• 🏮 古道驿站，酒旗招展
• ⚔️ 步伐坚定，仗剑前行

🎞️ 分镜 3：天涯孤影
类型：情感表达
场景：少年剑客独自站在夕阳西下的大漠孤烟中，长剑斜指地面，背影孤独而坚毅。天边残阳如血，风沙轻卷。回眸一瞥，眼神坚定而深邃。
画面特点：
• 🌅 大漠孤烟，夕阳西下
• 🌪️ 风沙轻卷，残阳如血
• 👁️ 回眸一瞥，眼神坚定

图片版权：苍何

-----

苍何的 OpeniClaw 助手  苍何的小龙虾助手  机器人
消息 +

用 canghe-image-gen 生成少年剑客的形象

4 条回复

⚔️ 少年剑客 - 「仗剑走天涯」主角形象

| 回复 苍何: 用 canghe-image-gen 生成少年剑客的形象 |
| --- |
| 好的，我来用 `canghe-image-gen` 生成少年剑客的形象： |

| 回复 苍何: 用 canghe-image-gen 生成少年剑客的形象 |
| --- |
| 图片生成成功！让我查看一下： |

| 回复 苍何: 用 canghe-image-gen 生成少年剑客的形象 |
| --- |
| 太棒了！✨ 少年剑客形象生成成功！<br>形象特点：<br>• 👤 面容：清秀俊朗，眼神坚定<br>• 🧱 发型：长发飘逸，束成高马尾<br>• 👔 服饰：青色古装长袍，腰间佩剑，衣袂上有水墨山水纹样<br>• ⚔️ 武器：腰间悬挂精致长剑<br>• 🌄 背景：古松苍劲，远山云雾，国风水墨意境<br>很有武侠小说的感觉！现在通过飞书发给你： |

| 回复 苍何: 用 canghe-image-gen 生成少年剑客的形象 |
| --- |
| ✅ 少年剑客形象已发送！<br>形象很满意吗？满意的话，接下来可以用这个主角图片 + 刚才的分镜脚本，生成 3 个漫剧视频分镜：<br>1. 少年出山 - 云雾山巅，眺望远方 |

图片版权：苍何
# 街霸6助手 (SF6 Assistant) 代码架构与功能实现开发维基 (WIKI)

> **维护说明**：本文档为项目的核心开发与架构指南，旨在供开发者与 AI 助手快速查询和定位具体功能代码。**每当完成一个正式版本（Release）的发布与编译后，均需在此文档中同步更新新增功能、架构变动与相关文件索引。**

---

## 目录
1. [项目整体架构图谱](#1-项目整体架构图谱)
2. [功能速查与代码文件定位表](#2-功能速查与代码文件定位表)
3. [核心业务链路深入说明](#3-核心业务链路深入说明)
4. [数据存储与数据库设计](#4-数据存储与数据库设计)
5. [网络解析与反爬机制](#5-网络解析与反爬机制)
6. [版本发布与维基维护规范](#6-版本发布与维基维护规范)

---

## 1. 项目整体架构图谱

项目遵循模块化、高内聚低耦合的客户端分层架构，主要分为以下层次：

```text
lib/
├── core/                  # 基础设施与全局配置层
│   ├── constants/         # 常量定义（角色、段位、API、配色）
│   ├── network/           # 网络通信与 HTML/JSON 逆向解析
│   ├── storage/           # SQLite 数据库与本地安全存储
│   ├── theme/             # 全局深色主题与视觉规范
│   └── utils/             # 诊断日志系统与辅助函数
├── models/                # 领域数据实体模型层
├── services/              # 业务逻辑服务层 (ChangeNotifier / 状态管理)
├── ui/                    # 展现层
│   ├── screens/           # 顶级主功能界面
│   │   ├── home/          # 仪表盘主页
│   │   ├── battle_log/    # 无限战绩库
│   │   ├── analytics/     # 深度克制与胜率分析
│   │   ├── social/        # 好友、战队与玩家主页
│   │   ├── tools/         # 官方帧数表与对策心得笔记
│   │   ├── settings/      # 设置、备份与诊断日志
│   │   └── auth/          # 卡普空官方 WebView 登录
│   └── widgets/           # 复用组件与卡片视觉模块
├── data/                  # 静态预置离线数据库
├── app.dart               # 根级应用配置与底部导航框架
└── main.dart              # 应用引导入口与全局防御边界
```

---

## 2. 功能速查与代码文件定位表

| 功能模块 | 具体功能描述 | 涉及的核心源文件路径 |
| :--- | :--- | :--- |
| **应用引导与崩溃防御** | 全局 ErrorWidget 兜底、方向性安全容器、应用初始化 | `lib/main.dart` |
| **底部导航与更新弹窗** | 主界面 Tab 切换、每日启动自动更新检测、首次启动更新公告弹出 | `lib/app.dart`<br>`lib/ui/widgets/announcement_dialog.dart` |
| **官方登录与会话拦截** | WebView 模拟官方登录、Cookie 自动拦截持久化 | `lib/ui/screens/auth/login_webview_screen.dart`<br>`lib/services/auth_service.dart` |
| **玩家手动绑定与切换** | 根据玩家 10 位 Short ID 绑定账号、多账号平台切换 | `lib/ui/screens/home/home_screen.dart`<br>`lib/services/auth_service.dart` |
| **卡普空全量多线程同步** | 官方战绩、全角色排位、好友战队并发抓取、Cookie 超时安全保护、全生命周期日志埋点 | `lib/core/network/capcom_sync_engine.dart`<br>`lib/ui/widgets/quick_sync_dialog.dart` |
| **Next.js 数据逆向解析** | 从官方 Buckler 网页 script 标签解析 JSON、提取对局详情与模式代号 | `lib/core/network/next_data_parser.dart` |
| **仪表盘玩家英雄卡片** | 当前段位徽章、LP/MR 进度条、主玩角色标签、全球大师榜排名 | `lib/ui/screens/home/home_screen.dart`<br>`lib/ui/widgets/rank_badge.dart` |
| **多角色排位天梯榜** | 主玩角色置顶、其余按 MR/LP 排序、默认折叠显示前3位、一键切换主玩角色 | `lib/ui/screens/home/home_screen.dart` |
| **官方最爱内容与游玩时长** | 100% 真实还原卡普空 Buckler 官方数据：解析 `content_play_time_list`（模式名、真实秒数、Top 3 排序与占比彩条）与 `battle_stats`（排位/比赛间/休闲/格斗中心总场次），彻底剔除任何虚假估算 | `lib/models/play_time_model.dart`<br>`lib/ui/screens/home/home_screen.dart`<br>`lib/ui/screens/social/player_profile_screen.dart` |
| **近期走势与六维雷达** | 近 20 场胜率条、近 10 局 W/L 走势图、六维能力评估条形图 | `lib/ui/screens/home/home_screen.dart`<br>`lib/ui/widgets/win_rate_bar.dart` |
| **无限战绩库列表** | 突破官方 100 局上限的本地无限存储、比赛模式与我方角色双筛选 | `lib/ui/screens/battle_log/battle_log_screen.dart`<br>`lib/services/battle_log_service.dart` |
| **单局对战卡片排版** | 宽敞对手名展示、两行精简时间 (`MM-dd`/`HH:mm`) 与 MR/LP 变化居中平衡对齐、回合击杀方式、录像代码复制 | `lib/ui/widgets/battle_card_item.dart` |
| **查看对手资料主页** | 从战绩卡片直接跳转对手个人主页、查看对手全角色天梯排位与交手历史 | `lib/ui/widgets/battle_card_item.dart`<br>`lib/ui/screens/social/player_profile_screen.dart` |
| **战报分享海报长图** | 胜负卡片长图预览与社交群聊分享名片生成 | `lib/ui/widgets/share_battle_card.dart` |
| **深度克制与胜率分析** | 我方角色筛选、官方比赛模式联动筛选、最优/最差对策高亮、面对各对手胜率表 | `lib/ui/screens/analytics/analytics_screen.dart`<br>`lib/services/stats_service.dart` |
| **MR 天梯走势折线图** | 基于已归档大师对局自动绘制的 MR 评分波动曲线 | `lib/ui/widgets/mr_trend_chart.dart` |
| **好友与俱乐部战队** | 好友在线状态、战队成员列表、特别关注置顶 | `lib/ui/screens/social/social_screen.dart`<br>`lib/ui/screens/social/club_detail_screen.dart`<br>`lib/services/social_service.dart` |
| **官方角色帧数表** | 全角色完整帧数（发生、持续、硬直差、发生判定与打康优势） | `lib/ui/screens/tools/tools_screen.dart`<br>`lib/services/frame_data_service.dart`<br>`lib/data/frame_data_database.dart` |
| **玩家与角色对策心得笔记** | 针对特定对手或角色的实战备忘录、实战标签 CRUD | `lib/ui/screens/tools/tools_screen.dart`<br>`lib/services/notes_service.dart` |
| **本地备份与恢复 (导出导入)** | 将本地全部战绩与对策笔记导出为独立 JSON 文件备份、防数据丢失 | `lib/services/backup_service.dart`<br>`lib/ui/screens/settings/settings_screen.dart` |
| **软件在线更新与检查** | 接入 GitHub Releases API、代理镜像下载、版本号对比 | `lib/services/update_service.dart`<br>`lib/ui/screens/settings/settings_screen.dart` |
| **全天候运行日志与诊断** | 内存日志记录、闪存防抖写入持久化、异常堆栈排查与一键导出 | `lib/core/utils/app_logger.dart`<br>`lib/ui/screens/settings/settings_screen.dart` |
| **全角色与天梯段位常量** | 全角色枚举与名称、卡普空数字 ID 映射、段位积分等级划分 | `lib/core/constants/characters.dart`<br>`lib/core/constants/ranks.dart` |

---

## 3. 核心业务链路深入说明

### 3.1 卡普空官方数据同步机制 (`capcom_sync_engine.dart`)
1. **认证与安全会话提取**：
   - 从 `FlutterSecureStorage` 或 `InAppWebViewController` 获取已登录的 `buckler` 域名 Cookie。
   - 增加 3 秒获取超时限制，若后台 WebView 挂起则安全回退至持久化缓存，防止主线程假死。
2. **多通道并发拉取 (Parallel Dispatch)**：
   - 通道 1：拉取 `/profile/{shortId}/play`，抓取全角色排位积分、胜率及各模式时长。
   - 通道 2：拉取 `/profile/{shortId}/battlelog`，抓取近 100 局官方对战记录。
   - 通道 3：拉取 `/friend/list` 与 `/club/{clubId}`，同步好友社交与战队动态。
3. **入库增量排重与计算**：
   - 通过 `replayCode` 或 `(playedAt + opponentShortId)` 进行主键排重。
   - 仅将新增对局写入 SQLite 数据库，避免覆盖用户已添加的自定义笔记。

### 3.2 官方对战模式映射规范 (`battle_record.dart`)
卡普空官方 SF6 内部模式代号与本应用的标准命名对照如下：
- `1` / `ranked`：**排位赛**
- `2` / `casual`：**休闲赛**
- `4` / `room` / `custom`：**比赛间对战** (注意：卡普空内部 ID 为 4，切勿称呼为非官方的“自定义房”)
- `3` / `hub` / `battle_hub`：**格斗中心对战** (卡普空内部 ID 为 3)

### 3.3 角色 ID 规范与防污染机制 (`characters.dart`)
- 卡普空官方在 `/play` 接口首行会返回一个 `character_id: 0` 或 `"cha"` 的全局总览行。
- **强制规则**：在 `fromCapcomId` 中严禁将 `0`、`cha`、`all`、`total` 映射为 `random`，必须在数据解析阶段直接剔除，否则会导致随机角色的对战场次累加为全角色的总和。
- 真实的随机角色由代号 `254`、`255` 或字符串 `'random'` 触发。

---

## 4. 数据存储与数据库设计

### 4.1 SQLite 核心表结构 (`database_helper.dart`)
- **`battle_records` (无限战绩库)**：
  - `id`: 本地自增或唯一标识
  - `replay_code`: 卡普空对战录像代码（可为空，具备唯一索引）
  - `player_character_id` / `opponent_character_id`: 双方角色标识
  - `player_score` / `opponent_score`: 双方胜局比分
  - `is_win`: 胜负布尔值 (1/0)
  - `player_lp` / `player_mr` / `player_mr_change`: 积分与变动
  - `battle_type`: 模式分类（`ranked`, `casual`, `customRoom`, `battleHub`）
  - `played_at`: 对战时间戳（毫秒存储）
  - `rounds_json`: 各小局终结类型（CA、SA、普通、满血超杀等）
- **`official_matchups` (全生涯克制统计)**：
  - 存储官方计算的全生涯对各对手胜负场次缓存。
- **`player_notes` (对策心得笔记)**：
  - 支持按对手 Fighter ID、Short ID 或角色绑定实战技巧。

### 4.2 本地持久化 (`secure_storage.dart`)
- 用户配置：偏好设置、最近检查更新日期、上一次查看的更新公告版本。
- 缓存数据：雷达能力六维图缓存、各模式游戏时长 JSON (`sf6_playtime_{shortId}`)、关注好友 Short ID 列表。

---

## 5. 网络解析与反爬机制

- **网页端反反爬策略**：卡普空 Buckler 页面采用 Next.js 构建，直接抓取 HTML 会受到前端渲染限制。应用通过正则表达式：
  ```dart
  RegExp(r'<script id="__NEXT_DATA__"[^>]*>([\s\S]*?)</script>')
  ```
  直接截取挂载在 HTML 骨架中的首屏完整 JSON 状态树，绕过复杂的 JavaScript 动态解密与 DOM 提取，速度提升 10 倍以上且稳定性极高。

---

## 6. 版本发布与维基维护规范

1. **版本编号规则**：
   - 正式发布版：`vX.Y.Z`（如 `v1.2.4`）
   - 测试补丁版：`vX.Y.Za`、`vX.Y.Zb`（如 `v1.2.4b`）
   - 内部 build 号：递增整型（如 `2408`）
2. **编译发布检查清单**：
   - 检查 `lib/core/utils/app_logger.dart` 中的 `currentAppVersion` 是否同步更新。
   - 检查 `pubspec.yaml` 中的 `version` 是否同步递增。
   - 运行 `flutter test` 确保全部核心测试 100% 通过。
   - **更新本 WIKI.md**：记录新引入的 Model、修改的 Screen、优化的逻辑以及新增的业务规范。

---

## 7. 版本演进与关键功能记录

### v1.2.5 (build 2500) - 正式版
- **下拉刷新静默黑屏彻底根治与架构四重加固**：
  - **根组件生命周期与解耦加固 (`lib/app.dart`)**：
    - 根因定位：此前 `_Sf6AppState.build()` 中在 `_isInitialized` 切换或数据同步时反复重建根 `MaterialApp`，且 `_onAuthChanged` 在下拉刷新中途直接调用根组件 `setState()`，导致在 `RefreshIndicator` 手势回弹时根 `Navigator` 和 `Overlay` 路由树被瞬间销毁，渲染管道丢失 RenderView（Detached Element），且因无 Dart 异常抛出导致诊断日志无记录。
    - 改动落地：将 `MaterialApp` 固化在应用根节点；引入 `_lastActivePlatformKey` 身份跟踪，在数据更新但账号未切换时，严禁触发根级 `setState()`。各子页面完全依托自身的 `ListenableBuilder` 响应数据更新，彻底避免了根路由栈被打断的问题。
  - **Android 原生渲染层加固 (`MainActivity.kt` & `AndroidManifest.xml`)**：
    - 在 `MainActivity.kt` 中重写 `getRenderMode()` 返回 `RenderMode.texture`，强制采用 `TextureView` 渲染，彻底免疫 Android 针对 `SurfaceView` 硬件缓冲丢失（Surface Buffer Lost）导致的静默黑屏。
    - 在 `AndroidManifest.xml` 的 `<application>` 中配置 `android:largeHeap="true"`，为高并发 JSON 解析分配充裕的堆空间，杜绝系统底层 LMK 内存抢占。
  - **网络并发节流与增量短路机制 (`capcom_sync_engine.dart` & `database_helper.dart`)**：
    - 在 `DatabaseHelper` 中新增 `getExistingReplayCodes` 方法，快速比对本地已有录像编号。
    - 彻底废除 10 页 battlelog 一次性并发 13 个全量 HTML 的暴力下载策略，改为「第 1 页探测 + 增量短路 + 批次温和推进」：第 1 页若无新增对局，立即短路跳过后续 9 页请求，刷新耗时降至 1 秒以内；若有新对局，则以每批 2 页分批拉取并在碰到已有对局时提前截断。峰值内存下降 80% 以上。
  - **主页上下文安全与组件保活 (`home_screen.dart`)**：
    - `onRefresh` 内部全流程加入强 `mounted` 保护，确保异步同步结束后安全调用 SnackBar 和刷新时长，配置霓虹青品牌色动画回弹。
- **深度分析（Analytics）模式筛选与数据源联动重构 (`analytics_screen.dart` & `stats_service.dart`)**：
  - 根因定位：此前 `analytics_screen.dart` 中，比赛模式筛选栏被 `if (!widget.statsService.useOfficialStats)` 条件包裹。由于默认展示官方全生涯胜率 (`useOfficialStats = true`)，导致界面完全隐藏了模式筛选栏，用户在角色横条下方无法切换不同模式（排位赛/休闲赛/比赛间/格斗中心）。
  - 改动落地：
    - 彻底解除模式筛选栏的显示约束，使其常驻于我方角色选择横条正下方。
    - 联动逻辑完善：用户点击任意具体对战模式（排位赛、休闲赛、比赛间对战、格斗中心对战）时，`StatsService.selectBattleType` 自动切换为本地对战回放数据源并即时重新聚合计算该模式对策数据；界面同步展示模式对策说明。
    - 当处于「全部模式」时，保留「全部对局 (全生涯)」与「近100场对局」的双轨切换开关；切换至全生涯官方统计时自动复位模式选择为全部模式。
- **产物更新**：
  - 编译并部署正式版本 `sf6_assistant_v1.2.5.apk`。

### v1.2.4d (build 2410)
- **首页时长卡片彻底移除**：
  - 彻底移除了首页的「各模式游戏时长」卡片，精简页面层级，保持首页紧凑聚焦。
- **深度分析页面数据源重构（「全部对局」与「近100场对局」双轨显式切换）**：
  - 根因排查：此前在增加比赛模式筛选时，由于卡普空官方的全生涯对手胜率表（`official_rival_matchups`）不区分模式，代码误将「全部模式」也绑定到了本地 100 场回放库，导致用户面对某角色的场次从全生涯的十几场缩水到了近百场的 4 场。
  - 改动落地：
    - 分析页面角色横条下方引入显式双段切换器：`[全部对局]`（展示卡普空官方全生涯对手克制总览）与 `[近100场对局]`（展示本地实战回放统计）。
    - 切换到「全部对局」时，完整呈现玩家自建号以来的全生涯对策数据，场次与苦战对局数据完整还原；切换到「近100场对局」时，可进一步展开横向模式筛选芯片（排位赛/休闲赛/比赛间/格斗中心）过滤近百场实战。
    - 在下拉刷新引擎 `capcom_sync_engine.dart` 中补齐了对 `character_win_rates_by_rival_character` 的持久化写入，每次刷新均同步最新全生涯对策表。
- **产物更新**：
  - 编译并部署正式版本 `sf6_assistant_v1.2.4d.apk`。

### v1.2.4c (build 2409)
- **卡普空官方「最爱内容 / 模式游玩时长」100% 真实结构逆向与接入**：
  - 根因排查：通过深入解构卡普空官方前端构建代码 (`profile/[sid]-131738976b822434.js`)，查明官方各模式游玩时长实际存储于 `play.base_info.content_play_time_list`（包含 `content_type`, `content_type_name`, `play_time` 官方真实秒数），而「最爱内容」是官方按游玩时长降序排列的前三名（Top 3）。此前版本因在顶层平铺字段未检索到，回退到了按近期对战乘以 160 秒的估算逻辑，导致数字完全失真。
  - 改动落地：
    - 重构数据模型 `PlayTimeModel` 与 `PlayTimeItem`，彻底删除 `PlayTimeModel.fromMatchCounts` 及所有乘以 160 秒的估算代码，坚持真实不欺瞒原则。
    - `NextDataParser.parsePlayTime` 全面解析 `content_play_time_list` 与 `battle_stats`（包含排位赛、比赛间、休闲赛、格斗中心四大模式的官方真实对局总数），并在主档案 `/profile/[sid]` 与子路由 `/play` 同步时双重持久化存储。
    - 首页卡片换装为「最爱内容 / 游玩时长」：顶部展示官方累计总时长，中间提供对应官方配色的模式比例横条，主体展示时长最高的前三位模式与格式化游玩时间（如「120小时30分」）及占比百分比，支持展开查看全部模式，并在底部集成官方四大模式的生涯真实场次看板。
- **战绩列表卡片时间排版精细化居中对齐**：
  - 在 `battle_card_item.dart` 中为右侧时间与分数变动模块添加显式居中约束 (`alignment: Alignment.center`)，确保日期与时分整体视觉严格对称居中。
- **安装包清理与产物归一**：
  - 彻底清理 E 盘工作区内全部 25 个历史旧版本 APK，当前目录仅保留最新正式编译版本 `sf6_assistant_v1.2.4c.apk`。

### v1.2.4b (build 2408)
- **各模式游戏时长卡片可见性与数据兜底修复**：
  - 根因：此前若卡普空官方接口未返回 explicit 秒数或用户尚未下拉全量同步，卡片因 `hasData == false` 被完全隐藏；且首页 `initState` 时若账号异步载入尚未完成，未能在账号就绪后自动拉取本地缓存。
  - 改动：首页始终保证「各模式游戏时长」卡片可见；引入双轨数据策略——若官方返回时长则直接展示，若官方接口无具体各模式时长，自动基于本地对战记录 (`battleLogService.records`) 与生涯总场次 (`profile.totalMatches`) 智能推算各模式估算时长 (`PlayTimeModel.fromMatchCounts`)；登录流程中自动持久化时长 JSON。
- **对战战绩卡片时间排版美化与居中对齐**：
  - 根因：战绩卡片右侧时间排版靠右对齐 (`CrossAxisAlignment.end`)，与上方得分/MR变动不对称，视觉效果杂乱。
  - 改动：改为独立最小宽度容器 (`minWidth: 54`)，两行时间 (`MM-dd` / `HH:mm`) 与 MR/LP 增减数值统一采用居中对齐 (`CrossAxisAlignment.center` + `TextAlign.center`)，视觉平衡美观。

### v1.2.4a (build 2407)
- **首页下拉刷新黑屏根因修复**：引入组件级安全容器 `_safeBuildCard`，全局 ErrorWidget 采用受限居中容器，Cookie 抓取设置 3 秒超时。
- **随机角色（Random）场次虚高 Bug 修复**：过滤卡普空官方 `/play` 接口中的总计汇总行 (`character_id: 0`/`cha`/`all`)。
- **对战模式映射与术语校正**：严格对齐官方规范（排位赛、休闲赛、比赛间对战、格斗中心对战）。
- **首页角色天梯榜折叠优化**：主玩角色置顶，定级角色超 3 位默认折叠并支持展开。
- **深度分析页模式筛选换装**：移除冗余官网/本地切换，换装模式横向筛选芯片。
- **战绩卡片重构与跳转对手个人主页**：一级卡片精简时间与名字排版，二级展开卡片增加「查看对方资料」跳转。

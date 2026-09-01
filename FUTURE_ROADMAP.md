# 🥊 SF6 Tracker（街霸6战绩助手）中长期优化路线图与未来计划

> 整理日期：2026-08-31  
> 归档版本：v1.0.32+2033  
> 状态：持续演进与维护中

---

## 📌 一、待排期重构与架构演进任务（建议延后 / 分阶段推进）

### 1. 🏗️ 网络层与数据层深度重构（从 UI 解耦）
* **现状**：目前 LoginWebViewScreen 与 QuickSyncDialog 中包含了部分 Dio 网络请求与 Next.js 抓包解析逻辑。
* **目标架构**：
  * 抽象 BucklerApiClient（处理 Cookie 会话、UA 管理、Dio 请求拦截与超时熔断）；
  * 建立 FighterRepository / BattleLogRepository / SocialRepository；
  * UI 层仅需调用 Repository.sync()，支持后续做后台 WorkManager 静默定时同步。
* **预计阶段**：v1.1.0 架构升级专项。

### 2. 🧩 巨型 UI 文件模块化拆分（God Widget 瘦身）
* **现状**：home_screen.dart (1200+ 行)、login_webview_screen.dart (1100+ 行) 较长。
* **拆分规划**：
  * HomeScreen 拆分为：
    * widgets/home_fighter_hero_card.dart（玩家名片与段位卡）
    * widgets/home_recent_form_card.dart（近期 20 战胜率与状态走势）
    * widgets/home_radar_card.dart（五维能力雷达图）
    * widgets/home_character_ladder_card.dart（全角色独立段位榜）
  * LoginWebViewScreen 拆分为：
    * widgets/login_profile_confirm_dialog.dart
    * widgets/manual_short_id_dialog.dart

### 3. 🧪 核心业务逻辑单元测试矩阵
* **目标**：为核心纯算法与数据转换建立 100% 覆盖的测试用例：
  * 胜负判定（Round Code 与 KO 判定边界条件）；
  * 最高连胜（Max Win Streak）与当前连胜算法；
  * LP/MR 段位换算与图标映射逻辑；
  * hardware_type（1=Steam, 2=PS5, 3=PS4, 4=Xbox, 5=NS2）平台转换。

### 4. 🗄️ 数据库迁移与性能优化
* **目标**：
  * 规范 sqflite 的 onUpgrade 版本号管理，替代 onOpen 中的 try/catch ALTER TABLE；
  * 对战角色对策统计 SQL 引入分区窗口函数，消除 N+1 循环查询。

---

## 📌 二、体验增强与未来功能库（暂不需要 / 体验增强）

### 1. 🔑 生产环境 Release 独立 Keystore 签名
* **计划**：在正式发布至 Google Play / 外部应用市场时，配置专用的 sf6_tracker.jks 签名并配置环境变量保护密码。

### 2. 💾 战绩数据本地导出与备份
* **功能**：
  * 支持导出本地 1000+ 场完整战绩为 .sqlite 数据库备份文件；
  * 支持导出对局历史为 .csv / .json，方便玩家导入 Excel 做深度技术统计；
  * 支持一键从文件恢复战绩。

### 3. 🔄 应用内版本更新检测 (In-App Update)
* **功能**：对接 GitHub Release API 或自建静态版本检测，有新版本时在设置页与启动时提供无感更新下载提示。

### 4. 🌐 国际化 (i18n) 多语言支持
* **计划**：为日文（日本語）、英文（English）做本地化字符串映射，便于海外街霸玩家使用。

### 5. ♿ 无障碍支持 (Accessibility)
* **计划**：为对战回合图标、MR/LP 图表提供清晰的 Semantics 语义描述。

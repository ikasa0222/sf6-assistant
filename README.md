# 🥊 街霸6助手 (SF6 Assistant)

<div align="center">

![GitHub Release](https://img.shields.io/badge/Release-v1.2.0-00E5FF?style=for-the-badge&logo=github)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Android](https://img.shields.io/badge/Android-5.0+-3DDC84?style=for-the-badge&logo=android)
![License](https://img.shields.io/badge/License-MIT-F59E0B?style=for-the-badge)

**专为《街头霸王6》（Street Fighter 6）玩家打造的高性能、电竞质感、全平台数据与战绩伴侣工具**

[✨ 核心特性](#-核心功能特性) • [🚀 快速开始](#-快速开始与构建) • [🔄 自动更新](#-github-release-自动更新机制) • [🏗️ 架构设计](#-项目架构与目录规范) • [🔒 隐私安全](#-本地隐私与安全声明)

</div>

---

## 🌟 核心功能特性

### 1. 🎮 多账号管理与跨平台数据隔离
- **全平台智能自适应嗅探**：自动精准识别玩家所在平台（**Steam (PC)、PlayStation (PS5/PS4)、Xbox Series X|S、Nintendo Switch**），彻底杜绝平台误判与串号。
- **多 Capcom ID 免密切换**：支持本地保存多个账号凭证，大号、小号与副账号自由一键切换。
- **纯原生 API 高速同步**：登录后全面使用高效原生请求，秒级抓取生涯对局、MR 分数、战队及好友数据。

### 2. 📊 仪表盘与无限战绩持久化
- **实时排位看板**：精准推导当前主玩角色（如艾莲娜 11864 LP 黄金 4 星、大师 MR 分等），呈现连胜加速指标与升段进度条。
- **永久本地战绩数据库**：突破官方仅保留 100 场的限制，通过 SQLite 永久归档每一场真实排位对局。
- **录像代码一键复制**：快速提取并复制 Replay Code 至剪贴板，便于在游戏内直接搜寻回放。

### 3. 🛠️ 官方全量角色帧数表与对策笔记
- **覆盖全量 28 名角色**：收录隆、肯、卢克、嘉米、春丽、豪鬼、维加 (Bison)、特瑞 (Terry)、不知火舞 (Mai)、艾莲娜 (Elena) 等全部角色的官方权威帧数数据。
- **多维度智能筛选**：支持按招式类别（通常技/特殊技/必杀技/SA超必杀/斗气系统）分类，支持一键高亮「被防有利 (+F)」与「被防大确反 (-F)」。
- **实战心得笔记**：针对特定角色或特定对手玩家记录起手习惯、受创确反与防守策略。

### 4. 📈 深度数据分析与胜率走势
- **MR 历史走势图**：平滑贝塞尔曲线呈现 Master Rating 波动峰值与低谷。
- **全角色克制矩阵**：统计对全游戏 28+ 名角色的对局胜率与胜负场比。

### 5. 👥 战队与好友实时动态
- **俱乐部天梯榜**：实时同步战队成员在线状态、月度贡献点与战队天梯积分。
- **好友对战状态**：监控好友所在游戏模式（Fighting Ground、Battle Hub、自定义房间）。

---

## 🔄 GitHub Release 自动更新机制

本项目内置 **`UpdateService`**，支持在应用内直接检查最新版本：

1. **一键检测**：在【设置】页点击「检查新版本」，自动对接 GitHub Releases API 检索最新安装包；
2. **更新日志呈现**：弹窗直接展示当前版本的详细更新日志与发布日期；
3. **双通道极速下载**：
   - **国内高速镜像源**：通过 `ghproxy.net` CDN 加速直链，无需梯子极速下载；
   - **GitHub 官方源**：直达 GitHub Release 官方发布页。

---

## 🏗️ 项目架构与目录规范

```
SF6_Tracker/
├── android/                        # Android 原生平台配置与清单
├── assets/                         # 本地静态资源 (角色立绘/段位徽章/帧数库)
│   ├── images/
│   │   ├── characters/             # 全角色高清头像
│   │   └── ranks/                  # 官方段位阶梯徽章
│   └── data/
│       └── framedata/              # 离线权威帧数 JSON 数据库
├── lib/
│   ├── main.dart                   # 应用入口与全局错误守卫
│   ├── app.dart                    # 根应用容器与动态模块导航
│   ├── core/                       # 核心底层基础设施
│   │   ├── constants/              # 颜色主题、API端点、角色/段位字典表
│   │   ├── network/                # Buckler Client 与 __NEXT_DATA__ 解析引擎
│   │   ├── storage/                # SQLite 本地归档与加密凭据存储
│   │   ├── theme/                  # 电竞暗黑/街头涂鸦/Material主题
│   │   └── utils/                  # 全链路黑匣子日志与工具函数
│   ├── models/                     # 账号、对局、战队、帧数表、笔记强类型数据模型
│   ├── services/                   # 认证、战绩同步、图表计算、更新检测核心服务
│   │   ├── auth_service.dart       # 多账号与凭证管理
│   │   ├── battle_log_service.dart # 对战记录与个人档案计算
│   │   ├── frame_data_service.dart # 全量角色帧数表核心引擎
│   │   ├── update_service.dart     # GitHub Release 自动检查更新服务
│   │   ├── stats_service.dart      # 数据分析与克制矩阵计算
│   │   └── social_service.dart     # 战队与好友数据聚合
│   └── ui/                         # 表现层 UI
│       ├── screens/                # 首页、战绩、分析、工具箱、社交、设置、登录
│       └── widgets/                # 角色头像、段位徽章、胜率条、雷达图、战报卡片
└── test/                           # 自动化测试与解析器校验套件
```

---

## 🚀 快速开始与构建

### 环境要求
- [Flutter SDK](https://flutter.dev/) (>= 3.0.0)
- Android Studio / Android SDK (API Level >= 21)

### 构建命令
```bash
# 1. 克隆代码仓库
git clone https://github.com/OldSea/SF6_Assistant.git
cd SF6_Assistant

# 2. 安装依赖
flutter pub get

# 3. 运行全部单元测试
flutter test

# 4. 编译 Release APK (分架构瘦身包)
flutter build apk --release --split-per-abi
```

编译产物位于 `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`。

---

## 🔒 本地隐私与安全声明

- **本地优先架构 (Local-First)**：本应用为纯客户端架构，**绝不上报任何用户密码、会话凭证或隐私数据**至任何第三方服务器。
- **硬件加密存储**：所有 Capcom ID 鉴权 Cookie 均通过系统加密通道（Android Keystore / `flutter_secure_storage`）安全加密存储在用户设备本地。

---

## 📄 开源许可证

本项目遵循 [MIT License](LICENSE) 协议开源。欢迎提交 Issue 与 Pull Request！

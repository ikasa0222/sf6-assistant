# 街霸6助手 (SF6 Assistant) 软件规格说明书 (SRS)

- **文档标识**: SF6-SPEC-v1.2.6.5
- **目标版本**: `v1.2.6.5` (build `2605`)
- **前序版本**: `v1.2.6.4` (build `2604`)
- **分析师角色**: 严苛的软件规格分析师 (Strict Software Specification Analyst)
- **文档状态**: 待人工审核挂起 (PENDING_HUMAN_APPROVAL)
- **生成时间**: 2026-10-05
- **密级与范畴**: iOS 未签名 IPA 云端构建流水线、工程合规、打包脚本、免越狱侧载手册与版本演进

---

## 1. 背景与目标定义 (Background & Objectives)

### 1.1 问题背景与业务痛点
1. **iOS 平台分发困境与未签名 IPA 迫切需求**：
   - 目前应用仅在 GitHub Actions 构建并分发 Android APK（`arm64-v8a`, `armeabi-v7a`, `x86_64`），广大 iOS 格斗玩家无法直接体验应用；
   - 官方苹果开发者账号（Apple Developer Program）年费高昂（$99/年）且 App Store 审核周期冗长、条款严苛；
   - 在越狱/免越狱 iOS 玩家社区中，**未签名 IPA（Unsigned IPA）侧载分发**已成为开源工具类 App 最成熟、普及度最高的标准分发形态（玩家可通过 TrollStore 巨魔商店一键永久安装，或通过 Sideloadly / 爱思助手 / AltStore 使用个人免费 Apple ID 免费自签安装）；
   - 当前项目缺乏自动化构建未签名 IPA 的 CI/CD 云端工作流，且本地缺乏一键组装 `Payload/` 并封装 IPA 的规范化打包工具脚本。
2. **iOS 原生工程配置合规性缺失**：
   - 侧载安装工具在提取与重签名 IPA 时，强依赖 `Info.plist` 中的应用元数据（显示名称、Bundle Identifier、权限描述字符串）；若相册权限（`NSPhotoLibraryAddUsageDescription`）或网络安全传输（`NSAppTransportSecurity`）未完整合规，会导致保存战绩长图闪退或数据接口被 iOS ATS 拦截。
3. **用户端侧载认知壁垒与教程空缺**：
   - 绝大多数普通 iOS 玩家对 IPA 文件如何安装至 iPhone/iPad 缺乏认知，易因未开启“开发者模式”或未信任开发者证书而误以为应用损坏；
   - 亟需在项目 `README.md` 与 `WIKI.md` 中建立体系化、保姆级的【iOS 用户免越狱安装指引 (侧载手册)】，解答 TrollStore 直装、Sideloadly 7 天自签、7 天到期续签与数据保留等关键疑惑。
4. **版本元数据升阶**：
   - 依据工程规范，版本全局同步递增至 `v1.2.6.5 (build 2605)`。

### 1.2 改造目标
- 完善并整合 GitHub Actions 工作流（`.github/workflows/build-ios.yml` 及 `.github/workflows/build-release.yml`），在 tag 推送或手动触发时，自动通过云端 `macos-latest` 运行测试并编译打包无签名 IPA（`SF6_Assistant_${TAG}_unsigned.ipa` 与 `SF6_Assistant_${TAG}.ipa`），自动注入 Release Assets；
- 全面规范 `ios/Runner/Info.plist`，确保应用名称、权限说明、网络放行完整合规，无缝兼容主流侧载工具；
- 在 `scripts/` 目录下提供本地自动化打包脚本（`package_unsigned_ipa.sh` 与 `package_unsigned_ipa.ps1`），支持跨终端一键编译并封装 IPA；
- 在 `README.md` 与 `WIKI.md` 编写完整的 iOS 免越狱侧载安装指南与常见问题 FAQ；
- 全局版本同步升级至 `1.2.6.5 (build 2605)`。

---

## 2. 架构影响与受影响模块矩阵 (Architecture Impact Matrix)

| 规格编号 (REQ ID) | 模块层级 | 受影响源文件路径 | 核心影响范围与交互组件 |
| :--- | :--- | :--- | :--- |
| **REQ-IPA-001** | CI/CD / Actions | `.github/workflows/build-ios.yml`<br>`.github/workflows/build-release.yml` | GitHub Actions 云端 macOS 自动化流水线：Flutter 测试、无签名编译、Payload 组装、Release 自动上传 |
| **REQ-IPA-002** | iOS Native / Config | `ios/Runner/Info.plist`<br>`ios/Runner.xcodeproj/project.pbxproj` | CFBundleDisplayName（街霸6助手）、相册导出权限说明、网络 ATS 放行、120Hz 高刷配置与侧载工具兼容性 |
| **REQ-IPA-003** | Automation / Script | `scripts/package_unsigned_ipa.sh`<br>`scripts/package_unsigned_ipa.ps1` | 本地跨平台一键无证书编译与 IPA 组装封装脚本、产物完整性校验与文件大小输出 |
| **REQ-DOC-001** | Documentation | `README.md`<br>`WIKI.md` | 用户端 iOS 免越狱安装指引：TrollStore 直装、Sideloadly 7 天自签、iOS 16+ 开发者模式、数据保留续签与 FAQ |
| **REQ-VER-001** | Build / Config | `pubspec.yaml`<br>`lib/core/utils/app_logger.dart` | 应用版本号升级至 `1.2.6+2605`，日志器与诊断系统升级至 `v1.2.6.5` |
| **REQ-DAT-003** | Model / Data / UI | `lib/models/frame_data_model.dart`<br>`lib/data/frame_data_database.dart`<br>`lib/ui/widgets/move_detail_modal.dart` | 必杀技轻/中/重/OD四版本独立真实数据模型构建、官方数据录入与变种表真实渲染 (v1.2.6.4 继承) |
| **REQ-CHT-003** | UI / Chart | `lib/ui/widgets/ranked_score_chart_card.dart` | 排位折线图标题纯中文化、维度切换二级展开菜单（PopupMenuButton）、Y轴刻度段位色彩动态渲染 (v1.2.6.4 继承) |
| **REQ-CHT-004** | UI / Service | `lib/ui/widgets/ranked_score_chart_card.dart` | 主玩角色切换即时感知、空排位战绩安全展示与友好占位兜底 (v1.2.6.4 继承) |
| **REQ-HOM-001** | UI / Storage | `lib/models/home_card_config.dart`<br>`lib/ui/screens/home/home_screen.dart`<br>`lib/ui/screens/settings/settings_screen.dart` | 首页 7 大核心卡片显隐与拖拽排序自定义引擎、本地永久持久化与设置页管理入口 (v1.2.6.4 继承) |
| **REQ-RPL-001** | UI / System | `lib/ui/screens/battle_log/match_history_screen.dart` | 战绩卡片 Replay Code 复制徽章与游戏内检索 5 步使用指引 (v1.2.6.3 继承) |
| **REQ-TOL-001** | Service / UI | `lib/services/frame_data_service.dart` | 工具箱默认角色与当前主玩角色自适应深度绑定 (v1.2.6.3 继承) |
| **REQ-DAT-002** | Data / Domain | `lib/data/frame_data_database.dart` | 帧数数据库非官方假角色物理清洗、全角色独立真实 18 招普通技对齐 (v1.2.6.3 继承) |
| **REQ-GIF-004** | Core / Cache | `lib/utils/sf6_move_media_helper.dart` | 碰撞框动图本地应用沙盒磁盘持久化缓存、0ms 秒开与 APK 体积工程权衡 (v1.2.6.3 继承) |

---

## 3. 功能需求规格逐项拆解 (Detailed Functional Specifications)

---

### REQ-IPA-001: GitHub Actions 云端 macOS 自动化未签名 IPA 构建与 Release 发布流水线规范
- **需求描述**:
  由于开发者在 Windows 环境下无法本地编译 iOS 原生二进制文件，且 iOS 玩家急需直接下载可用 IPA。必须完善并维护 GitHub Actions 云端流水线（`.github/workflows/build-ios.yml` 与 `.github/workflows/build-release.yml`），基于 GitHub 托管的 `macos-latest` 虚拟机，在触发发布标签（`v*`）或手动派发（`workflow_dispatch`）时，全自动执行代码检出、依赖安装、单测验证、未签名 iOS 编译、Payload 组装压缩及 GitHub Release 自动发布。
- **输入输出与触发契约**:
  - **触发条件 (Triggers)**:
    - 标签推送：`push: tags: ['v*']`（如 `v1.2.6.5`）
    - 手动调度：`workflow_dispatch`（支持手动选定分支快速打包诊断）
  - **云端宿主环境**: `runs-on: macos-latest`
  - **执行管道步骤 (Pipeline Stages)**:
    1. **Checkout Code**: `actions/checkout@v4`（检出全量源码）
    2. **Setup Flutter**: `subosito/flutter-action@v2`，严格锁定 `flutter-version: '3.22.x'`，`channel: 'stable'`，`cache: true`
    3. **Install Dependencies**: `flutter pub get`
    4. **Run Verification Tests**: `flutter test`（强制运行全量单元测试，测试失败立即熔断，严禁带病打包）
    5. **Build iOS Application**:
       ```bash
       flutter build ios --release --no-codesign
       ```
       编译生成原生应用包 `build/ios/iphoneos/Runner.app`。
    6. **Assemble Payload & Package IPA**:
       - 创建标准 iOS 安装包结构目录 `Payload/`；
       - 将 `build/ios/iphoneos/Runner.app` 完整递归复制至 `Payload/` 目录下；
       - 提取当前发布标签 `TAG_NAME="${{ github.ref_name }}"`（若为空则兜底为 `v1.2.6.5` 或 `latest`）；
       - 生成规范命名产物：
         - 产物 1 (主要产物): `SF6_Assistant_${TAG_NAME}_unsigned.ipa`
         - 产物 2 (兼容软链/副本): `SF6_Assistant_${TAG_NAME}.ipa`（适配部分不识别 `_unsigned` 后缀的旧版工具）
       - 压缩命令规范：`zip -r -q <target_ipa> Payload`，禁止将额外目录打包进压缩包根目录。
    7. **Publish to GitHub Release**:
       - 使用 `softprops/action-gh-release@v2`；
       - `files`: `release-ios/*.ipa`（包含上述生成的所有 IPA 文件）；
       - 鉴权配置：`permissions: contents: write`；
       - 仅在 `startsWith(github.ref, 'refs/tags/')` 时发布至正式 Release Assets，使 iOS 玩家与 Android APK 在同一 Release 页面并列下载。
- **边界条件与异常处理**:
  - 若 `build/ios/iphoneos/Runner.app` 构建失败不存在，流水线必须退出并抛出非 0 状态码，禁止生成 0 字节损坏 IPA；
  - 手动触发（`workflow_dispatch`）非 tag 情况下，将生成的 IPA 作为 Actions Artifact (`actions/upload-artifact@v4`) 归档保存，保留天数设为 14 天，供测试人员下载。
- **验收标准 (Given-When-Then)**:
  - **Given** 开发者向仓库推送新版本标签 `git tag v1.2.6.5 && git push origin v1.2.6.5`；
  - **When** GitHub Actions `build-ios` 工作流被自动触发执行；
  - **Then** 工作流在 macOS 镜像上成功运行 `flutter test` 并执行 `flutter build ios --release --no-codesign`；
  - **Then** 成功生成内含 `Payload/Runner.app` 结构的两个 IPA 文件；
  - **Then** GitHub 对应 Release 的 Assets 列表中确切出现 `SF6_Assistant_v1.2.6.5_unsigned.ipa` 与 `SF6_Assistant_v1.2.6.5.ipa`，文件大小正常（约 30MB~50MB）。

---

### REQ-IPA-002: iOS 原生工程合规、权限声明与侧载兼容性规范
- **需求描述**:
  第三方侧载重签名工具（TrollStore 巨魔商店、Sideloadly、爱思助手、AltStore、轻松签等）在将未签名 IPA 安装至 iOS 设备时，会对应用的 Bundle Identifier、显示名称以及权限描述进行静态解析。若缺少必要的合规配置，会导致应用安装后图标无名称、图片导出闪退或网络请求受限。
  必须对 `ios/Runner/Info.plist` 与 Xcode 工程配置进行严格审计与规范化加固。
- **输入输出与配置规范**:
  - **配置文件路径**: `ios/Runner/Info.plist`
  - **核心配置键值标准**:
    1. **应用中文显示名 (CFBundleDisplayName)**:
       ```xml
       <key>CFBundleDisplayName</key>
       <string>街霸6助手</string>
       ```
       确保在 iOS 主屏幕、多任务界面、TrollStore 列表及设置中均明确显示为“街霸6助手”，禁止显示为默认工程代号 `sf6_tracker`。
    2. **相册存储权限声明 (NSPhotoLibraryAddUsageDescription)**:
       ```xml
       <key>NSPhotoLibraryAddUsageDescription</key>
       <string>保存战绩海报长图到系统相册</string>
       ```
       用于在战绩海报、角色雷达图长图导出时安全调用 iOS PhotoKit，声明文案清晰合理，杜绝苹果沙盒权限拒绝崩溃。
    3. **网络安全传输策略 (NSAppTransportSecurity)**:
       ```xml
       <key>NSAppTransportSecurity</key>
       <dict>
           <key>NSAllowsArbitraryLoads</key>
           <true/>
       </dict>
       ```
       允许跨域访问卡普空官方数据节点、海外媒体镜像及代理通道。
    4. **高刷屏帧率支持 (CADisableMinimumFrameDurationOnPhone)**:
       ```xml
       <key>CADisableMinimumFrameDurationOnPhone</key>
       <true/>
       ```
       放开 iPhone 13 Pro 及后续机型的 120Hz ProMotion 流畅帧率。
    5. **包标识符与执行体规范**:
       - `CFBundleExecutable`: `$(EXECUTABLE_NAME)`
       - `CFBundleIdentifier`: `$(PRODUCT_BUNDLE_IDENTIFIER)`（工程默认 `com.sf6.tracker`）
       - `CFBundlePackageType`: `APPL`
       - `LSRequiresIPhoneOS`: `<true/>`
  - **架构与部署目标要求**:
    - 架构支持：`arm64` 原生 64 位指令集；
    - 最低支持系统：iOS 12.0 或更高版本（兼容 iPhone 6s 及以上全量设备）。
- **边界条件与异常处理**:
  - 侧载工具可能会在签名阶段动态修改 `CFBundleIdentifier`（例如根据免费个人证书添加随机后缀），`Info.plist` 中的配置必须使用标量字符串或标准 Xcode 占位宏，禁止包含硬编码未闭合符号导致 `plutil` 解析崩溃。
- **验收标准 (Given-When-Then)**:
  - **Given** 用户通过 TrollStore 或 Sideloadly 将未签名 IPA 安装至 iOS 设备；
  - **When** 查看 iOS 手机桌面图标；
  - **Then** 应用图标下方清晰展示名称“街霸6助手”；
  - **When** 用户在战绩界面点击“保存战绩海报到相册”；
  - **Then** 系统弹出合规的权限弹窗（显示“保存战绩海报长图到系统相册”），授权后图片顺利存入相册，无闪退；
  - **When** 玩家在 iPhone 15 Pro 上滑动招式列表；
  - **Then** 满帧 120 FPS 流畅渲染，无锁帧卡顿。

---

### REQ-IPA-003: 本地跨平台一键无证书编译与 IPA 打包辅助脚本规范
- **需求描述**:
  为满足开发者或拥有本地构建环境的高级玩家在本地（macOS、Linux 或配置了交叉编译环境的终端）一键生成未签名 IPA 的需求，必须在 `scripts/` 目录下提供标准化的自动化打包辅助脚本：
  - `scripts/package_unsigned_ipa.sh`（适用于 macOS / Linux / Git Bash）
  - `scripts/package_unsigned_ipa.ps1`（适用于 Windows PowerShell 环境下的辅助操作与自动化调度）
- **输入输出与脚本功能规范**:
  - **输入参数**:
    - 可选环境变量 `TAG_NAME`（若未指定，脚本自动从 `pubspec.yaml` 中正则解析版本号，如 `v1.2.6.5`）。
  - **执行流程 (Execution Flow)**:
    1. **环境预检 (Environment Pre-check)**:
       - 检查系统是否安装 `flutter`，验证 `flutter --version`；
       - 若在 macOS 下，检查 `xcodebuild` 是否就绪；若非 macOS 则提示通过云端 CI/CD 或特定工具链构建；
    2. **依赖获取与单测运行 (Pub Get & Test)**:
       - 执行 `flutter pub get`；
       - 执行 `flutter test`，若存在失败测试用例则中断退出；
    3. **构建无代码签名 iOS App (Build iOS)**:
       - 执行 `flutter build ios --release --no-codesign`；
       - 检查产物 `build/ios/iphoneos/Runner.app` 是否存在，若缺失则退出并打印详细错误；
    4. **目录组装与封包 (Payload Assembly & Packaging)**:
       - 清理旧的暂存目录 `build/ipa_staging`；
       - 创建 `build/ipa_staging/Payload`；
       - 将 `Runner.app` 完整拷贝至 `build/ipa_staging/Payload/`；
       - 进入 `build/ipa_staging` 目录，执行打包命令：
         ```bash
         zip -r -q "SF6_Assistant_${TAG_NAME}_unsigned.ipa" Payload
         cp "SF6_Assistant_${TAG_NAME}_unsigned.ipa" "SF6_Assistant_${TAG_NAME}.ipa"
         ```
       - 将打包好的 IPA 移动至根目录 `release/` 或输出目录；
    5. **产物验证与报告 (Verification & Report)**:
       - 检查 IPA 文件大小；
       - 输出绿色完成提示，打印输出文件绝对路径与 MD5/SHA256 哈希值。
- **边界条件与异常处理**:
  - 临时工作目录清理：脚本在退出时（无论成功还是异常报错），必须执行 `trap` 清理临时暂存目录 `build/ipa_staging`，禁止遗留冗余垃圾文件；
  - 路径空格保护：脚本中的所有变量和路径引用必须使用双引号包裹，防止路径中包含空格导致解析截断。
- **验收标准 (Given-When-Then)**:
  - **Given** 开发者在 macOS 终端进入项目根目录；
  - **When** 运行 `./scripts/package_unsigned_ipa.sh`；
  - **Then** 脚本自动完成测试、编译、组装 Payload 并输出 `SF6_Assistant_v1.2.6.5_unsigned.ipa`；
  - **When** 解压该 IPA 检查内部结构；
  - **Then** 根目录下仅存在 `Payload` 目录，其内部包含完整的 `Runner.app`。

---

### REQ-DOC-001: 用户端免越狱安装与侧载手册规范 (README & WIKI)
- **需求描述**:
  针对普通 iOS 玩家不了解如何安装未签名 `.ipa` 文件的现状，必须在项目官方文档（`README.md` 与 `WIKI.md`）中建立体系化、图文并茂、步骤清晰的【iOS 用户免越狱安装指引 (侧载手册)】。必须覆盖市面上最主流的安装路径，涵盖永久免签方案、7天免费自签方案、iOS 16+ 开发者模式引导、7天到期续签与数据保留机制以及常见问题 FAQ。
- **文档结构与内容契约**:
  在 `README.md` 的下载板块及 `WIKI.md` 的专属章节中，严格包含以下内容结构：

  ```markdown
  ### 📱 iOS 用户安装指引 (免越狱侧载)

  街霸6助手为 iOS 用户提供未签名 `.ipa` 安装包，您可通过以下三种方式之一在 iPhone / iPad 上安装使用：

  #### 方案 A: 巨魔商店 (TrollStore) —— 【最推荐 · 永久使用 · 免越狱】
  - **适用设备**: 
    - iOS 14.0 ~ 15.8.3 (全机型)
    - iOS 16.0 ~ 16.6.1 (全机型)
    - iOS 17.0 (部分支持机型)
  - **安装步骤**:
    1. 在本 Release 页面下载 `SF6_Assistant_vX.X.X.X_unsigned.ipa`；
    2. 使用 Safari 浏览器下载后，点击分享按钮，选择【通过 TrollStore 打开】；
    3. 点击【Install】，秒级安装完成！
    4. **优势**: **永久有效**、无需证书、永不掉签、免越狱、无需电脑。

  #### 方案 B: 电脑工具自签 (Sideloadly / 爱思助手) —— 【全系统支持 · 7天自签】
  - **适用设备**: iOS 12.0 ~ iOS 18.x 全版本 iOS 设备（无需越狱，需电脑辅助）。
  - **使用 Sideloadly (推荐，支持 Windows & macOS)**:
    1. 电脑端下载并安装 [Sideloadly 官网](https://sideloadly.io/)；
    2. 使用数据线将 iPhone 连接至电脑，在手机上点击“信任此电脑”；
    3. 打开 Sideloadly，将下载的 `.ipa` 文件拖拽至左侧 IPA 图标区；
    4. 在【Apple ID】输入框中输入您的个人 Apple ID 邮箱（免费个人账号即可）；
    5. 点击【Start】，根据提示输入 Apple ID 密码（仅用于与苹果服务器通信申请免费证书，安全可靠）；
    6. 等待进度条达到 100% (Done)，手机桌面上即会出现【街霸6助手】图标。

  #### ⚠️ 安装后首次打开必看：
  1. **信任证书**:
     - 进入手机【设置】->【通用】->【VPN 与设备管理】；
     - 在“开发者 App”下方点击您的 Apple ID，点击【信任】。
  2. **开启开发者模式 (仅 iOS 16 及更高系统)**:
     - 进入手机【设置】->【隐私与安全性】-> 滑动到底部找到【开发者模式】；
     - 开启开关，按提示【重启手机】，开机后点击【开启】并输入锁屏密码。

  #### 🔄 关于 7 天到期续签与数据保留说明：
  - **免费个人 Apple ID 签名有效期为 7 天**。7 天到期后应用可能提示“无法验证应用”；
  - **续签操作**: 无需卸载！只需将手机重新连上电脑，用 Sideloadly 重新签名安装一次即可；
  - **数据绝对安全**: 重新覆盖安装**不会丢失任何历史对战记录、本地笔记与配置数据**。

  #### ❓ 常见问题 FAQ:
  - **Q: 提示“无法验证应用”或闪退？**  
    A: 请检查是否开启了 iOS 16+ 的【开发者模式】，并确保在【VPN 与设备管理】中信任了证书。
  - **Q: 提示“无法连接网络”或战绩拉取失败？**  
    A: 请进入手机【设置】->【无线局域网】->【使用无线局域网与蜂窝网络的 App】，找到【街霸6助手】，确保勾选了“无线局域网与蜂窝网络”。
  - **Q: 能否通过爱思助手 / AltStore / 牛蛙助手安装？**  
    A: 完全支持！爱思助手用户可直接使用其内置的“IPA 自签名”功能直接安装。
  ```

- **边界条件与异常处理**:
  - 文档中的第三方工具官网链接必须权威有效，禁止包含钓鱼或失效短链接；
  - 必须明确加粗告知用户“覆盖安装不丢失数据”，避免用户每次到期误卸载导致本地战绩历史丢失。
- **验收标准 (Given-When-Then)**:
  - **Given** 任意 iOS 玩家访问项目仓库主页或 Release 页面；
  - **When** 查阅 `README.md` 与 `WIKI.md`；
  - **Then** 能够清晰找到针对 iOS 未签名 IPA 的完整安装教程，覆盖 TrollStore 与 Sideloadly 两种核心方案；
  - **Then** 按照教程操作，新手玩家能在 5 分钟内顺利完成自签安装并成功打开应用。

---

### REQ-VER-001: 应用版本号与构建编号统一升阶至 1.2.6.5 (build 2605)
- **需求描述**:
  由于本次新增了未签名 IPA 云端流水线构建支持、完善了 iOS 原生合规配置并新增打包自动化脚本，依据项目版本演进规范，全局版本号必须严格同步递增至 `v1.2.6.5 (build 2605)`。
- **变更文件与配置项**:
  1. `pubspec.yaml`:
     - 原值: `version: 1.2.6+2604`
     - 目标值: `version: 1.2.6+2605`
  2. `lib/core/utils/app_logger.dart`:
     - 原值: `static const String currentAppVersion = 'v1.2.6.4';`
     - 目标值: `static const String currentAppVersion = 'v1.2.6.5';`
     - 原值: `static const String currentBuildNumber = '2604';`
     - 目标值: `static const String currentBuildNumber = '2605';`
- **验收标准 (Given-When-Then)**:
  - **Given** 项目配置与代码更新完毕；
  - **When** 导出运行日志或查看应用内诊断；
  - **Then** 日志头部与关于页面确切显示为 `v1.2.6.5 (build 2605)`。

---

## 4. 前序基础功能规格固化 (Base Functional Specifications)

为了保证系统规格的连续性与完整性，前序已验收并投入生产的核心规格在此保持固化生效：

1. **REQ-DAT-003: 必杀技四版本真实数据结构与变种表**
   - 严禁任何 `startup +2, +4, -2` 伪造计算；
   - 基于 `MoveVariation` / `FrameMove.variations` 强类型模型录入轻/中/重/OD 官方真实发生帧、被防差、伤害与无敌帧；详情弹窗变种表 100% 真实渲染。
2. **REQ-CHT-003 & REQ-CHT-004: 排位分数折线图交互升阶与主玩联动**
   - 标题纯中文“排位分数走势”，去除冗余英文与括号；
   - 维度切换改右上角二级展开菜单（`PopupMenuButton`），折叠展示 `[近20场 ▾]`，杜绝窄屏溢出；
   - Y 轴刻度基于 `Sf6Rank.fromLpOrMr` 动态渲染大师金/钻石蓝/白金绿段位官方色彩；
   - 监听主玩角色变动即时同步；空排位记录安全切换并友好兜底提示“暂无排位赛记录（进行2场以上即可生成走势图）”。
3. **REQ-HOM-001: 首页 7 大核心卡片显隐与拖拽排序自定义**
   - 涵盖 `hero`, `score_chart`, `ladder`, `recent_form`, `play_time`, `quick_stats`, `radar`；
   - 设置页增设「首页卡片管理」入口，支持 `ReorderableListView` 拖拽排序与 `Switch` 显隐，支持一键恢复默认；
   - 通过 `StorageService` 永久持久化保存配置，首页按自定义配置动态消费渲染。
4. **REQ-RPL-001: 战绩录像代码 (Replay Code) 复制与指引**
   - 战绩卡片展示 `REPLAY: {replayCode}` 胶囊，一键复制至剪贴板，提供游戏内 CFN 5 步检索观看详细指引。
5. **REQ-TOL-001: 工具箱主玩角色自适应深度联动**
   - 决策链路：`activePlatform.mainCharId` -> `userProfile.mainCharacterId` -> `'ryu'`，彻底推翻写死 `elena` / `luke`。
6. **REQ-DAT-002: 帧数库假角色清洗与独立真实普通技结构**
   - 物理删除 `sagat`, `cviper`, `alex`, `ingrid`, `yasmine` 假数据；全官方角色独立提供真实 18 招普通技数值。
7. **REQ-GIF-004: 碰撞框动图本地磁盘持久化缓存架构**
   - 论证为何不将 1.2GB+ 动图打包进 APK；基于 `path_provider` 实现沙盒磁盘永久缓存，0ms 秒开，可统计可清理。
8. **REQ-GIF-001 ~ REQ-GIF-003, REQ-COS-001 ~ REQ-COS-002, REQ-CMB-001 ~ REQ-CMB-003**
   - 动图渐进式加载、二级检视首选动图、媒体助手字典覆盖；
   - 招式消耗精准分离（普通必杀 0 气、OD 2 气、SA 1~3 槽）；
   - 连招数据治理、6 大中文标准起手类型与智能容错。
9. **REQ-NAV-001, REQ-SHR-001, REQ-CMD-001, REQ-CMD-002, REQ-DAT-001, REQ-HTB-001**
   - 跨界面防自环导航、真实剪贴板分享、经典/现代标准图形指令渲染、豪鬼“车蹴”官方中文对齐、碰撞框 60FPS 逐帧播放内核。

---

## 5. 非功能性需求与性能指标 (Non-Functional Requirements & Performance Budgets)

### 5.1 CI/CD 流水线构建性能
1. **GitHub Actions 构建时限**:
   - `build-ios` 完整流水线耗时控制在 **12 分钟以内**（依托 Flutter Action 缓存与依赖预取）；
   - 单元测试运行时间控制在 **60 秒以内**；
   - 生成的未签名 IPA 文件体积严格控制在 **35 MB ~ 50 MB** 区间，禁止打包冗余无用的符号表与构建垃圾。

### 5.2 兼容性与原生稳定性
1. **iOS 侧载工具兼容率**:
   - 产出的 IPA 必须通过 TrollStore、Sideloadly、爱思助手、AltStore 100% 成功解析并完成签名安装；
   - 安装后冷启动时间 $\le 800\text{ms}$，首屏渲染零黑屏、零异常崩溃。
2. **文档可用性指标**:
   - 侧载安装指引步骤简明易懂，平均阅读与操作耗时 $\le 5\text{分钟}$。

---

## 6. 人工审核门禁与签署挂起清单 (Human Approval Gate & Sign-off)

> [!IMPORTANT]
> **软件规格分析师严格声明**：
> 本规格说明书已全面重构并严密拆解了用户最新提出的“未签名 IPA 方案”及系统需求：
> 1. GitHub Actions 云端 macOS 自动化未签名 IPA 构建与 Release 发布流水线 (`REQ-IPA-001`)；
> 2. iOS 原生工程合规配置（名称、相册权限、ATS放行、高刷与侧载兼容）(`REQ-IPA-002`)；
> 3. 本地跨平台一键无证书编译与 IPA 打包辅助脚本 (`REQ-IPA-003`)；
> 4. 用户端免越狱安装与侧载手册（TrollStore 直装、Sideloadly 7天自签、开发者模式、数据保留续签与 FAQ）(`REQ-DOC-001`)；
> 5. 目标版本递增至 `1.2.6.5 (build 2605)` (`REQ-VER-001`)。
>
> 遵循岗位职责约束，**本人严禁编写任何业务实现代码或单元测试代码。**
> 本规格文件（`specs/spec.md`）现已固化并处于**挂起等待人工审核状态 (PENDING_HUMAN_APPROVAL)**。

### 审核检查清单 (Audit Checklist)
- [ ] **REQ-IPA-001**: GitHub Actions 云端构建流水线（检出、Flutter 3.22.x、单测、无签名编译、Payload 组装、多命名上传）是否完备？
- [ ] **REQ-IPA-002**: `ios/Runner/Info.plist` 中名称、相册权限、ATS 策略及侧载工具兼容性声明是否精准无遗漏？
- [ ] **REQ-IPA-003**: 本地跨平台打包脚本（`.sh` 与 `.ps1`）的编译逻辑、Payload 组装与产物验证是否清晰严密？
- [ ] **REQ-DOC-001**: 用户端安装指引是否覆盖了 TrollStore、Sideloadly、iOS 16+ 开发者模式以及覆盖安装不丢数据的核心说明？
- [ ] **REQ-VER-001**: 目标版本 `1.2.6.5 (build 2605)` 与 `pubspec.yaml` `1.2.6+2605` 是否完全对齐？

---
*规格说明书编制完成，流水线挂起等待人工审核批准。*

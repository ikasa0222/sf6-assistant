# 街霸6助手 (SF6 Assistant) 软件规格说明书 (SRS)

- **文档标识**: SF6-SPEC-v1.2.7.1
- **目标版本**: `v1.2.7.1` (build `2701`)
- **前序版本**: `v1.2.7.0` (build `2700`)
- **分析师角色**: 严苛的软件规格分析师 (Strict Software Specification Analyst)
- **文档状态**: 待人工审核挂起 (PENDING_HUMAN_APPROVAL)
- **生成时间**: 2026-10-17
- **密级与范畴**: 阿俊立绘图标资产补齐、真机AssetBundle异步加载架构重构与测试降级、阿俊官方Supercombo权威帧数与指令全面矫正、版本元数据小版本升阶发布

---

## 1. 背景与目标定义 (Background & Objectives)

### 1.1 问题背景与核心痛点分析

在 `v1.2.7.0 (build 2700)` 引入新角色阿俊 (Arjun) 并进行全量数据库去伪存真治理后，用户与实机真机环境暴露出以下严重缺陷与阻断性问题：

1. **用户严重反馈 1：阿俊图标彻底缺失 (UI 404 / 破图)**：
   - `assets/images/characters/arjun.png` 在工程目录中彻底缺失；
   - `CharacterAvatar`、`ToolsScreen`、`HitboxViewerScreen`、`MoveActionPreview` 等组件均直接通过 `'assets/images/characters/${char.id}.png'` 加载角色头像与立绘图标；
   - 由于缺少该文件，导致阿俊在角色头像、招式预览、角色选择等界面无法展示阿俊图标，抛出资产缺失错误或呈现空白破图，严重破坏视觉一致性。

2. **用户严重反馈 2：数据大量缺失，有的直接空着，有的空了拳脚帧数 (真机资产加载架构失效)**：
   - **根因深度分析**：在 `lib/data/frame_data_database.dart` 中，旧逻辑在 `_ensureJsonLoaded()` 中使用了 `dart:io` 的 `File('assets/data/sf6_framedata.json')`；
   - 在 PC 开发机执行单元测试时，由于当前进程工作目录为工程根目录，`File('assets/...').existsSync()` 能正确命中物理文件；
   - **真机运行时彻底失效**：然而在 Android APK 与 iOS IPA 真机打包运行环境中，静态资产被封装打包在原生安装包内的虚拟 Asset Bundle（如 Android `assets/flutter_assets/`），`dart:io` 的 `File` 根本无法访问 APK 内部路径，导致 `file.existsSync()` 恒返回 `false`，真机运行时的 `_cachedJsonMoves` 永远为 `null`！
   - **连锁破坏效应**：
     - **“有的直接空着”**：对于未在 `FrameDataDatabase.getCharacterMoves()` 的 `switch` 中单独硬编码的 18 个格斗家（Luke, Terry, Bison, Marisa, JP, Manon, Ed, Rashid, Aki 等），其招式读取依赖 `default:` 分支中的 `_cachedJsonMoves`。由于真机上 `_cachedJsonMoves == null`，直接返回空列表 `[]`，真机用户打开这些角色时招式表全空；
     - **“有的空了拳脚帧数”**：对于在 `switch` 中配置了必杀技但普通技委托给 `_getNormalsFor(id)` 的角色，其 `_getNormalsFor(id)` 中的 `default:` 分支同样依赖 `_cachedJsonMoves`。真机上 `_cachedJsonMoves == null` 导致普通技列表返回 `[]`，用户进入招式表时仅看到必杀技而普通拳脚帧数完全空缺；
   - **架构重构诉求**：必须使用 Flutter 原生 `rootBundle.loadString('assets/data/sf6_framedata.json')` 结合 `FrameDataDatabase.init()` 彻底重构真机资产加载架构，同时在 `_ensureJsonLoaded()` 中保留 `File` 降级能力，确保纯 Dart / Flutter 单元测试免启动引擎依然 100% 兼容。

3. **用户严重反馈 3：阿俊数据存在臆想成分，需按照 Supercombo Wiki 权威数据矫正与补全**：
   - 旧版本阿俊普通技存在草案臆想数据（例如 5MP 填了 6F、5HP 填了 10F、5LK 填了 5F 等）；
   - 部分必杀技与超必杀技指令出现按键及方向笔误（如呼吸之环误填 214K，实际为 236K；神柱误填 22P，实际为 214K；阴森审讯未标注未防御引爆灰血机制；SA1 误为 236236K，实际为 236236P；SA3 误为 236236P，实际为 236236K 等）；
   - 必须严格按照 Supercombo Wiki 权威数据重新定义与对齐 18 招普通技、6 招核心必杀技（四版本独立变种）及 3 招超必杀技。

4. **版本元数据升阶发布规范**：
   - 配合本次关键缺陷修复与架构重构，版本元数据由 `v1.2.7.0 (build 2700)` 升阶至 `v1.2.7.1 (build 2701)`。

### 1.2 改造目标与量化指标

- **目标 1: 角色立绘图标 100% 覆盖**：新增 `assets/images/characters/arjun.png`，尺寸与格式符合项目规范，全应用 0 破图。
- **目标 2: 真机离线资产加载架构彻底打通**：通过 `rootBundle.loadString` + `FrameDataDatabase.init()` 在应用启动时完成数据预热，真机上非隆角色（18个角色）及全 32 位官方角色招式与普通技 100% 正常显示。
- **目标 3: 单元测试向下兼容与零劣化**：保持 `File` 同步降级加载机制，保证在纯 Dart 单测与 Flutter 单测中招式数据库均能无缝加载，测试通过率 100%。
- **目标 4: 阿俊权威数据 100% 对齐 Supercombo Wiki**：清除所有臆想数值与错误指令，实现 `FrameDataDatabase` 与 `sf6_framedata.json` 双端严格镜像一致。
- **目标 5: 版本元数据严密升阶**：`pubspec.yaml` 升至 `1.2.7+2701`，`app_logger.dart` 升至 `v1.2.7.1` (build `2701`)。

---

## 2. 架构影响与受影响模块矩阵 (Architecture Impact Matrix)

| 规格编号 (REQ ID) | 模块层级 | 受影响源文件路径 | 核心影响范围与交互组件 |
| :--- | :--- | :--- | :--- |
| **REQ-ICO-001** | UI / Asset | `assets/images/characters/arjun.png`<br>`lib/ui/widgets/character_avatar.dart`<br>`lib/ui/screens/tools/tools_screen.dart`<br>`lib/ui/screens/tools/hitbox_viewer_screen.dart`<br>`lib/ui/widgets/move_action_preview.dart` | 补齐阿俊透明背景 PNG 头像资产，解决角色头像、角色选择横轴、碰撞框角色切换、招式预览组件破图 404 故障 |
| **REQ-ASSET-001** | Core / Data | `lib/data/frame_data_database.dart`<br>`lib/main.dart`<br>`lib/services/frame_data_service.dart` | 重构真机资产加载架构，引入 `FrameDataDatabase.init()` 与 `rootBundle.loadString`，保留 `File` 单元测试降级机制，彻底根治 18 个非隆角色真机数据全空及普通技缺失缺陷 |
| **REQ-DAT-004** | Data / Spec | `lib/data/frame_data_database.dart`<br>`assets/data/sf6_framedata.json`<br>`lib/models/frame_data_model.dart`<br>`assets/data/sf6_combos.json`<br>`lib/utils/sf6_move_media_helper.dart` | 全面矫正阿俊 18 招普通技、6 招核心必杀技（指令纠正为呼吸之环 236K、神柱 214K、未防御灰血投等）与 3 招 SA (SA1 236236P, SA2 214214P, SA3 236236K)，严格对齐 Supercombo Wiki 权威数据 |
| **REQ-VER-001** | Build / Config | `pubspec.yaml`<br>`lib/core/utils/app_logger.dart` | 应用版本号小版本升级至 `1.2.7+2701`，日志诊断系统与应用运行元数据升级至 `v1.2.7.1 (build 2701)` |
| **REQ-ARJ-001** | Core / Domain | `lib/core/constants/characters.dart` | 阿俊全局常量注册（ID `arjun`、Capcom ID 35、shortCode `ARJ`）(v1.2.7.0 继承) |
| **REQ-ARJ-002** | Data / Stats | `lib/data/character_stats_database.dart` | 阿俊官方权威体能立回参数（HP 10500、走速、前冲 20F/1.280 等）(v1.2.7.0 继承) |
| **REQ-ARJ-004** | Asset / Combo | `assets/data/sf6_combos.json`<br>`lib/data/sf6_combos_database.dart` | 阿俊 6 大中文标准起手连招库（连动更新指令为 236K/214K/SA 修正指令）(v1.2.7.0 继承并协同对齐) |
| **REQ-ARJ-005** | Service / Media | `lib/services/notes_service.dart`<br>`lib/utils/sf6_move_media_helper.dart` | 阿俊对战心得与媒体动图映射（连动指令别名兼容）(v1.2.7.0 继承并协同对齐) |
| **REQ-AUD-001** | Data / Cleanse | `lib/data/frame_data_database.dart`<br>`assets/data/sf6_framedata.json` | 彻底清除克隆隆数据回退机制，全角色普通技独立对齐 (v1.2.7.0 继承) |
| **REQ-AUD-002** | Data / Cleanse | `lib/data/character_stats_database.dart` | 彻底清理泛型假数据 fallback，32 位官方格斗家权威机体属性覆盖 (v1.2.7.0 继承) |
| **REQ-IPA-001 ~ 003** | CI/CD / iOS | `.github/workflows/`, `ios/`, `scripts/` | iOS 未签名 IPA 构建流水线、Info.plist 原生合规与本地打包脚本 (v1.2.6.5 继承) |

---

## 3. 功能需求规格逐项拆解 (Detailed Functional Specifications)

---

### REQ-ICO-001: 阿俊 (Arjun) 角色头像与界面图标资源补齐规范

#### 1. 需求描述
用户反馈阿俊的图标完全缺失，导致在真机或模拟器中使用该角色时，头像区域呈现空白、破图或抛出 `Unable to load asset: assets/images/characters/arjun.png` 异常。
本需求要求在工程中正式补充阿俊的官方头像立绘静态资源 `assets/images/characters/arjun.png`，打通全应用所有以 `'assets/images/characters/${char.id}.png'` 为模式的图标消费链路，并建立优雅的资产加载容错机制。

#### 2. 输入输出与数据契约
- **目标资产文件路径**:
  - `E:\SF6_Tracker\assets\images\characters\arjun.png`
- **资产规格要求**:
  - **格式**: 32-bit RGBA 格式 PNG（透明背景，无硬边白色杂底）；
  - **尺寸与分辨率**: 正方形像素比例，基准分辨率不低于 $256 \times 256$ 像素（建议 $300 \times 300$ 至 $512 \times 512$ 像素，与既有 `ryu.png`、`luke.png` 保持同级清晰度）；
  - **内容构图**: 街头霸王 6 官方风格阿俊角色半身/面部特写，色调与光影与既有 31 位角色立绘风格统一；
  - **体积控制**: 经 pngcrush/optipng 优化，单个文件体积控制在 $120\text{KB} \sim 220\text{KB}$ 之间，避免膨胀 APK 安装包体积。
- **打包清单配置 (`pubspec.yaml`)**:
  - `pubspec.yaml` 中已有 `- assets/images/characters/` 目录级注册，文件加入后自动纳入 Flutter Asset Bundle，无须修改资产声明路径。
- **UI 消费组件契约**:
  1. `lib/ui/widgets/character_avatar.dart`:
     - 当传入 `Sf6Character(id: 'arjun', ...)` 时，`AssetImage('assets/images/characters/arjun.png')` 正常命中并解码；
     - 必须保留 `errorBuilder`，当极端环境资产加载受阻时优雅呈现阿俊名字简写 `'AR'` 或默认剪影，杜绝抛出红色 Crash Widget；
  2. `lib/ui/screens/tools/tools_screen.dart`:
     - 顶部格斗家横向选择滑动列表中，阿俊圆形/圆角矩形头像正常展示，选中有高亮外框；
  3. `lib/ui/screens/tools/hitbox_viewer_screen.dart`:
     - 角色选择抽屉及招式碰撞框标题栏角色小图标正常渲染；
  4. `lib/ui/widgets/move_action_preview.dart`:
     - 招式操作详情卡片左侧角色标识正常渲染。

#### 3. 边界条件与异常处理
- **边界条件 1 (大小写兼容)**:
  - 角色 ID 在传参时可能偶发包含大写字母（如 `'Arjun'` 或 `'ARJUN'`），UI 组件必须在拼装路径前统一通过 `toLowerCase().trim()` 转为小写，确保精确定位 `arjun.png`（避免在 Linux/Android 等大小写敏感文件系统上 404）；
- **边界条件 2 (网络离线与资产损坏防护)**:
  - 若设备因磁盘故障或包体受损导致 Asset 加载失败，`Image.asset` 的 `errorBuilder` 必须捕获 `FlutterError` 并安全回退为带渐变背景的文字占位符（包含“阿俊”或“AR”），严禁出现应用无响应 (ANR) 或白屏；
- **边界条件 3 (内存缓存控制)**:
  - 32 位角色快速滑动切换时，Flutter 原生 `PaintingBinding.instance.imageCache` 自动管理内存缓存，避免重复解码导致主线程掉帧。

#### 4. 验收标准 (Given-When-Then)
- **Given** 应用已编译并在真机或模拟器中启动；
- **When** 用户进入【工具箱 -> 招式帧数表 / 基础属性 / 实用连招 / 碰撞框检视】；
- **Then** 角色列表中阿俊展示专属立绘图标，画面清晰、Alpha 通道边缘透明平滑；
- **When** 在工具箱顶部快速横向滑动切换角色并选中“阿俊”；
- **Then** 控制台无任何 `FlutterError: Unable to load asset` 报错日志，界面渲染流畅无掉帧；
- **When** 在断网离线状态下冷启动应用并查看阿俊头像；
- **Then** 依然能够 100% 正常显示离线打包的阿俊头像。

---

### REQ-ASSET-001: 帧数数据库真机资产加载重构与单元测试降级架构

#### 1. 需求描述
旧版本 `FrameDataDatabase` 使用 `dart:io` 的 `File('assets/data/sf6_framedata.json')` 尝试同步读取离线数据。该逻辑在开发机执行单测时依赖本地物理文件系统可勉强运行，但在 Android APK 和 iOS IPA 打包后，Asset 文件已被打包为安装包内部的二进制只读资源，`File` 无法访问，导致真机运行时 `_cachedJsonMoves` 永远为空！
进而导致 18 个非隆角色（Luke, Terry, Bison, Marisa, JP, Manon, Ed, Rashid, Aki 等）在手机端进入时普通技全部为空列表（有的直接空着，有的空了拳脚帧数）。
本需求要求：
1. 彻底重构真机资产加载架构，通过 Flutter 原生 `rootBundle.loadString('assets/data/sf6_framedata.json')` 实现真机环境下 100% 可靠的异步数据预热与解析；
2. 在 `FrameDataDatabase` 中新增静态异步初始化方法 `init()`，并在 `main.dart` 启动时作为核心基础设施执行 `await FrameDataDatabase.init()`；
3. 保留并加固 `File` 同步读取作为“单元测试/开发机免引擎环境降级方案”，确保纯 Dart 单测与 CI 流水线依然能够免 Flutter 引擎顺利执行。

#### 2. 输入输出与数据契约
- **核心文件修改**:
  - `E:\SF6_Tracker\lib\data\frame_data_database.dart`
  - `E:\SF6_Tracker\lib\main.dart`
  - `E:\SF6_Tracker\lib\services\frame_data_service.dart`
- **类结构与接口契约 (`FrameDataDatabase`)**:
  ```dart
  class FrameDataDatabase {
    // 内存缓存字典，Key 统一为小写 trimmed 角色 ID
    static Map<String, List<FrameMove>>? _cachedJsonMoves;
    static bool _isInitialized = false;

    /// 核心异步初始化方法 (主启动流程与真机运行专用)
    /// 可选注入 AssetBundle 或自定义 jsonContent 便于模拟测试
    static Future<void> init({AssetBundle? bundle, String? jsonContent}) async {
      if (_isInitialized && _cachedJsonMoves != null) return;
      try {
        final content = jsonContent ??
            await (bundle ?? rootBundle).loadString('assets/data/sf6_framedata.json');
        _parseAndCacheJson(content);
        _isInitialized = true;
      } catch (e) {
        // 真机若发生异常，记录日志并尝试同步 File 降级
        _ensureJsonLoaded();
      }
    }

    /// 纯文本 JSON 解析并构筑类型安全对象缓存
    static void _parseAndCacheJson(String content) {
      final rawMap = json.decode(content) as Map<String, dynamic>;
      _cachedJsonMoves = rawMap.map((key, value) {
        final list = (value as List<dynamic>)
            .map((e) => FrameMove.fromJson(e as Map<String, dynamic>))
            .toList();
        return MapEntry(key.toLowerCase().trim(), list);
      });
    }

    /// 同步降级加载机制 (保持纯 Dart 单元测试环境向下兼容)
    static void _ensureJsonLoaded() {
      if (_cachedJsonMoves != null) return;
      try {
        final file = File('assets/data/sf6_framedata.json');
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          _parseAndCacheJson(content);
        }
      } catch (_) {}
    }

    /// 单元测试专用重置钩子
    @visibleForTesting
    static void resetCacheForTesting() {
      _cachedJsonMoves = null;
      _isInitialized = false;
    }
  }
  ```
- **启动时序注入 (`lib/main.dart`)**:
  ```dart
  void main() async {
    runZonedGuarded(() async {
      WidgetsFlutterBinding.ensureInitialized();

      await AppLogger.instance.init();
      // 在渲染启动前预热并解析离线帧数数据
      await FrameDataDatabase.init();

      // 其余原有错误拦截器与沉浸式 UI 配置保持不变
      runApp(const Sf6App());
    }, (Object error, StackTrace stack) {
      AppLogger.instance.error('ZoneError', '$error\n$stack');
    });
  }
  ```
- **数据查询路由契约 (`getCharacterMoves(String charId)`)**:
  - 对于未在 `switch` 中硬编码的 18 个非隆角色（`luke`, `terry`, `bison`, `marisa`, `jp`, `manon`, `ed`, `rashid`, `aki`, `jamie`, `kimberly`, `lily`, `dhalsim`, `blanka`, `ehonda`, `cammy`, `ken`, `juri` 等）：
    1. 进入 `getCharacterMoves(charId)`；
    2. 若 `_cachedJsonMoves` 为空，自动调用 `_ensureJsonLoaded()` 进行保底兜底；
    3. 从 `_cachedJsonMoves![id]` 中检索并返回其完整的招式列表（包含普通技、特殊技、必杀技及超必杀技）；
    4. 彻底杜绝返回空列表 `[]`。
  - 对于在 `switch` 中硬编码但普通技委托给 `_getNormalsFor(id)` 的角色：
    1. `_getNormalsFor(id)` 在进入 `default:` 时从 `_cachedJsonMoves![id]` 提取 `type == MoveType.normal` 的完整拳脚列表；
    2. 彻底杜绝拳脚帧数全空。

#### 3. 边界条件与异常处理
- **边界条件 1 (应用快速唤起与冷启动并发竞争)**:
  - 若 UI 在 `FrameDataDatabase.init()` 尚未完全返回的微秒内即调用了 `getCharacterMoves`，`getCharacterMoves` 内部第一行依然执行 `_ensureJsonLoaded()`，若此时仍在异步过程中，应保证返回只包含通用斗气技能的基础列表，并在数据就绪后通过 `FrameDataService` 刷新通知，绝不允许抛出空指针异常；
- **边界条件 2 (单元测试免 Flutter 引擎运行)**:
  - 纯 Dart 单元测试（不调用 `TestWidgetsFlutterBinding.ensureInitialized()`）无法访问 `rootBundle`。此时代码自动触发 `catch` 并进入 `_ensureJsonLoaded()`，通过 `File('assets/data/sf6_framedata.json')` 成功读取物理文件，确保既有 CI 单测 100% 保持通过；
- **边界条件 3 (JSON 格式错误或缺失字段防御)**:
  - 若 JSON 解析时某招式缺少非核心字段（如 `driveGaugeRecovery`），`FrameMove.fromJson` 必须具备默认值防御，防止个别招式解析异常导致整库瘫痪。

#### 4. 验收标准 (Given-When-Then)
- **Given** 应用已构建为 Release APK 并在 Android 真机上冷启动运行；
- **When** 用户进入【招式帧数表】，切换查看卢克 (Luke)、特瑞 (Terry)、维加 (Bison)、玛丽莎 (Marisa)、JP、曼侬 (Manon)、埃德 (Ed)、拉希德 (Rashid)、阿鬼 (Aki)；
- **Then** 所有 18 个角色的普通拳脚列表（5LP, 5MP, 5HP, 2MK 等）与完整必杀技表均完整呈现，无任何空白列表或“拳脚帧数全空”故障；
- **When** 在工程根目录下执行终端命令 `flutter test`；
- **Then** 全量单元测试无需真机 AssetBundle 环境即可通过 `File` 降级读取通过，0 个测试用例失败；
- **When** 真机从后台唤醒或重新进入工具箱；
- **Then** 招式列表展示为 0ms 瞬间渲染，无二次从磁盘重复解析导致的卡顿。

---

### REQ-DAT-004: 阿俊 (Arjun) 权威数据全面矫正与 Supercombo Wiki 对齐规范

#### 1. 需求描述
旧版本代码中，阿俊 (Arjun) 的普通技帧数存在臆想与草案数据（如 5MP 填为 6F、5HP 填为 10F、5LK 填为 5F 等），且核心必杀技与超必杀技存在指令与按键错误（呼吸之环误填 214K，实际为 236K；神柱误填 22P，实际为 214K；阴森审讯未定义未防御引爆灰血机制；SA1 误为 236236K，实际为 236236P；SA3 误为 236236P，实际为 236236K 等）。
必须彻底根据格斗游戏权威数据库 **Supercombo Wiki** 官方实测数据，全面纠偏阿俊全部 18 招普通技、6 招必杀技四版本真实变种及 3 招 SA 超必杀技，实现 `FrameDataDatabase`、`assets/data/sf6_framedata.json`、连招库 `sf6_combos.json` 以及媒体映射字典的高度一致与零误差。

#### 2. 输入输出与数据契约

##### A. 地面与跳跃普通技 (18 招权威数据清单)
在 `FrameDataDatabase._getNormalsFor('arjun')` 与 `assets/data/sf6_framedata.json` 中，严格对齐以下权威数值：

1. **站立轻拳 (5LP)**:
   - 发生: `4` | 持续: `3` | 硬直: `8` | 被防: `+1` | 命中: `+4` | 伤害: `300` | 可取消: `true` | 特性: 4F最速起手抢招，被防+1有利
2. **站立中拳 (5MP)**:
   - 发生: `11` | 持续: `4` | 硬直: `15` | 被防: `-2` | 命中: `+4` | 伤害: `700` | 可取消: `true` | 特性: 核心立回拳，发生11F，命中+4可目押连段
3. **站立重拳 (5HP)**:
   - 发生: `15` | 持续: `4` | 硬直: `18` | 被防: `-3` | 命中: `+2` | 伤害: `800` | 可取消: `true` | 特性: 带 TC 目标连段派生，确反大起手
4. **站立轻脚 (5LK)**:
   - 发生: `6` | 持续: `3` | 硬直: `12` | 被防: `-4` | 命中: `+1` | 伤害: `400` | 可取消: `true` | 特性: 快速推开近战距离
5. **站立中脚 (5MK)**:
   - 发生: `7` | 持续: `4` | 硬直: `14` | 被防: `-3` | 命中: `+2` | 伤害: `700` | 可取消: `false` | 特性: 带 TC 派生，中距离长腿立回截击
6. **站立重脚 (5HK)**:
   - 发生: `14` | 持续: `4` | 硬直: `18` | 被防: `-3` | 命中: `击倒(+43F)` | 伤害: `800` | 可取消: `false` | 特性: 强力破招击倒，被防仅-3极度安全
7. **蹲下轻拳 (2LP)**:
   - 发生: `5` | 持续: `3` | 硬直: `8` | 被防: `-1` | 命中: `+5` | 伤害: `300` | 可取消: `true` | 特性: 下盘快速插动抢招
8. **蹲下中拳 (2MP)**:
   - 发生: `9` | 持续: `3` | 硬直: `16` | 被防: `-4` | 命中: `击倒(+27F)` | 伤害: `700` | 可取消: `false` | 特性: **下段判定**，命中直接击倒对手
9. **蹲下重拳 (2HP)**:
   - 发生: `10` | 持续: `4` | 硬直: `24` | 被防: `-5` | 命中: `-1` | 伤害: `800` | 可取消: `true` | 特性: 核心防空重拳，对空强判定
10. **蹲下轻脚 (2LK)**:
    - 发生: `5` | 持续: `2` | 硬直: `10` | 被防: `-2` | 命中: `+2` | 伤害: `300` | 可取消: `false` | 特性: 最速下段起手插动
11. **蹲下中脚 (2MK)**:
    - 发生: `8` | 持续: `3` | 硬直: `17` | 被防: `-2` | 命中: `+5` | 伤害: `600` | 可取消: `true` | 特性: **核心下段摸奖神技**，被防仅 -2F 极度安全，可取消绿冲或必杀
12. **蹲下重脚 (2HK)**:
    - 发生: `10` | 持续: `3` | 硬直: `24` | 被防: `-12` | 命中: `击倒` | 伤害: `900` | 可取消: `false` | 特性: 扫堂腿击倒，被防大负帧确反
13. **跳跃轻拳 (j.LP)**: 发生: `4` | 伤害: `300` | 空中最速抢招
14. **跳跃轻脚 (j.LK)**: 发生: `5` | 伤害: `320` | 逆向打背脚
15. **跳跃中拳 (j.MP)**: 发生: `7` | 伤害: `700` | 空对空截杀
16. **跳跃中脚 (j.MK)**: 发生: `7` | 伤害: `600` | 逆向跳入压制
17. **跳跃重拳 (j.HP)**: 发生: `9` | 伤害: `800` | 高伤下砸重拳
18. **跳跃重脚 (j.HK)**: 发生: `9` | 伤害: `800` | 斜下长距离重脚

##### B. 核心必杀技指令纠正与四版本真实变种清单

1. **正义之臂 (Arm of Justice)**: 指令 `236P`
   - `L (轻)`: 发生 `14` | 持续 `3` | 硬直 `18` | 被防 `-6` | 命中 `+2` | 伤害 `700`
   - `M (中)`: 发生 `17` | 持续 `3` | 硬直 `18` | 被防 `-4` | 命中 `+3` | 伤害 `800`
   - `H (重)`: 发生 `20` | 持续 `3` | 硬直 `19` | 被防 `-2` | 命中 `击倒` | 伤害 `900`
   - `OD (强化)`: 发生 `14` | 持续 `4` | 硬直 `16` | 被防 `+2` | 命中 `大弹墙` | 伤害 `1200` (消耗2气，弹墙连段起手)

2. **狂暴之肩 (Cruel Shoulder)**: 指令 `623P`
   - `L (轻)`: 发生 `6` | 持续 `4` | 硬直 `34` | 被防 `-24` | 命中 `击倒` | 伤害 `1100` | 无敌: `1-8F 对空无敌`
   - `M (中)`: 发生 `7` | 持续 `4` | 硬直 `36` | 被防 `-28` | 命中 `击倒` | 伤害 `1250` | 无敌: `1-9F 对空无敌`
   - `H (重)`: 发生 `8` | 持续 `5` | 硬直 `38` | 被防 `-32` | 命中 `击倒` | 伤害 `1350` | 无敌: `1-10F 对空完全无敌`
   - `OD (强化)`: 发生 `6` | 持续 `6` | 硬直 `40` | 被防 `-36` | 命中 `击倒` | 伤害 `1450` | 无敌: `1-8F 完全无敌 (核心凹招)`

3. **呼吸之环 (Breathing Ring)**: **指令纠正为 `236K`** (原 214K 纠正)
   - `L (轻)`: 发生 `15` | 持续 `3` | 硬直 `20` | 被防 `-4` | 命中 `+1` | 伤害 `600` | 制造灰血冲击波
   - `M (中)`: 发生 `18` | 持续 `3` | 硬直 `20` | 被防 `-2` | 命中 `击倒` | 伤害 `750`
   - `H (重)`: 发生 `22` | 持续 `4` | 硬直 `18` | 被防 `+1` | 命中 `击倒` | 伤害 `900` | 压制有利波
   - `OD (强化)`: 发生 `16` | 持续 `4` | 硬直 `18` | 被防 `+3` | 命中 `崩防浮空` | 伤害 `1050` | 消耗2气，压制有利

4. **神柱 (Divine Pillar)**: **指令纠正为 `214K`** (原 22P 纠正)
   - `L (轻)`: 发生 `26` | 持续 `4` | 硬直 `22` | 被防 `+1` | 命中 `击倒` | 伤害 `600` | 近距离光柱压制
   - `M (中)`: 发生 `29` | 持续 `4` | 硬直 `22` | 被防 `+2` | 命中 `击倒` | 伤害 `600` | 中距离召唤
   - `H (重)`: 发生 `32` | 持续 `4` | 硬直 `22` | 被防 `+3` | 命中 `击倒` | 伤害 `600` | 远距离防空
   - `OD (强化)`: 发生 `24` | 持续 `6` | 硬直 `20` | 被防 `+4` | 命中 `大浮空` | 伤害 `900` | 双重光柱夹击

5. **阴森审讯 (Ghastly Interrogation)**: 指令 `63214K` (**近身未防御指令投，引爆灰血**)
   - `L (轻)`: 发生 `8` | 持续 `2` | 硬直 `40` | 被防 `不可防` | 命中 `倒地` | 伤害 `1800` | 抓取距离极长
   - `M (中)`: 发生 `7` | 持续 `2` | 硬直 `40` | 被防 `不可防` | 命中 `倒地` | 伤害 `2000` | 中距离指令投
   - `H (重)`: 发生 `5` | 持续 `2` | 硬直 `40` | 被防 `不可防` | 命中 `倒地` | 伤害 `2200` | 发生最快 5F
   - `OD (强化)`: 发生 `5` | 持续 `2` | 硬直 `40` | 被防 `不可防` | 命中 `大暴击` | 伤害 `2500` | 消耗2气超高爆发指令投

6. **不屈防壁 (Indomitable Defense)**: 指令 `214P`
   - `L/M/H`: 发生 `1` | 持续 `18` | 硬直 `15` | 被防 `架招` | 命中 `反击` | 伤害 `900`
   - `OD (强化)`: 发生 `1` | 持续 `24` | 硬直 `15` | 被防 `强化架招` | 命中 `大崩防` | 伤害 `1200`

##### C. 超必杀技 (Super Arts) 权威定义与指令纠正
1. **SA1: 咆哮毁灭 (Roaring Ruin)**: **指令纠正为 `236236P`** (原 236236K 纠正)
   - 发生: `8` | 持续: `6` | 硬直: `40` | 被防: `-18` | 命中: `击倒` | 伤害: `2000` | 特性: 1-8F 对空完全无敌
2. **SA2: 瞬间遗忘 (Instant Oblivion)**: 指令 `214214P`
   - 发生: `9` | 持续: `8` | 硬直: `44` | 被防: `-16` | 命中: `大破防` | 伤害: `3000` | 特性: 灰血引爆超杀
3. **SA3: 夜叉之令 (Order of the Yaksha)**: **指令纠正为 `236236K`** (原 236236P 纠正)
   - 发生: `13` | 持续: `8` | 硬直: `48` | 被防: `-26` | 命中: `夜叉终结` | 伤害: `4000 (残血 CA 4500)` | 特性: 完全无敌终结技

##### D. 连招库与媒体路由协同纠偏契约
1. `assets/data/sf6_combos.json`:
   - `arjun_1`: `PC 5HP > 4HP > 236PP, 623HP > 236236K (SA3)` (纠正 SA3 指令为 236236K)；
   - `arjun_3`: `CH 5MP, 2MP > 236MK` (纠正呼吸之环指令为 236MK)；
   - `arjun_5`: `PC Drive Impact, 6HP, 214KK, 623HP` (纠正 OD 神柱指令为 214KK)；
   - `arjun_6`: `Wall Splat, 5HK, 236HP > 236236P (SA1)` (纠正 SA1 指令为 236236P)；
2. `lib/utils/sf6_move_media_helper.dart`:
   - 必杀技动图匹配规则支持新指令别名：呼吸之环 (`236K` / `214K`)、神柱 (`214K` / `22P`)、SA1 (`236236P` / `236236K`)、SA3 (`236236K` / `236236P`)，保证动图寻址向前兼容。

#### 3. 边界条件与异常处理
- **双端严格一致性**:
  - `FrameDataDatabase` 内存代码与 `assets/data/sf6_framedata.json` 对应条目的 `startup`、`onBlock`、`onHit`、`damage`、`command` 字段必须逐字符校验一致，杜绝内存与 JSON 产生分歧；
- **派生与TC判定容错**:
  - 5HP 与 5MK 必须在 `notes` 中明确注明可派生 TC 目标连段，帮助玩家准确把握立回取消时机。

#### 4. 验收标准 (Given-When-Then)
- **Given** 用户打开阿俊的招式帧数表；
- **When** 检查 5MP 与 5HP 数据；
- **Then** 5MP 发生显示为 11F，被防 -2F，伤害 700；5HP 发生显示为 15F，被防 -3F，伤害 800；
- **When** 检查 2MK 数据；
- **Then** 发生显示为 8F，被防显示为 -2F，命中显示为 +5F，伤害 600；
- **When** 检查呼吸之环与神柱的招式指令；
- **Then** 呼吸之环指令确切为 `236K`，神柱指令确切为 `214K`；
- **When** 检查超必杀技列表；
- **Then** SA1 发生为 8F 指令为 `236236P`，SA2 发生为 9F 指令为 `214214P`，SA3 发生为 13F 指令为 `236236K`；
- **When** 在实用连招板块查看阿俊连招；
- **Then** 所有连招指令与帧数表新指令完全对应，无旧指令残留冲突。

---

### REQ-VER-001: 应用版本号与构建编号统一升级至 1.2.7.1 (build 2701)

#### 1. 需求描述
鉴于本次修复解决了真机 AssetBundle 数据大面积空缺的阻断性缺陷，补齐了阿俊立绘图标资产并完成了 Supercombo Wiki 官方权威帧数全量纠偏，依据语义化版本与工程发布规范，应用版本号必须从小版本 `1.2.7.0 (build 2700)` 升阶至 `1.2.7.1 (build 2701)`。

#### 2. 输入输出与数据契约
- **目标变更文件与字段定义**:
  1. `E:\SF6_Tracker\pubspec.yaml`:
     - 原值: `version: 1.2.7+2700`
     - 目标值: `version: 1.2.7+2701`
  2. `E:\SF6_Tracker\lib\core\utils\app_logger.dart`:
     - 原值: `static const String currentAppVersion = 'v1.2.7.0';`
     - 目标值: `static const String currentAppVersion = 'v1.2.7.1';`
     - 原值: `static const String currentBuildNumber = '2700';`
     - 目标值: `static const String currentBuildNumber = '2701';`

#### 3. 边界条件与异常处理
- **诊断系统与关于页联动**:
  - `AppLogger.instance.buildConciseDiagnosticSummary()` 输出的诊断头部必须展示 `v1.2.7.1 (build 2701)`；
  - 设置页面及关于页读取的应用版本展示字符串必须一致；
- **CI/CD 流水线构建标签兼容**:
  - GitHub Actions 云端构建流水线与 iOS IPA 打包脚本将读取此版本号生成产物文件包名（如 `SF6_Assistant_v1.2.7.1_build2701_unsigned.ipa`）。

#### 4. 验收标准 (Given-When-Then)
- **Given** 应用版本元数据已更新；
- **When** 查看 `pubspec.yaml` 与 `app_logger.dart`；
- **Then** `pubspec.yaml` 中 `version` 精确为 `1.2.7+2701`；
- **Then** `AppLogger.currentAppVersion` 精确为 `'v1.2.7.1'`，`AppLogger.currentBuildNumber` 精确为 `'2701'`；
- **When** 导出应用诊断报告；
- **Then** 报告第一行准确反映当前版本为 `v1.2.7.1 (build 2701)`。

---

## 4. 前序基础功能规格固化与继承 (Base Functional Specifications)

为确保系统规格全景图的严密性与向前兼容性，此前已验收并投入生产的核心规格在此继续生效：

1. **REQ-ARJ-001 ~ REQ-ARJ-005: 阿俊 (Arjun) 角色全生态基础规格**
   - 全局常量注册（ID `arjun`、Capcom ID 35、shortCode `ARJ`）；
   - 权威机体立回属性录入（HP 10500、前冲 20F/1.280、绿冲最大滑行 3.450 等）；
   - 6 大中文标准起手实用连招库（确反康、普通命中、打断康、绿冲起手、斗气迸发、版边崩防）；
   - 对战心得笔记与媒体动图 Slug 路由。
2. **REQ-AUD-001 & REQ-AUD-002: 数据库去伪存真与全角色机体属性清查**
   - 彻底清除 `_getNormalsFor` 克隆隆数据的严重结构缺陷，全角色普通技 100% 独立权威对齐；
   - 彻底清理泛型假数据 fallback，补齐全 32 位官方格斗家权威机体立回属性。
3. **REQ-IPA-001 ~ REQ-IPA-003, REQ-DOC-001: iOS 未签名 IPA 方案全套基础设施**
   - GitHub Actions 云端 macOS 自动化无代码签名 Release 流水线；
   - `ios/Runner/Info.plist` 原生合规配置（中文名“街霸6助手”、相册权限、ATS 放行、120Hz 高刷）；
   - 本地跨平台打包辅助脚本（`package_unsigned_ipa.sh` / `.ps1`）；
   - 用户端保姆级免越狱侧载手册（TrollStore 直装、Sideloadly 7天自签、开发者模式、数据保留续签与 FAQ）。
4. **REQ-DAT-003: 必杀技轻/中/重/OD四版本真实数据模型与变种表**
   - 彻底推翻 `+2/+4` 伪造算法，基于 `MoveVariation` 模型录入官方真实轻中重 OD 数据，弹窗真实渲染。
5. **REQ-CHT-003 & REQ-CHT-004: 排位折线图纯中文标题、二级展开菜单与段位色彩刻度**
   - 标题纯中文“排位分数走势”，去除冗余英文与括号；
   - 维度切换改右上角二级展开菜单（`PopupMenuButton`），折叠展示 `[近20场 ▾]`；
   - Y 轴刻度基于 `Sf6Rank.fromLpOrMr` 动态渲染官方段位色彩；
   - 监听主玩角色变动即时同步；空排位记录安全切换并友好兜底提示“暂无排位赛记录”。
6. **REQ-HOM-001: 首页 7 大核心卡片显隐与拖拽排序自定义**
   - 涵盖 `hero`, `score_chart`, `ladder`, `recent_form`, `play_time`, `quick_stats`, `radar`；
   - 设置页增设「首页卡片管理」入口，支持 `ReorderableListView` 拖拽排序与 `Switch` 显隐，支持一键恢复默认；
   - 通过 `StorageService` 永久持久化保存配置，首页按自定义配置动态消费渲染。
7. **REQ-RPL-001 & REQ-TOL-001: 对战录像代码复制与工具默认角色自适应**
   - 录像代码一键复制与 CFN 5 步检索观看指引；
   - 工具箱默认角色自适应绑定当前主玩角色（`activePlatform.mainCharId` -> `userProfile.mainCharacterId` -> `'ryu'`）。
8. **REQ-GIF-004: 碰撞框动图本地应用沙盒磁盘持久化缓存架构**
   - 基于 `path_provider` 实现沙盒磁盘永久缓存，0ms 秒开，可统计可清理。

---

## 5. 非功能性需求与性能指标 (Non-Functional Requirements & Performance Budgets)

### 5.1 启动性能与内存预算
1. **真机数据初始化时延**:
   - `FrameDataDatabase.init()` 读取与解析 `assets/data/sf6_framedata.json` 在主流真机芯片（骁龙 8+ / A15 及以上）上的冷启动耗时强制 $\le 80\text{ms}$，在低端测试机上 $\le 150\text{ms}$，严禁阻塞应用首屏启动超过 $200\text{ms}$；
2. **常驻内存与图片缓存**:
   - 全 32 位角色头像及帧数数据完全常驻内存时，内存增加量强制 $\le 8\text{MB}$；
   - 图片解码缓存平滑回收，避免在 32 位格斗家密集切换时发生 OOM。

### 5.2 兼容性与自动化流水线指标
1. **单测降级兼容率**:
   - 纯 Dart 单元测试在无 Flutter 渲染引擎介入的前提下，通过 `_ensureJsonLoaded()` 的 `File` 读取降级成功率必须达到 $100\%$；
2. **数据完整性审计**:
   - 全 32 位官方收录格斗家在 `FrameDataDatabase.getCharacterMoves()` 下招式总数均 $> 30$ 招，普通技数量均 $\ge 18$ 招，不存在任何空列表或字段 null 异常。

---

## 6. 人工审核门禁与签署挂起清单 (Human Approval Gate & Sign-off)

> [!IMPORTANT]
> **软件规格分析师严格声明**：
> 本规格说明书（`specs/spec.md`）已针对用户的严重反馈完成深度需求拆解与架构规格定义：
> 1. **REQ-ICO-001**: 补齐阿俊专属角色立绘图标（`arjun.png`），解决 UI 头像及选择器 404 破图缺陷；
> 2. **REQ-ASSET-001**: 重构真机资产加载机制，使用 `rootBundle.loadString` + `FrameDataDatabase.init()` 预热离线数据，保留 `File` 单测降级，彻底根治 18 角色真机普通技与招式全空故障；
> 3. **REQ-DAT-004**: 严格对齐 Supercombo Wiki 权威数据，纠偏阿俊全部 18 招普通技、6 招必杀技（呼吸之环 236K、神柱 214K、未防御灰血投等）及 3 招 SA (SA1 236236P, SA2 214214P, SA3 236236K)；
> 4. **REQ-VER-001**: 统一升级应用版本元数据至 `1.2.7.1 (build 2701)`。
>
> 遵循岗位职责约束，**本人严禁编写任何业务实现代码或单元测试代码。**
> 本规格说明书现已固化并处于**挂起等待人工审核状态 (PENDING_HUMAN_APPROVAL)**。

### 审核检查清单 (Audit Checklist)
- [ ] **REQ-ICO-001**: 阿俊头像图标 `assets/images/characters/arjun.png` 规格与全 UI 组件接入契约是否清晰完备？
- [ ] **REQ-ASSET-001**: 真机通过 `rootBundle.loadString` + `FrameDataDatabase.init()` 加载以及单元测试通过 `File` 降级加载的双轨架构是否可行并能彻底解决 18 角色数据空缺？
- [ ] **REQ-DAT-004**: 阿俊 18 招普通技、必杀技指令纠正（呼吸之环 236K、神柱 214K、未防御指令投）与超必杀技指令（SA1 236236P、SA3 236236K）是否已严格对齐 Supercombo Wiki 权威实机数据？
- [ ] **REQ-VER-001**: 目标版本 `1.2.7.1 (build 2701)` 与 `pubspec.yaml` `1.2.7+2701` 是否一致？

---
*规格说明书编制完成，流水线挂起等待人工审核批准。*

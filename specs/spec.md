# 街霸6助手 (SF6 Assistant) 软件规格说明书 (SRS)

- **文档标识**: SF6-SPEC-v1.2.7.0
- **目标版本**: `v1.2.7.0` (build `2700`)
- **前序版本**: `v1.2.6.5` (build `2605`)
- **分析师角色**: 严苛的软件规格分析师 (Strict Software Specification Analyst)
- **文档状态**: 待人工审核挂起 (PENDING_HUMAN_APPROVAL)
- **生成时间**: 2026-10-17
- **密级与范畴**: 新角色阿俊全模块同步上线、数据库去伪存真清查、独立普通技与立回属性权威补齐、版本大跨越演进

---

## 1. 背景与目标定义 (Background & Objectives)

### 1.1 问题背景与核心痛点
1. **游戏最新版本参战角色“阿俊 (Arjun)”全生态空缺**：
   - 卡普空官方在《街头霸王 6》最新赛季中正式上线了全新格斗家——**阿俊 (Arjun)**（徒手瑜伽 / 灰血压制型格斗家）；
   - 当前 App 尚未在全局常量（`characters.dart`）、立回机体属性库（`character_stats_database.dart`）、帧数数据库（`frame_data_database.dart` / `sf6_framedata.json`）、实用连招库（`sf6_combos.json`）、对策复盘笔记（`notes_service.dart`）以及媒体动图路由（`sf6_move_media_helper.dart`）中收录阿俊，导致玩家无法在工具箱任何板块查阅或绑定该角色。
2. **工具页面数据库严重伪造失真与回退假数据弊病 (Data Contamination & Fake Fallbacks)**：
   - **普通技克隆假数据**：清查发现 `FrameDataDatabase._getNormalsFor(id)` 中，存在严重的偷懒回退机制——除少数几个单独写死 case 的角色外，其余所有角色在 `default:` 分支中全部默认返回了“隆 (Ryu)”的 18 招普通技！导致大量角色的普通技发生帧、被防差与取消判定被恶意篡改成隆的数据；
   - **机体属性库大面积空缺**：`CharacterStatsDatabase` 仅收录了 11 个旧角色，其余 20+ 个角色（如埃德、特瑞、不知火舞、阿鬼、曼侬、拉希德等）全部进入 `getStats()` 的泛型 fallback 默认假数据（血量全填 10000、走速冲刺全填隆的数值），完全丧失了立回分析的参考价值。
3. **版本大跨越里程碑**：
   - 由于本次引入了重大全新角色生态并对全量底层数据进行了深度去伪存真治理，依据项目规范，版本号由 `v1.2.6.x` 系列正式跨越升阶至里程碑大版本 `v1.2.7.0 (build 2700)`。

### 1.2 改造目标
- **全模块上线阿俊 (Arjun)**：完成角色常量注册（第 32 位官方角色）、立回机体属性录入（HP 10500 等）、权威帧数表与必杀技四版本真实变种构建、6 大中文标准起手实用连招库填充、对策笔记与媒体动图映射；
- **全数据库去伪存真清查治理**：
  - 彻底根治 `_getNormalsFor` 克隆伪造隆数据的严重结构缺陷，确保全量角色普通技 100% 具备权威独立的发生、被防差与取消判定；
  - 补齐全 32 位官方格斗家权威机体立回属性，彻底铲除泛型假数据；
- **版本元数据大版本升阶**：统一规范为 `1.2.7.0 (build 2700)`。

---

## 2. 架构影响与受影响模块矩阵 (Architecture Impact Matrix)

| 规格编号 (REQ ID) | 模块层级 | 受影响源文件路径 | 核心影响范围与交互组件 |
| :--- | :--- | :--- | :--- |
| **REQ-ARJ-001** | Core / Domain | `lib/core/constants/characters.dart` | 注册阿俊全局常量（ID `arjun`、Capcom ID 35、shortCode `ARJ`），全局官方格斗家扩充至 32 位 |
| **REQ-ARJ-002** | Data / Stats | `lib/data/character_stats_database.dart` | 录入阿俊权威机体立回属性（HP 10500、走速、前冲帧数距离、绿冲极值、跳跃数据等） |
| **REQ-ARJ-003** | Data / Frame | `lib/data/frame_data_database.dart`<br>`assets/data/sf6_framedata.json`<br>`lib/models/frame_data_model.dart` | 录入阿俊完整官方招式表（18招独立普通技、7招特殊技、2招普通投、6招必杀技四版本真实变种、3招SA） |
| **REQ-ARJ-004** | Asset / Combo | `assets/data/sf6_combos.json`<br>`lib/data/sf6_combos_database.dart` | 录入阿俊高保真实用连招库，严格覆盖 6 大中文标准起手类型（确反康/普通命中/斗气迸发/绿冲起手/版边崩防） |
| **REQ-ARJ-005** | Service / Media | `lib/services/notes_service.dart`<br>`lib/utils/sf6_move_media_helper.dart` | 录入阿俊实战对策复盘要点；配置阿俊媒体 slug 与招式动图文件名正向映射字典 |
| **REQ-AUD-001** | Data / Cleanse | `lib/data/frame_data_database.dart`<br>`assets/data/sf6_framedata.json` | 彻底清除 `_getNormalsFor` 克隆隆数据的伪造回退缺陷，全角色普通技 100% 真实独立动态加载与对齐 |
| **REQ-AUD-002** | Data / Cleanse | `lib/data/character_stats_database.dart` | 彻底清理泛型假数据 fallback，全量补齐 SF6 全部 32 位官方格斗家权威机体立回与体能数据 |
| **REQ-VER-001** | Build / Config | `pubspec.yaml`<br>`lib/core/utils/app_logger.dart` | 应用版本号大版本升级至 `1.2.7+2700`，日志器与诊断系统升级至 `v1.2.7.0` |
| **REQ-IPA-001** | CI/CD / Actions | `.github/workflows/build-ios.yml`<br>`.github/workflows/build-release.yml` | GitHub Actions 云端 macOS 自动化未签名 IPA 构建与双命名 Release 资产分发 (v1.2.6.5 继承) |
| **REQ-IPA-002** | iOS Native / Config | `ios/Runner/Info.plist` | CFBundleDisplayName（街霸6助手）、相册权限说明、网络 ATS 放行、120Hz 高刷配置 (v1.2.6.5 继承) |
| **REQ-IPA-003** | Automation / Script | `scripts/package_unsigned_ipa.sh`<br>`scripts/package_unsigned_ipa.ps1` | 本地跨平台一键无证书编译与 IPA 封包辅助脚本 (v1.2.6.5 继承) |
| **REQ-DOC-001** | Documentation | `README.md`<br>`WIKI.md` | 用户端 iOS 免越狱侧载手册（TrollStore 直装、Sideloadly 7天自签、开发者模式、数据保留续签与 FAQ） (v1.2.6.5 继承) |
| **REQ-DAT-003** | Model / Data / UI | `lib/models/frame_data_model.dart`<br>`lib/ui/widgets/move_detail_modal.dart` | 必杀技轻/中/重/OD四版本独立真实数据模型构建与变种表真实渲染 (v1.2.6.4 继承) |
| **REQ-CHT-003** | UI / Chart | `lib/ui/widgets/ranked_score_chart_card.dart` | 排位折线图标题纯中文化、维度切换二级展开菜单（PopupMenuButton）、Y轴刻度段位色彩动态渲染 (v1.2.6.4 继承) |
| **REQ-CHT-004** | UI / Service | `lib/ui/widgets/ranked_score_chart_card.dart` | 主玩角色切换即时感知、空排位战绩安全展示与友好占位兜底 (v1.2.6.4 继承) |
| **REQ-HOM-001** | UI / Storage | `lib/models/home_card_config.dart`<br>`lib/ui/screens/home/home_screen.dart`<br>`lib/ui/screens/settings/settings_screen.dart` | 首页 7 大核心卡片显隐与拖拽排序自定义引擎 (v1.2.6.4 继承) |
| **REQ-RPL-001** | UI / System | `lib/ui/screens/battle_log/match_history_screen.dart` | 战绩卡片 Replay Code 复制徽章与游戏内检索 5 步使用指引 (v1.2.6.3 继承) |
| **REQ-TOL-001** | Service / UI | `lib/services/frame_data_service.dart` | 工具箱默认角色与当前主玩角色自适应深度绑定 (v1.2.6.3 继承) |
| **REQ-DAT-002** | Data / Domain | `lib/data/frame_data_database.dart` | 帧数数据库非官方假角色物理清洗、全角色独立真实 18 招普通技对齐 (v1.2.6.3 继承) |
| **REQ-GIF-004** | Core / Cache | `lib/utils/sf6_move_media_helper.dart` | 碰撞框动图本地应用沙盒磁盘持久化缓存、0ms 秒开与 APK 体积工程权衡 (v1.2.6.3 继承) |

---

## 3. 功能需求规格逐项拆解 (Detailed Functional Specifications)

---

### REQ-ARJ-001: 新角色阿俊 (Arjun) 常量注册与全局元数据规范
- **需求描述**:
  在 `lib/core/constants/characters.dart` 中正式注册新角色阿俊（Arjun），确立其作为街霸6第 32 位官方登场格斗家的核心元数据契约，打通全局根据 ID、中文名、英文名、简称及 Capcom 官方数字 ID 的检索管道。
- **输入输出与字段契约**:
  - **角色常量实体 (`Sf6Character`)**:
    ```dart
    Sf6Character(
      id: 'arjun',
      nameEn: 'Arjun',
      nameZh: '阿俊',
      shortCode: 'ARJ',
      avatarUrl: 'https://www.streetfighter.com/6/buckler/assets/character/arjun/icon.png',
      archetype: '徒手瑜伽 / 灰血压制型',
    )
    ```
  - **检索与映射支持**:
    1. `Sf6Characters.all`: 列表总长度由 31 位扩增至 32 位（包含阿俊，末尾保留 1 个随机格斗家占位）；
    2. `Sf6Characters.getById`:
       - 支持入参 `'arjun'`、`'ARJUN'`、`'Arjun'`；
       - 支持入参中文名 `'阿俊'`；
       - 支持入参简称 `'ARJ'`；
    3. `Sf6Characters.fromCapcomId`:
       - 卡普空官方数字 ID 映射：`35: 'arjun'`。
- **边界条件与异常处理**:
  - 大小写不敏感：输入带前后空格或小写的 `' arjun '` 必须精确解析；
  - 兜底保底：若输入未知 ID，严禁返回 null，必须安全回退至标准格式对象。
- **验收标准 (Given-When-Then)**:
  - **Given** 调用 `Sf6Characters.getById('阿俊')` 或 `Sf6Characters.fromCapcomId(35)`；
  - **When** 检查返回结果；
  - **Then** 返回对象的 `id` 确切为 `'arjun'`，`nameZh` 为 `'阿俊'`，`archetype` 包含“徒手瑜伽”；
  - **Then** `Sf6Characters.all.length` 判定值准确反映 32 位官方收录格斗家。

---

### REQ-ARJ-002: 阿俊权威机体立回与属性数据库录入规范
- **需求描述**:
  在 `lib/data/character_stats_database.dart` 中录入阿俊的官方权威体能、立回与运动学参数，杜绝走泛型假数据 fallback。
- **输入输出与属性契约**:
  - **数据条目 (`_data['arjun']`)**:
    ```dart
    'arjun': CharacterStats(
      characterId: 'arjun',
      nameZh: '阿俊',
      nameEn: 'ARJUN',
      quote: '以苦修磨砺肉身与灵魂，在不可侵犯的正义之柱前，诸恶皆当退散。',
      difficulty: '进阶',
      archetype: '徒手瑜伽 / 灰血压制型',
      lifePoints: 10500,              // 拥有高体魄生命值
      throwRange: 0.820,              // 普投判定距离
      throwHurtbox: 0.330,            // 被投受创框
      forwardWalkSpeed: 0.046,        // 前前行速度
      backwardWalkSpeed: 0.031,       // 后后行速度
      forwardDashSpeed: 20,           // 前冲总帧数 (20F)
      backwardDashSpeed: 24,          // 后冲总帧数 (24F)
      forwardDashDistance: 1.280,     // 前冲距离
      backwardDashDistance: 0.900,    // 后冲距离
      driveRushMinThrow: 0.650,       // 绿冲最小投距离
      driveRushMinBlock: 1.950,       // 绿冲最小被防距离
      driveRushMax: 3.450,            // 绿冲最大滑行极限
      jumpSpeed: '4+38+3',            // 起跳4F + 滞空38F + 着地3F (总45F)
      jumpApex: 2.100,                // 起跳最高点
      hitboxCount: 68,                // 招式碰撞框总数
    )
    ```
- **边界条件与异常处理**:
  - 调用 `CharacterStatsDatabase.getStats('arjun')` 必须命中真实 Map，禁止走通用 fallback 兜底。
- **验收标准 (Given-When-Then)**:
  - **Given** 在【工具 -> 基础属性】中选中阿俊；
  - **When** 检查属性面板；
  - **Then** 生命值确切显示为 10500，前冲为 20F/1.280，引用语录与定位清晰呈现。

---

### REQ-ARJ-003: 阿俊权威帧数库与必杀技四版本真实变种规范
- **需求描述**:
  在 `lib/data/frame_data_database.dart` 与 `assets/data/sf6_framedata.json` 中录入阿俊完整的官方招式表，严谨对齐 Supercombo Wiki 与卡普空官方权威数据。必须提供阿俊专属的 18 招独立普通技、7 招特殊技、2 招普通投、6 招核心必杀技（各带 L/M/H/OD 独立四版本真实变种）以及 3 招 SA 超必杀技。
- **输入输出与招式明细契约**:
  1. **独立普通技 (18 招独立数据)**:
     - `5LP`: 发生 4F | 持续 3F | 硬直 8F | 被防 +1F | 命中 +5F | 伤害 300 | `isCancelable: true`
     - `2LP`: 发生 4F | 持续 3F | 硬直 8F | 被防 -1F | 命中 +4F | 伤害 300 | `isCancelable: true`
     - `5LK`: 发生 5F | 持续 3F | 硬直 10F | 被防 -2F | 命中 +3F | 伤害 320 | `isCancelable: true`
     - `2LK`: 发生 5F | 持续 2F | 硬直 10F | 被防 -3F | 命中 +2F | 伤害 250 | `isCancelable: false` (下段)
     - `5MP`: 发生 6F | 持续 3F | 硬直 13F | 被防 +1F | 命中 +6F | 伤害 600 | `isCancelable: true` (核心立回)
     - `2MP`: 发生 7F | 持续 3F | 硬直 14F | 被防 -1F | 命中 +4F | 伤害 550 | `isCancelable: true`
     - `5MK`: 发生 8F | 持续 4F | 硬直 16F | 被防 -3F | 命中 +3F | 伤害 650 | `isCancelable: false` (长距离截击)
     - `2MK`: 发生 8F | 持续 3F | 硬直 18F | 被防 -5F | 命中 +1F | 伤害 500 | `isCancelable: true` (下段摸奖核心)
     - `5HP`: 发生 10F | 持续 4F | 硬直 19F | 被防 -3F | 命中 +4F | 伤害 850 | `isCancelable: true` (重确反)
     - `2HP`: 发生 9F | 持续 4F | 硬直 23F | 被防 -11F | 命中 +2F | 伤害 850 | `isCancelable: true` (对空重拳)
     - `5HK`: 发生 11F | 持续 4F | 硬直 19F | 被防 -4F | 命中 +3F | 伤害 900 | `isCancelable: false` (破招崩防)
     - `2HK`: 发生 10F | 持续 3F | 硬直 25F | 被防 -12F | 命中 击倒 | 伤害 900 | `isCancelable: false` (扫堂腿)
     - 空中技: `j.LP`(4F), `j.LK`(5F打背), `j.MP`(7F空对空), `j.MK`(7F逆向), `j.HP`(9F高伤压制), `j.HK`(9F长踢)。
  2. **特殊技 (Unique Moves - 7 招)**:
     - `责任之刃 (Blade of Duty)`: `6MP`，发生 20F，被防 -1F，命中 +3F，中段开罐破蹲防；
     - `凌驾法律 (Above the Law)`: `6HP`，发生 18F，被防 -2F，命中 +4F，大威力前踏冲拳；
     - `施加秩序 (Impose Order)`: `4HP`，发生 16F，被防 +1F，命中 +7F，二连掌核心打拆连段技；
     - `无法无天 (Loose Cannon)`: `6HK`，发生 17F，被防 -4F，命中 +4F，长距离跨步下劈重踢；
     - `镇压 (Suppression)`: `4HK`，发生 14F，被防 -4F，命中 +3F，强力对空与浮空截击踢；
     - `穷追不舍 (Hot Pursuit)`: `3HK`，发生 13F，被防 -6F，命中 +2F，滑步下段偷袭；
     - `忏悔拳 (Penitent Fist)`: `3HP`，发生 15F，被防 -3F，命中 +4F，中距离插动重拳。
  3. **普通投 (Throws - 2 招)**:
     - `正义判决 (Righteous Verdict)`: `LP+LK`，发生 5F，伤害 1200，被防不可防御，命中倒地+24F；
     - `审判天平 (Scale of the Judged)`: `4LP+LK`，发生 5F，伤害 1200，被防不可防御，命中换边倒地+40F。
  4. **必杀技四版本真实变种 (Special Moves & Variations - 6 招)**:
     - `正义之臂 (Arm of Justice)`: `236P`
       - `L`: 发生 14F | 被防 -6F | 命中 +2F | 伤害 700 (快速直冲掌)
       - `M`: 发生 17F | 被防 -4F | 命中 +3F | 伤害 800 (中距离突进)
       - `H`: 发生 20F | 被防 -2F | 命中 击倒 | 伤害 900 (重型推移)
       - `OD`: 发生 14F | **被防 +2F** | 命中 大弹墙 | 伤害 1200 (消耗2气，弹墙连段起手)
     - `狂暴之肩 (Cruel Shoulder)`: `623P`
       - `L`: 发生 6F | 被防 -24F | 伤害 1100 (1-8F 对空无敌)
       - `M`: 发生 7F | 被防 -28F | 伤害 1250 (1-9F 对空无敌)
       - `H`: 发生 8F | 被防 -32F | 伤害 1350 (1-10F 对空完全无敌)
       - `OD`: 发生 6F | 被防 -36F | 伤害 1450 | **1-8F 完全无敌 (核心凹招，命中触发神柱共鸣)**
     - `呼吸之环 (Breathing Ring)`: `214K`
       - `L`: 发生 15F | 被防 -4F | 命中 +1F | 伤害 600 (制造灰血冲击波)
       - `M`: 发生 18F | 被防 -2F | 命中 击倒 | 伤害 750
       - `H`: 发生 22F | 被防 +1F | 命中 击倒 | 伤害 900 (压制有利波)
       - `OD`: 发生 16F | 被防 +3F | 命中 崩防浮空 | 伤害 1050 (消耗2气)
     - `神柱 (Divine Pillar)`: `22P`
       - `L`: 发生 26F | 被防 +1F | 伤害 600 (近距离光柱压制)
       - `M`: 发生 29F | 被防 +2F | 伤害 600 (中距离召唤)
       - `H`: 发生 32F | 被防 +3F | 伤害 600 (远距离防空)
       - `OD`: 发生 24F | 被防 +4F | 伤害 900 (双重能量光柱夹击)
     - `阴森审讯 (Ghastly Interrogation)`: `63214K` (近身指令投)
       - `L`: 发生 8F | 被防 不可防 | 伤害 1800 (抓取距离极长)
       - `M`: 发生 7F | 被防 不可防 | 伤害 2000
       - `H`: 发生 5F | 被防 不可防 | 伤害 2200 (发生最快，抓取距离较短)
       - `OD`: 发生 5F | 被防 不可防 | 伤害 2500 (消耗2气，超高爆发指令投)
     - `不屈防壁 (Indomitable Defense)`: `214P` (格挡架势)
       - `L/M/H`: 发生 1F | 持续 18F | 成功架招后自动派生 `Moral Breakdown` 破防反击 (伤害 900)
       - `OD`: 发生 1F | 持续 24F | 强化架招，吸收一切上中下段与飞行道具，反击造成大崩防。
  5. **SA 超必杀技 (Super Arts - 3 招)**:
     - `SA1: 咆哮毁灭 (Roaring Ruin)`: `236236K`，发生 9F，被防 -18F，伤害 2000，完全无敌对空冲击；
     - `SA2: 瞬间遗忘 (Instant Oblivion)`: `214214P`，发生 11F，被防 -16F，伤害 3000，灰血引爆超杀；
     - `SA3: 夜叉之令 (Order of the Yaksha)`: `236236P`，发生 7F，被防 -26F，伤害 4000 (残血 CA 爆发 4500)，完全无敌终结技。
- **边界条件与异常处理**:
  - `move_detail_modal.dart` 在打开阿俊各必杀技时，变种表严密读取真实录入的 variations，禁止触发 `+2/+4` 伪造算法。
- **验收标准 (Given-When-Then)**:
  - **Given** 用户在招式表或帧数表中查阅阿俊；
  - **When** 展开全部招式；
  - **Then** 包含完整的 18 招普通技、7 招特殊技、2 招投技、6 招必杀技及 3 招超必杀技；
  - **When** 查看“狂暴之肩 (Cruel Shoulder)”详情；
  - **Then** 变种表格真实呈现 L(6F)、M(7F)、H(8F)、OD(6F/1-8F完全无敌被防-36F)。

---

### REQ-ARJ-004: 阿俊实用连招库与六大起手分类规范
- **需求描述**:
  在 `assets/data/sf6_combos.json` 与 `Sf6CombosDatabase` 中为阿俊录入权威实战连段，杜绝脏数据，严格遵守 6 大中文标准起手类型（确反康/普通命中/斗气迸发/绿冲起手/版边崩防/打断康），并配齐通俗易懂的中文实战指南。
- **连招条目契约 (规范示例)**:
  1. `确反康 (Punish Counter)`:
     - 序列: `PC 5HP > 4HP > 236PP, 623HP > 236236P (SA3)`
     - 伤害: `5820 (CA 6220)` | 消耗: `2气 + 3槽` | 难度: `进阶` | 位置: `任意位置`
     - 指南: “对手大升龙破空后的最痛确反路线。利用 4HP 取消接 OD 正义之臂打出弹墙，重狂暴之肩顺势带入 SA3 夜叉之令斩杀。”
  2. `普通命中 (Normal Hit)`:
     - 序列: `2LK ~ 2LP ~ 5LP > 236LP`
     - 伤害: `1260` | 消耗: `0气 + 0槽` | 难度: `极简` | 位置: `任意位置`
     - 指南: “核心下段轻攻击摸奖确认，近身点中即确认接轻正义之臂换位击倒。”
  3. `打断康 (Counter Hit)`:
     - 序列: `CH 5MP, 2MP > 214MK`
     - 伤害: `1850` | 消耗: `0气 + 0槽` | 难度: `简单` | 位置: `版中`
     - 指南: “立回中拳抢招打断对手动作，命中后从容目押接 2MP 呼吸之环。”
  4. `绿冲起手 (Drive Rush)`:
     - 序列: `2MK > DRC, 5HP > 4HP > 214214P (SA2)`
     - 伤害: `3890` | 消耗: `3气 + 2槽` | 难度: `普通` | 位置: `任意位置`
     - 指南: “下中脚立回突进确认，投入 3 格斗气与 2 条 SA 能量，打出高额灰血压制伤害。”
  5. `斗气迸发 (Drive Impact)`:
     - 序列: `PC Drive Impact, 6HP, 22PP, 623HP`
     - 伤害: `3250` | 消耗: `2气 + 0槽` | 难度: `普通` | 位置: `版边`
     - 指南: “迸发破防崩墙后，大威力冲拳接 OD 神柱引发共鸣，重狂暴之肩追击。”
  6. `版边崩防 (Wall Splat)`:
     - 序列: `Wall Splat, 5HK, 236HP > 236236K (SA1)`
     - 伤害: `3150` | 消耗: `0气 + 1槽` | 难度: `简单` | 位置: `版边`
     - 指南: “对手力竭被推墙崩防的极简惩罚，单槽 SA1 稳定收割。”
- **边界条件与异常处理**:
  - JSON 格式必须经过合规校验，`characterId` 统一为 `'arjun'`，`damage` 均为纯数字字符串，禁止出现出招代码误填或乱码。
- **验收标准 (Given-When-Then)**:
  - **Given** 用户在【实用连招】板块选择“阿俊”；
  - **When** 浏览连招列表并切换起手筛选标签；
  - **Then** 能够清晰检索出包含上述 6 大类别的规范连段卡片，指令图标无乱码，一键复制功能正常。

---

### REQ-ARJ-005: 阿俊对策复盘笔记与媒体映射字典规范
- **需求描述**:
  在 `NotesService` 录入阿俊的官方战术对抗复盘心得；并在 `Sf6MoveMediaHelper` 扩充阿俊的 UFD 媒体 slug 与招式文件名映射，确保二级弹窗与碰撞框模块具备正向动图寻址能力。
- **输入输出与契约要求**:
  1. **对策复盘笔记 (`NotesService`)**:
     - 预置阿俊对战心得：
       - “【立回防范】阿俊 5MK 与 6HP 手长判定极强，但收招硬直较大，可多尝试绿冲下中脚下盘插动”；
       - “【规避指令投】阿俊拥有 5F 极速指令投（阴森审讯），近身压制被其贴身时需提防打拆投，果断跳跃或后撤步确反”；
       - “【破防防壁】注意其 214P 不屈防壁架势，切忌无脑出高硬直单发攻击被其 Moral Breakdown 借力反击”。
  2. **媒体助手字典 (`Sf6MoveMediaHelper`)**:
     - Slug 规范：`getUfdCharacterSlug('arjun') => 'arjun'`；
     - 核心必杀映射字典：
       - 236P -> `arjun-armofjustice-hp.gif`
       - 623P -> `arjun-cruelshoulder-hp.gif`
       - 214K -> `arjun-breathingring-hk.gif`
       - 22P -> `arjun-divinepillar-hp.gif`
       - 63214K -> `arjun-ghastlyinterrogation.gif`
       - 214P -> `arjun-indomitabledefense.gif`
       - SA1/SA2/SA3 对应超杀动画映射。
- **边界条件与异常处理**:
  - 若海外动图尚未完全收录，由 `REQ-GIF-001` 本地高保真网格剪影平滑保底。
- **验收标准 (Given-When-Then)**:
  - **Given** 用户在阿俊笔记板块查阅对策；
  - **When** 载入笔记；
  - **Then** 显示权威的阿俊攻防心得；
  - **When** 碰撞框模块调用 `Sf6MoveMediaHelper.getHitboxGifUrl('arjun', move)`；
  - **Then** 精准拼装出规范的 UFD URL，无非法字符。

---

### REQ-AUD-001: 根治普通技克隆伪造回退与全角色真实独立普通技规范
- **需求描述**:
  清查表明：`FrameDataDatabase._getNormalsFor(id)` 在 `default:` 分支中直接 copy/fallback 隆（Ryu）的普通技，导致众多未显式写 case 的角色普通技全部被篡改为隆的数值（发生、被防差全同）。这是极其严重的结构性伪造！
  必须彻底重构：
  1. 彻底清查并移除 `default: return [FrameMove(name: '站立轻拳 (5LP)...)]` 克隆隆数据的行为；
  2. 建立双轨权威加载引擎：
     - **轨道 A**: 优先从离线静态完整数据库 `assets/data/sf6_framedata.json` 中动态读取该角色的全量真实招式（包含每位角色独特的 18 招普通技数值与特性）；
     - **轨道 B**: 对于预置内存编译的官方核心角色，在 `_getNormalsFor(id)` 中必须逐一补齐真实的独特数值，未录入角色若 JSON 亦无，必须严格返回空列表，**严禁凭空克隆其他角色数据**！
- **输入输出与结构约束**:
  - 针对全量收录角色的普通技核心指标审计：
    - 桑吉尔夫 (Zangief): 5LP 必须为 7F，2MK 必须 `isCancelable == false`；
    - 春丽 (Chun-Li): 5MP 必须为 6F，2MK 必须 `isCancelable == false`；
    - 古烈 (Guile): 5MP 必须为 6F，`isCancelable == false`；
    - 嘉米 (Cammy): 5LK 必须为 4F，`isCancelable == true`；
    - 玛丽莎 (Marisa): 5HP 必须为 13F(蓄力17F)，带霸体；
    - 埃德 (Ed)、维加 (Bison)、特瑞 (Terry)、不知火舞 (Mai)、阿俊 (Arjun) 等必须全部享有独立真实的普通技集合。
- **边界条件与异常处理**:
  - 全量扫描断言：对于任意两个不同角色 $A \neq B$，其普通技列表中被防差与发生帧数组的完全相等率必须 $< 100\%$，绝杜绝全盘克隆。
- **验收标准 (Given-When-Then)**:
  - **Given** 用户在帧数表中切换查看桑吉尔夫、春丽与阿俊的普通技；
  - **When** 对比其 5LP 与 2MK 的数据；
  - **Then** 绝不出现与隆完全一致的雷同克隆数据，各自展示官方 Supercombo 权威数值。

---

### REQ-AUD-002: 全 32 位角色机体属性数据库全量补齐与假数据清除规范
- **需求描述**:
  `lib/data/character_stats_database.dart` 当前仅包含了 11 个旧角色，其余 20+ 个角色全部进入 `getStats()` 的通用假数据 fallback（血量硬编码 10000、走速冲刺全为隆的数据）。
  必须彻底清查并全量补齐 SF6 全部 32 位官方收录格斗家的真实立回机体数据（基于 Supercombo Wiki 与官方数据表）。
- **覆盖格斗家全量清单 (32 位)**:
  1. `ryu` (隆)
  2. `ken` (肯)
  3. `luke` (卢克)
  4. `cammy` (嘉米)
  5. `chunli` (春丽)
  6. `guile` (古烈)
  7. `zangief` (桑吉尔夫)
  8. `juri` (韩蛛俐)
  9. `bison` (维加 / M.Bison)
  10. `terry` (特瑞)
  11. `akuma` (豪鬼)
  12. `arjun` (阿俊) - **新增**
  13. `ed` (埃德)
  14. `rashid` (拉希德)
  15. `aki` (阿鬼)
  16. `marisa` (玛丽莎)
  17. `jp` (JP)
  18. `manon` (曼侬)
  19. `deejay` (迪·杰)
  20. `ehonda` (本田)
  21. `dhalsim` (达尔西姆)
  22. `blanka` (布兰卡)
  23. `lily` (莉莉)
  24. `jamie` (杰米)
  25. `kimberly` (金伯莉)
  26. `mai` (不知火舞)
  27. `elena` (艾莲娜)
  28. 以及后续季票确认登场角色。
- **核心体能指标必须全真核对**:
  - `lifePoints`: 豪鬼 9000、老桑 10500、阿俊 10500、玛丽莎 10500，其余角色 10000；
  - `forwardWalkSpeed` / `backwardWalkSpeed`: 每位角色独有走速（如嘉米 0.051，老桑 0.038）；
  - `forwardDashSpeed` / `forwardDashDistance`: 每位角色独有前冲性能；
  - `driveRushMax`: 绿冲极限距离（如 DJ、玛丽莎超远滑行 vs 老桑短绿冲）；
  - `jumpApex` 与 `jumpSpeed`: 每位角色真实的跳跃滞空与最高点。
- **边界条件与异常处理**:
  - 彻底将 `getStats` 中的假数据兜底替换为防御性安全对象，并输出警告日志；
  - 对 32 位官方格斗家，`_data.containsKey(key)` 判定必须 100% 为 `true`。
- **验收标准 (Given-When-Then)**:
  - **Given** 用户在【基础属性】板块依次切换查看拉希德、埃德、不知火舞与阿俊；
  - **When** 检查属性面板；
  - **Then** 所有角色均展示各自专属的血量、走速、绿冲极值与经典语录，绝无千篇一律的通用假数据。

---

### REQ-VER-001: 应用版本号与构建编号统一大版本升阶至 1.2.7.0 (build 2700)
- **需求描述**:
  鉴于本次完成了全新官方角色阿俊的完整生态上线以及全量数据库的去伪存真治理，应用全局版本号严格升级至里程碑大版本 `v1.2.7.0 (build 2700)`。
- **变更文件与配置项**:
  1. `pubspec.yaml`:
     - 原值: `version: 1.2.6+2605`
     - 目标值: `version: 1.2.7+2700`
  2. `lib/core/utils/app_logger.dart`:
     - 原值: `static const String currentAppVersion = 'v1.2.6.5';`
     - 目标值: `static const String currentAppVersion = 'v1.2.7.0';`
     - 原值: `static const String currentBuildNumber = '2605';`
     - 目标值: `static const String currentBuildNumber = '2700';`
- **验收标准 (Given-When-Then)**:
  - **Given** 应用编译打包完成；
  - **When** 导出运行日志或查看应用内诊断；
  - **Then** 日志头部与关于页面确切显示为 `v1.2.7.0 (build 2700)`。

---

## 4. 前序基础功能规格固化 (Base Functional Specifications)

为了保证系统规格的连续性与完整性，前序已验收并投入生产的核心规格在此保持固化生效：

1. **REQ-IPA-001 ~ REQ-IPA-003, REQ-DOC-001: iOS 未签名 IPA 方案全套基础设施**
   - GitHub Actions 云端 macOS 自动化无代码签名 Release 流水线；
   - `ios/Runner/Info.plist` 中文显示名“街霸6助手”、相册权限、ATS 放行与 120Hz 高刷原生合规；
   - 本地跨平台打包脚本（`package_unsigned_ipa.sh` / `.ps1`）；
   - 用户端保姆级免越狱侧载手册（TrollStore 直装、Sideloadly 7天自签、开发者模式、数据保留续签与 FAQ）。
2. **REQ-DAT-003: 必杀技轻/中/重/OD四版本真实数据模型与变种表**
   - 彻底推翻 `+2/+4` 伪造算法，基于 `MoveVariation` 模型录入官方真实轻中重 OD 数据，弹窗真实渲染。
3. **REQ-CHT-003 & REQ-CHT-004: 排位折线图纯中文标题、二级展开菜单与段位色彩刻度**
   - 标题纯中文“排位分数走势”，去除冗余英文与括号；
   - 维度切换改右上角二级展开菜单（`PopupMenuButton`），折叠展示 `[近20场 ▾]`；
   - Y 轴刻度基于 `Sf6Rank.fromLpOrMr` 动态渲染官方段位色彩；
   - 监听主玩角色变动即时同步；空排位记录安全切换并友好兜底提示“暂无排位赛记录”。
4. **REQ-HOM-001: 首页 7 大核心卡片显隐与拖拽排序自定义**
   - 涵盖 `hero`, `score_chart`, `ladder`, `recent_form`, `play_time`, `quick_stats`, `radar`；
   - 设置页增设「首页卡片管理」入口，支持 `ReorderableListView` 拖拽排序与 `Switch` 显隐，支持一键恢复默认；
   - 通过 `StorageService` 永久持久化保存配置，首页按自定义配置动态消费渲染。
5. **REQ-RPL-001 & REQ-TOL-001: 对战录像代码复制与工具默认角色自适应**
   - 录像代码一键复制与 CFN 5 步检索观看指引；
   - 工具箱默认角色自适应绑定当前主玩角色（`activePlatform.mainCharId` -> `userProfile.mainCharacterId` -> `'ryu'`）。
6. **REQ-GIF-004: 碰撞框动图本地应用沙盒磁盘持久化缓存架构**
   - 基于 `path_provider` 实现沙盒磁盘永久缓存，0ms 秒开，可统计可清理。
7. **REQ-GIF-001 ~ REQ-GIF-003, REQ-COS-001 ~ REQ-COS-002, REQ-CMB-001 ~ REQ-CMB-003**
   - 动图渐进式加载、二级检视首选动图、媒体助手字典覆盖；
   - 招式消耗精准分离（普通必杀 0 气、OD 2 气、SA 1~3 槽）；
   - 连招数据治理、6 大中文标准起手类型与智能容错。
8. **REQ-NAV-001, REQ-SHR-001, REQ-CMD-001, REQ-CMD-002, REQ-DAT-001, REQ-HTB-001**
   - 跨界面防自环导航、真实剪贴板分享、经典/现代标准图形指令渲染、豪鬼“车蹴”官方中文对齐、碰撞框 60FPS 逐帧播放内核。

---

## 5. 非功能性需求与性能指标 (Non-Functional Requirements & Performance Budgets)

### 5.1 数据检索与内存开销
1. **全 32 位角色切换响应时延**:
   - 工具箱在 32 位格斗家之间无缝切换时，招式表与机体属性计算耗时强制 $\le 16\text{ms}$，严禁主线程掉帧；
   - 32 位角色常驻内存数据结构总占用 $\le 6\text{MB}$。
2. **数据一致性校验指标**:
   - 全角色普通技雷同度清零检查：不存在任何非同一人物却拥有全相同 18 招普通技的异常数据；
   - `assets/data/sf6_combos.json` 与 `assets/data/sf6_framedata.json` 语法校验 100% 通过。

### 5.2 兼容性与原生稳定性
1. **CI/CD 构建时限**:
   - 包含新增角色数据与全量单测后，GitHub Actions 云端流水线构建总耗时保持在 $\le 12\text{分钟}$。

---

## 6. 人工审核门禁与签署挂起清单 (Human Approval Gate & Sign-off)

> [!IMPORTANT]
> **软件规格分析师严格声明**：
> 本规格说明书已完成全方位深度扩展与修订，严密覆盖了用户的最新需求：
> 1. 新角色阿俊 (Arjun) 常量与全局元数据注册 (`REQ-ARJ-001`)；
> 2. 阿俊权威机体立回与属性数据库录入 (`REQ-ARJ-002`)；
> 3. 阿俊权威帧数库与必杀技四版本真实变种录入 (`REQ-ARJ-003`)；
> 4. 阿俊 6 大标准起手实用连招库建设 (`REQ-ARJ-004`)；
> 5. 阿俊对策复盘笔记与媒体映射字典扩充 (`REQ-ARJ-005`)；
> 6. 彻底清除 `_getNormalsFor` 克隆隆数据的伪造回退缺陷，全角色普通技独立动态对齐 (`REQ-AUD-001`)；
> 7. 清理假数据 fallback，全量补齐全 32 位官方格斗家权威机体立回数据 (`REQ-AUD-002`)；
> 8. 目标版本里程碑大跨越至 `1.2.7.0 (build 2700)` (`REQ-VER-001`)。
>
> 遵循岗位职责约束，**本人严禁编写任何业务实现代码或单元测试代码。**
> 本规格文件（`specs/spec.md`）现已固化并处于**挂起等待人工审核状态 (PENDING_HUMAN_APPROVAL)**。

### 审核检查清单 (Audit Checklist)
- [ ] **REQ-ARJ-001 ~ REQ-ARJ-005**: 新角色阿俊的元数据、属性、帧数表（含四版本变种）、连招库、笔记及媒体字典是否完备精准？
- [ ] **REQ-AUD-001**: 彻底铲除普通技克隆隆数据的结构缺陷、实现全角色独立普通技的方案是否清晰无误？
- [ ] **REQ-AUD-002**: 全量 32 位官方格斗家机体立回属性补全范围是否覆盖全员？
- [ ] **REQ-VER-001**: 目标版本 `1.2.7.0 (build 2700)` 与 `pubspec.yaml` `1.2.7+2700` 是否完全对齐？

---
*规格说明书编制完成，流水线挂起等待人工审核批准。*

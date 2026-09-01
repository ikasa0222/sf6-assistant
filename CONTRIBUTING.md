# 贡献指南 (Contributing Guide)

感谢您对 **街霸6助手 (SF6 Assistant)** 开源项目的关注与支持！无论是提交 Bug 报告、提出新功能建议，还是贡献代码，我们都非常欢迎。

---

## 🛠️ 开发与环境搭建

### 1. 必备前置环境
- **Flutter SDK**: `>= 3.0.0 < 4.0.0`
- **Dart SDK**: 同步于 Flutter 版本
- **Android SDK**: API Level `>= 21` (推荐 Android 10+ / API 29+)
- **IDE**: Android Studio / VS Code (安装 Flutter 与 Dart 插件)

### 2. 本地克隆与启动
```bash
# 克隆仓库
git clone https://github.com/OldSea/SF6_Assistant.git
cd SF6_Assistant

# 获取依赖
flutter pub get

# 启动调试 (连接真机或启动模拟器)
flutter run
```

---

## 🧪 自动化测试规范

在提交 Pull Request 之前，请务必确保所有单元测试与解析器校验通过：

```bash
flutter test
```

---

## 📂 代码架构与目录规范

```
lib/
├── core/         # 底层基础设施（网络抓包、加密存储、主题配色、黑匣子日志）
├── models/       # 强类型数据模型（对战记录、玩家档案、战队、帧数表、段位）
├── services/     # 核心业务逻辑与数据处理服务（Auth, BattleLog, FrameData, Update, Stats, Social）
└── ui/           # 表现层 UI（Screens 页面与可复用 Widgets 组件）
```

---

## 📝 Pull Request 规范

1. **创建分支**：基于 `main` 分支拉取新分支（例如 `feature/frame-data-search` 或 `fix/webview-cookie`）；
2. **规范提交信息 (Conventional Commits)**：
   - `feat: 新增功能描述`
   - `fix: 修复问题描述`
   - `docs: 文档更新`
   - `style: 代码格式调整`
   - `refactor: 代码重构`
   - `test: 测试用例调整`
3. **提交 PR**：描述您的修改内容、解决的 Issue 以及测试验证截图。

再次感谢每一位格斗游戏爱好者与开源开发者的贡献！🔥

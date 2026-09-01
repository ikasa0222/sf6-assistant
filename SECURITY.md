# 安全与隐私策略 (Security & Privacy Policy)

## 🔒 本地优先与隐私原则 (Local-First Privacy)

街霸6助手严格遵守**纯客户端架构与本地优先安全准则**：

1. **零服务端收集**：本应用没有任何自有服务器，绝不上报、收集、传输或泄露任何用户的账号密码、Cookie 或对局数据。
2. **硬件级加密存储**：所有本地保存的 Capcom ID 登录凭据均通过系统硬件加密通道（`flutter_secure_storage` / Android Keystore）加密持久化。
3. **官方直连通信**：应用内所有网络请求均直连卡普空官方 Buckler's Boot Camp 域名（`https://www.streetfighter.com`），不经过任何第三方代理中转。

---

## 🛡️ 漏洞报告 (Reporting a Vulnerability)

如果您在本项目中发现了任何潜在的安全或隐私隐患，请不要公开在 Issue 中发布漏洞细节，请通过私信或邮件联系维护者，我们将第一时间响应并修复。

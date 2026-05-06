---
name: asa-shop-auth-email
description: 用于终端用户邮箱验证码登录流程。当用户提到"邮箱登录""验证码登录""刷新会话""退出登录"时触发。
version: 2.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, auth, email, session]
---

# asa-shop-auth-email

## 目标

完成终端用户的邮箱验证码登录闭环，支持登录、刷新、查询用户信息、登出。

> **注意**：本协议下所有接口当前为 🔜 桩接口（返回 501），尚未在 Phase 1 实现。

## 前置条件

- 已知 `merchant_id`
- ASA 协议 Phase 1 无需额外鉴权（后续 Phase 4 接入 OpenASA OAuth）
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`

## 关键接口

| 方法 | 路径 | 状态 |
|------|------|------|
| POST | `/shop/{merchant_id}/auth/auth-email/requestEmailLoginCode` | 🔜 桩接口 |
| POST | `/shop/{merchant_id}/auth/auth-email/verifyEmailLoginCode` | 🔜 桩接口 |
| POST | `/shop/{merchant_id}/auth/auth-email/refreshAuthSession` | 🔜 桩接口 |
| GET | `/shop/{merchant_id}/auth/auth-email/getAuthUserInfo` | 🔜 桩接口 |
| POST | `/shop/{merchant_id}/auth/auth-email/logoutAuthSession` | 🔜 桩接口 |

## 执行步骤

1. 请求验证码：提交用户邮箱，确认响应里的 `expires_in`，文档示例为 300 秒。
2. 验证登录：提交邮箱与 6 位验证码，换取会话 `token`。
3. 可选：读取当前登录用户信息用于会话确认。
4. 会话临近过期时执行刷新。
5. 用户要求退出时执行登出。

## 字段与响应要点

- `requestEmailLoginCode` 请求体只需要 `email`
- `verifyEmailLoginCode` 请求体需要 `email` 和 `code`
- `verifyEmailLoginCode` 示例响应包含 `token`、`token_type`、`expires_in`
- `getAuthUserInfo` 可返回 `sub`、`email`、`name`

## 风险与校验

- 验证码为 6 位数字，过期后需重新获取
- 对邮箱格式做基础校验
- 不在聊天中重复展示完整会话 token
- 刷新和登出前先确认当前会话上下文，避免操作错账号

## 失败处理

- `INVALID_PARAMETER`：邮箱或验证码格式错误
- `TOKEN_EXPIRED`：重新认证
- `UNAUTHORIZED`：检查调用头和凭据

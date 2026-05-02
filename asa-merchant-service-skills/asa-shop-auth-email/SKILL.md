---
name: asa-shop-auth-email
description: 用于终端用户邮箱验证码登录流程。当用户提到“邮箱登录”“验证码登录”“刷新会话”“退出登录”时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, auth, email, session]
---

# asa-shop-auth-email

## 目标

完成终端用户的邮箱验证码登录闭环，支持登录、刷新、查询用户信息、登出。

## 前置条件

- 已知 `merchant_id`
- 已具备 OAuth Token 或 API Key（调用 auth-email 协议同样要求认证）

## 关键接口

- `POST /shop/{merchant_id}/auth/auth-email/requestEmailLoginCode`
- `POST /shop/{merchant_id}/auth/auth-email/verifyEmailLoginCode`
- `POST /shop/{merchant_id}/auth/auth-email/refreshAuthSession`
- `GET /shop/{merchant_id}/auth/auth-email/getAuthUserInfo`
- `POST /shop/{merchant_id}/auth/auth-email/logoutAuthSession`

## 执行步骤

1. 请求验证码：提交用户邮箱，确认 `expires_in`。
2. 验证登录：提交邮箱与验证码，换取会话 `token`。
3. 可选：读取当前登录用户信息用于会话确认。
4. 会话临近过期时执行刷新。
5. 用户要求退出时执行登出。

## 风险与校验

- 验证码为 6 位数字，过期后需重新获取
- 对邮箱格式做基础校验
- 不在聊天中重复展示完整会话 token

## 失败处理

- `INVALID_PARAMETER`：邮箱或验证码格式错误
- `TOKEN_EXPIRED`：重新认证
- `UNAUTHORIZED`：检查调用头和凭据

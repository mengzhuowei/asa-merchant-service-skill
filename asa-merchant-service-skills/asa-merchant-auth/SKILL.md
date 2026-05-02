---
name: asa-merchant-auth
description: 用于商户后台管理接口认证流程，包括注册、登录、MFA、刷新、登出和当前账号信息读取。当用户提到“商户后台登录/认证”时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, auth, mfa]
---

# asa-merchant-auth

## 目标

为商户运营侧提供标准化身份认证能力，确保后续管理接口可安全调用。

## Base URL

- `/merchant`

## 关键接口

- `POST /merchant/auth/register`
- `POST /merchant/auth/login`
- `POST /merchant/auth/mfa/verify`
- `POST /merchant/auth/refresh`
- `POST /merchant/auth/logout`
- `GET /merchant/auth/me`

## 执行步骤

1. 按需执行注册或登录。
2. 若登录返回 `mfa_required=true`，立即转 MFA 验证。
3. 获取 JWT Token 后缓存到安全上下文。
4. 调用 `me` 检查当前登录身份。
5. 在会话过期前刷新，结束操作后登出。

## 输出模板

- `认证状态`：成功/失败
- `MFA 状态`：是否已通过
- `会话有效性`：当前可用/需要刷新
- `当前账号`：`admin_id`、`username`（如可用）

## 安全要求

- 不打印密码
- 不回显完整 Token
- 登录失败时不猜测账号存在性

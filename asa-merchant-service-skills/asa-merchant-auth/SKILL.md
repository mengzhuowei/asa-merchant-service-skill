---
name: asa-merchant-auth
description: 用于商户后台管理接口认证流程，包括注册、登录、MFA、刷新、登出和当前账号信息读取。当用户提到“商户后台登录”“商户认证”“MFA 验证”时触发。
version: 1.1.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, auth, mfa]
---

# asa-merchant-auth

## 目标

为商户运营侧提供标准化身份认证能力，确保后续管理接口可安全调用。

## Base URL

- `/merchant`
- 服务地址默认使用 `http://192.168.6.174:8080`

## 关键接口

- `POST /merchant/auth/register`
- `POST /merchant/auth/login`
- `POST /merchant/auth/mfa/verify`
- `POST /merchant/auth/refresh`
- `POST /merchant/auth/logout`
- `GET /merchant/auth/me`

## 执行步骤

1. 按需执行注册或登录；注册时先收集 `username`、`password`、`merchant_name` 等字段。
2. 若登录返回 `mfa_required=true`，立即转 MFA 验证，并使用登录阶段返回的临时凭据继续。
3. 获取 JWT Token 后缓存到安全上下文。
4. 调用 `me` 检查当前登录身份。
5. 在会话过期前刷新，结束操作后登出。

## 字段与响应要点

- `login` 成功响应可包含 `token`、`token_type`、`mfa_required`、`admin`
- `admin` 示例字段包含 `id`、`username`、`name`
- `me` 用于确认当前账号，示例至少返回 `admin_id`
- `refresh` 需要在请求体里携带当前 `token`

## 输出模板

- `认证状态`：成功/失败
- `MFA 状态`：是否已通过
- `会话有效性`：当前可用/需要刷新
- `当前账号`：`admin_id`、`username`（如可用）

## 安全要求

- 不打印密码
- 不回显完整 Token
- 登录失败时不猜测账号存在性
- 仅在用户明确要求时执行登出，避免中断正在进行的后台操作

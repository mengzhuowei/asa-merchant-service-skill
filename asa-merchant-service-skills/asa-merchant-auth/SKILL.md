---
name: asa-merchant-auth
description: 用于商户后台管理接口认证流程，包括登录、登出、Token 刷新和当前账号信息读取。当用户提到"商户后台登录""商户认证"时触发。
version: 2.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, auth]
---

# asa-merchant-auth

## 目标

为商户运营侧提供标准化身份认证能力，确保后续管理接口可安全调用。

## Base URL

- `/merchant/auth`
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`

## 关键接口

| 方法 | 路径 | 状态 | 鉴权 |
|------|------|------|------|
| POST | `/merchant/auth/login` | ✅ 已实现 | 无需 |
| POST | `/merchant/auth/logout` | ✅ 已实现 | Bearer Token |
| GET | `/merchant/auth/me` | ✅ 已实现 | Bearer Token |
| POST | `/merchant/auth/refresh` | ✅ 已实现 | Bearer Token |

## 执行步骤

1. 调用 login，传入 `merchant_id`、`username`、`password`。
2. 获取 JWT Token（默认有效期 24 小时），缓存到安全上下文。
3. 调用 `GET /merchant/auth/me` 检查当前登录身份。
4. 在会话过期前调用 `POST /merchant/auth/refresh` 刷新。
5. 结束操作后调用 `POST /merchant/auth/logout` 登出。

## 字段与响应要点

### POST /merchant/auth/login

请求体：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| merchant_id | string | 是 | 商户唯一标识 |
| username | string | 是 | 登录用户名 |
| password | string | 是 | 登录密码 |

成功响应 (200) 包含 `token` 和 `admin` 对象，`admin` 包含 `admin_id`、`merchant_id`、`username`、`name`、`role`、`email`。

错误响应：

| 错误码 | HTTP | 说明 |
|--------|------|------|
| `INVALID_CREDENTIALS` | 401 | 用户名或密码错误 |
| `ACCOUNT_DISABLED` | 403 | 账号已被禁用 |
| `INVALID_PARAMETER` | 400 | 缺少必填字段 |

### GET /merchant/auth/me

响应包含 `admin_id`、`merchant_id`、`role`。

### POST /merchant/auth/refresh

当前为桩实现。请求体携带当前 `token`。

### POST /merchant/auth/logout

响应 `{"message": "已登出"}`。

## 种子测试账号

| 角色 | 用户名 | 密码 | 商户ID |
|------|--------|------|--------|
| 商户管理员 | `admin` | `admin123` | `mch_demo001` |

## 输出模板

- `认证状态`：成功/失败
- `会话有效性`：当前可用/需要刷新
- `当前账号`：`admin_id`、`merchant_id`、`role`（如可用）

## 安全要求

- 不打印密码
- 不回显完整 Token
- 登录失败时不猜测账号存在性
- 仅在用户明确要求时执行登出，避免中断正在进行的后台操作

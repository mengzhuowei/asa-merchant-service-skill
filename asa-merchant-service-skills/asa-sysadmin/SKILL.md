---
name: asa-sysadmin
description: 用于运营后台管理，包括运营登录、商户管理、商品审核、退款审核、账号管理、系统配置、公告管理和日志审计。当用户提到"运营后台""系统管理""审核商户""sysadmin"时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, sysadmin, admin, operations]
---

# asa-sysadmin

## 目标

为平台运营人员提供系统管理能力，覆盖商户管理、审核、配置和审计。

## 前置条件

- 通过 `POST /sysadmin/auth/login` 获取运营后台 JWT Token
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`

## 关键接口

### 认证（✅ 已实现）

| 方法 | 路径 | 状态 | 鉴权 |
|------|------|------|------|
| POST | `/sysadmin/auth/login` | ✅ 已实现 | 无需 |

### 商户管理（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/sysadmin/merchants` | 🔜 桩接口 |
| GET | `/sysadmin/merchants/{id}` | 🔜 桩接口 |
| POST | `/sysadmin/merchants/{id}/approve` | 🔜 桩接口 |
| POST | `/sysadmin/merchants/{id}/reject` | 🔜 桩接口 |
| POST | `/sysadmin/merchants/{id}/disable` | 🔜 桩接口 |
| POST | `/sysadmin/merchants/{id}/enable` | 🔜 桩接口 |

### 商品审核（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/sysadmin/products/review` | 🔜 桩接口 |
| POST | `/sysadmin/products/{id}/approve` | 🔜 桩接口 |
| POST | `/sysadmin/products/{id}/reject` | 🔜 桩接口 |

### 退款审核（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/sysadmin/refunds` | 🔜 桩接口 |
| POST | `/sysadmin/refunds/{id}/approve` | 🔜 桩接口 |
| POST | `/sysadmin/refunds/{id}/reject` | 🔜 桩接口 |

### 运营账号管理（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/sysadmin/admins` | 🔜 桩接口 |
| POST | `/sysadmin/admins` | 🔜 桩接口 |
| PUT | `/sysadmin/admins/{id}` | 🔜 桩接口 |
| DELETE | `/sysadmin/admins/{id}` | 🔜 桩接口 |

### 系统配置（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/sysadmin/config/{group}/{key}` | 🔜 桩接口 |
| PUT | `/sysadmin/config/{group}/{key}` | 🔜 桩接口 |

### 公告管理（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/sysadmin/announcements` | 🔜 桩接口 |
| POST | `/sysadmin/announcements` | 🔜 桩接口 |
| PUT | `/sysadmin/announcements/{id}` | 🔜 桩接口 |
| DELETE | `/sysadmin/announcements/{id}` | 🔜 桩接口 |

### 日志审计（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/sysadmin/logs/audit` | 🔜 桩接口 |
| GET | `/sysadmin/logs/login` | 🔜 桩接口 |
| GET | `/sysadmin/logs/settlement` | 🔜 桩接口 |

## 认证详细规范

### POST /sysadmin/auth/login

请求体：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | 是 | 登录用户名 |
| password | string | 是 | 登录密码 |

成功响应 (200) 包含 `token` 和 `admin` 对象，`admin` 包含 `user_id`、`username`、`name`、`role`、`email`、`phone`。

错误响应：

| 错误码 | HTTP | 说明 |
|--------|------|------|
| `INVALID_CREDENTIALS` | 401 | 用户名或密码错误 |
| `ACCOUNT_DISABLED` | 403 | 账号已被禁用 |
| `INVALID_PARAMETER` | 400 | 缺少必填字段 |

## 种子测试账号

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 运营管理员 | `super_admin` | `admin123` | 登录运营后台 |

## 执行规则

1. 所有写操作（approve/reject/disable/enable/delete）必须二次确认。
2. 当前除登录外所有管理接口为桩接口（返回 501），调用前向用户说明。
3. 遇到 `401/403` 先回到 sysadmin 认证修复。

## 失败处理

- `INVALID_CREDENTIALS` (401)：用户名或密码错误
- `ACCOUNT_DISABLED` (403)：账号已被禁用
- `INVALID_PARAMETER` (400)：缺少必填字段
- `UNAUTHORIZED` / `TOKEN_EXPIRED`：重新登录

## 安全要求

- 不打印密码
- 不回显完整 Token
- 禁用/删除等高风险操作必须二次确认
- 不伪造审核结果

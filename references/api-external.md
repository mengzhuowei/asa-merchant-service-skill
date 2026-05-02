# ASA Merchant Service — 商户 API 文档

> 版本：v2.9 | 更新日期：2026-05-01
>
> 本文档面向 **AI Agent 开发者** 和 **商户运营人员**，包含 ASA 协议接口和商户后台管理接口。

---

## 目录

- [1. 概述](#1-概述)
- [2. 通用约定](#2-通用约定)
- [3. ASA 协议接口](#3-asa-协议接口)
  - [3.1 try 协议](#31-try-协议)
  - [3.2 shop 协议](#32-shop-协议)
  - [3.3 payment 协议](#33-payment-协议)
  - [3.4 auth-email 协议](#34-auth-email-协议)
- [4. 商户后台管理接口](#4-商户后台管理接口)
  - [4.1 认证](#41-认证)
  - [4.2 入驻管理](#42-入驻管理)
  - [4.3 商品管理](#43-商品管理)
  - [4.4 订单管理](#44-订单管理)
  - [4.5 财务管理](#45-财务管理)
  - [4.6 商户配置](#46-商户配置)
- [5. 全局模型](#5-全局模型)
- [6. 错误码](#6-错误码)

---

## 1. 概述

ASA Merchant Service 提供两类 API：

| API 分类 | Base URL | 说明 | 认证方式 |
|----------|----------|------|----------|
| **ASA 协议接口** | `/shop/{merchant_id}` | AI Agent 调用，商品浏览、下单、支付等 | OAuth 2.0 Bearer Token 或 API Key |
| **商户后台管理** | `/merchant` | 商户运营人员使用，管理商品、订单、财务等 | 用户名+密码登录 JWT Token |

> **服务地址：** `http://192.168.6.174:8080`

---

## 2. 通用约定

### 2.1 分页

所有列表接口统一支持分页参数：

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| offset | int | 0 | 偏移量 |
| limit | int | 20 | 每页数量，最大 100 |

统一响应格式：

```json
{
  "data": [],
  "total": 0
}
```

### 2.2 限流

- 全局限流：每分钟 100 次请求
- 超过限制返回 HTTP 429 `RATE_LIMIT_EXCEEDED`
- 限流基于客户端 IP 或 `merchant_id`

### 2.3 时间格式

- 所有时间字段使用 ISO 8601 格式
- 示例：`2025-01-01T00:00:00+08:00`

### 2.4 错误响应格式

```json
{
  "code": "ERROR_CODE",
  "message": "错误描述"
}
```

### 2.5 CORS

- 允许所有来源（`Access-Control-Allow-Origin: *`）
- 支持方法：GET, POST, PUT, PATCH, DELETE, OPTIONS
- 允许请求头：Origin, Content-Type, Authorization, X-API-Key

---

## 3. ASA 协议接口

> **Base URL：** `/shop/{merchant_id}`
>
> 供 AI Agent 调用，需 OAuth 2.0 或 API Key 认证（try 协议除外）。

### 认证方式

**方式一：OAuth 2.0 Bearer Token**

通过 OpenASA OAuth 授权获取 access_token，在请求头中携带：

```
Authorization: Bearer <access_token>
```

Token 为 RS256 签名的 JWT，由 OpenASA 的 JWKS 公钥验证。

**方式二：API Key**

```
X-API-Key: <api_key>
```

API Key 由商户在后台自行创建和管理。

---

### 3.1 try 协议

无需认证，用于 Agent 检测服务连通性。

#### POST `/shop/{merchant_id}/try/ping`

健康检查。

**Response:**
```json
{
  "status": "ok",
  "timestamp": 1746057600
}
```

#### POST `/shop/{merchant_id}/try/echo`

参数回显测试。

**Request Body:**
```json
{
  "any_key": "any_value"
}
```

**Response:**
```json
{
  "echo": { "any_key": "any_value" },
  "method": "POST",
  "path": "/shop/{merchant_id}/try/echo"
}
```

#### POST `/shop/{merchant_id}/try/stats`

服务统计信息。

**Response:**
```json
{
  "uptime": "72h30m15s",
  "goroutines": 42,
  "memory_used": 83886080,
  "version": "1.0.0"
}
```

---

### 3.2 shop 协议

需 OAuth / API Key 认证。

#### GET `/shop/{merchant_id}/products`

获取商品列表（仅返回已上架商品）。

**Query Parameters:**

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| offset | int | 0 | 偏移量 |
| limit | int | 20 | 每页数量，最大 100 |

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "product_id": "prod_xxx",
      "merchant_id": "mch_xxx",
      "name": "iPhone 15 Pro Max",
      "description": "全新正品，全国联保",
      "price": 9999.00,
      "currency": "CNY",
      "stock": 100,
      "images": "[\"https://image.url/1.png\"]",
      "category": "数码产品",
      "tags": "[\"苹果\",\"手机\",\"热销\"]",
      "sku": "AP-IP15PM-001",
      "attributes": "{\"color\":\"深空黑\",\"storage\":\"256GB\"}",
      "status": "published",
      "created_at": "2025-01-01T00:00:00+08:00",
      "updated_at": "2025-01-01T00:00:00+08:00"
    }
  ],
  "total": 1
}
```

#### GET `/shop/{merchant_id}/products/{product_id}`

获取商品详情。

**Response:** 单个商品对象（同上）。

#### POST `/shop/{merchant_id}/orders`

创建订单。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| product_id | string | ✅ | 商品 ID |
| quantity | int | ✅ | 数量，最小 1 |
| contact_phone | string | ❌ | 联系电话 |
| contact_address | string | ❌ | 收货地址 |
| remark | string | ❌ | 备注 |

**Response (201 Created):**
```json
{
  "id": "uuid",
  "order_no": "ord_xxx",
  "merchant_id": "mch_xxx",
  "product_id": "prod_xxx",
  "product_name": "iPhone 15 Pro Max",
  "quantity": 1,
  "unit_price": 9999.00,
  "total_amount": 9999.00,
  "paid_amount": 0,
  "currency": "CNY",
  "status": "created",
  "contact_phone": "138xxxxxxxx",
  "contact_address": "收货地址",
  "remark": "请尽快发货",
  "created_at": "2025-01-01T00:00:00+08:00",
  "updated_at": "2025-01-01T00:00:00+08:00"
}
```

#### GET `/shop/{merchant_id}/orders/{order_id}`

获取订单详情。

**Response:** 完整订单对象（含 `paid_amount`、`paid_at`、`fulfilled_at` 等）。

#### POST `/shop/{merchant_id}/orders/{order_id}/cancel`

取消订单。

**Request Body:**
```json
{
  "reason": "不想买了"
}
```

**Response:**
```json
{
  "message": "订单已取消"
}
```

---

### 3.3 payment 协议

需 OAuth / API Key 认证。

#### GET `/shop/{merchant_id}/payment/methods`

获取支持的支付方式列表。

**Response:**
```json
{
  "data": [
    { "channel": "sand", "name": "杉德支付", "type": "sand" },
    { "channel": "wechat", "name": "微信支付", "type": "wechat" },
    { "channel": "alipay", "name": "支付宝", "type": "alipay" }
  ]
}
```

#### POST `/shop/{merchant_id}/payment/orders`

创建支付单。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| order_id | string | ✅ | 订单 ID |
| channel | string | ✅ | 支付通道：`sand` / `wechat` / `alipay` |

**Response (201 Created):**
```json
{
  "id": "pay_xxx",
  "merchant_id": "mch_xxx",
  "order_id": "ord_xxx",
  "channel": "sand",
  "amount": 9999.00,
  "currency": "CNY",
  "status": "pending",
  "channel_order_id": "",
  "created_at": "2025-01-01T00:00:00+08:00",
  "updated_at": "2025-01-01T00:00:00+08:00"
}
```

#### GET `/shop/{merchant_id}/payment/orders/{payment_order_id}`

查询支付单状态。

**Response:** 支付单对象（同上）。

#### POST `/shop/{merchant_id}/payment/orders/{payment_order_id}/close`

关闭支付单。

**Response:**
```json
{
  "message": "支付单已关闭"
}
```

#### POST `/shop/{merchant_id}/payment/refunds`

申请退款。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| order_id | string | ✅ | 订单 ID |
| amount | float | ✅ | 退款金额 |
| reason | string | ✅ | 退款原因 |

**Response (201 Created):**
```json
{
  "message": "退款申请已提交"
}
```

#### GET `/shop/{merchant_id}/payment/refunds/{refund_id}`

查询退款申请状态。

**Response:**
```json
{
  "refund_id": "ref_xxx"
}
```

---

### 3.4 auth-email 协议

需 OAuth / API Key 认证。用于终端用户的邮箱验证码登录流程。

#### POST `/shop/{merchant_id}/auth/auth-email/requestEmailLoginCode`

请求邮箱登录验证码。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| email | string | ✅ | 有效的邮箱地址 |

**Response:**
```json
{
  "message": "验证码已发送",
  "expires_in": 300
}
```

> 验证码为 6 位数字，发送至指定邮箱。

#### POST `/shop/{merchant_id}/auth/auth-email/verifyEmailLoginCode`

验证邮箱登录码。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| email | string | ✅ | 邮箱地址 |
| code | string | ✅ | 验证码 |

**Response:**
```json
{
  "token": "session_token_xxx",
  "token_type": "bearer",
  "expires_in": 3600
}
```

#### POST `/shop/{merchant_id}/auth/auth-email/refreshAuthSession`

刷新会话。

**Response:**
```json
{
  "token": "new_session_token_xxx",
  "token_type": "bearer",
  "expires_in": 3600
}
```

#### GET `/shop/{merchant_id}/auth/auth-email/getAuthUserInfo`

获取当前登录用户信息。

**Response:**
```json
{
  "sub": "user_xxx",
  "email": "user@example.com",
  "name": "User"
}
```

#### POST `/shop/{merchant_id}/auth/auth-email/logoutAuthSession`

登出当前会话。

**Response:**
```json
{
  "message": "已登出"
}
```

---

## 4. 商户后台管理接口

> **Base URL：** `/merchant`
>
> 供商户运营人员使用，需登录获取 JWT Token 后携带 `Authorization: Bearer <token>`。

### 4.1 认证

#### POST `/merchant/auth/register`

注册商户管理员账号。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | ✅ | 登录用户名，唯一 |
| password | string | ✅ | 登录密码 |
| merchant_name | string | ✅ | 商户名称 |
| name | string | ❌ | 管理员姓名 |
| email | string | ❌ | 联系邮箱 |
| phone | string | ❌ | 联系电话 |

**Response:**
```json
{
  "message": "注册成功",
  "admin_id": "a1b2c3d4e5f67890abcdef1234567890",
  "merchant_id": "mch_xxx",
  "username": "shop_admin"
}
```

#### POST `/merchant/auth/login`

登录获取 Token。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| username | string | ✅ | 用户名 |
| password | string | ✅ | 密码 |

**Response:**
```json
{
  "token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer",
  "mfa_required": false,
  "admin": {
    "id": "a1b2c3d4e5f67890abcdef1234567890",
    "username": "shop_admin",
    "name": "管理员张三"
  }
}
```

> 若商户开启了 MFA，`mfa_required` 为 `true`，需调用 MFA 验证接口。

#### POST `/merchant/auth/mfa/verify`

MFA 二次验证。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| temp_token | string | ✅ | 登录返回的临时 Token |
| mfa_code | string | ✅ | MFA 验证码 |

**Response:**
```json
{
  "token": "eyJhbGciOiJSUzI1NiIs...",
  "token_type": "Bearer"
}
```

#### POST `/merchant/auth/refresh`

刷新 Token。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| token | string | ✅ | 当前 Token |

**Response:**
```json
{
  "token": "new_token_xxx"
}
```

#### POST `/merchant/auth/logout`

登出。

**Response:**
```json
{
  "message": "已登出"
}
```

#### GET `/merchant/auth/me`

获取当前登录账号信息。

**Response:**
```json
{
  "admin_id": "a1b2c3d4e5f67890abcdef1234567890"
}
```

---

### 4.2 入驻管理

#### POST `/merchant/merchant/apply`

提交商户入驻申请。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| business_name | string | ✅ | 店铺名称 |
| business_license_url | string | ✅ | 营业执照图片链接 |
| id_card_front_url | string | ✅ | 身份证正面照 |
| id_card_back_url | string | ✅ | 身份证反面照 |
| contact_name | string | ✅ | 联系人 |
| contact_phone | string | ✅ | 联系电话 |
| contact_email | string | ✅ | 联系邮箱 |
| settlement_bank | string | ✅ | 结算银行名称 |
| settlement_account | string | ✅ | 结算账号 |
| settlement_account_name | string | ✅ | 开户名 |
| bank_code | string | ❌ | 银行代码 |

**Response:**
```json
{
  "onboarding_id": "onb_xxx",
  "merchant_id": null,
  "business_name": "张三数码店",
  "status": "submitted",
  "submitted_at": "2025-01-01T00:00:00+08:00"
}
```

#### GET `/merchant/merchant/onboarding`

查询入驻审核进度。

**Response:**
```json
{
  "onboarding_id": "onb_xxx",
  "merchant_id": null,
  "business_name": "张三数码店",
  "status": "submitted",
  "rejection_reason": null,
  "submitted_at": "2025-01-01T00:00:00+08:00",
  "reviewed_at": null
}
```

**status 说明：**

| 状态 | 说明 |
|------|------|
| `submitted` | 已提交，待审核 |
| `under_review` | 审核中 |
| `approved` | 审核通过，`merchant_id` 已生成 |
| `rejected` | 审核驳回，查看 `rejection_reason` |

---

### 4.3 商品管理

#### GET `/merchant/products`

获取商品列表。

**Query Parameters:**

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| offset | int | 0 | 偏移量 |
| limit | int | 20 | 每页数量 |
| status | string | - | 筛选：`all` / `pending` / `approved` / `rejected` / `published` / `unpublished` |

**Response:**
```json
{
  "data": [
    {
      "product_id": "prod_xxx",
      "name": "iPhone 15 Pro Max",
      "price": 9999.00,
      "status": "pending",
      "created_at": "2025-01-01T00:00:00+08:00"
    }
  ],
  "total": 1
}
```

#### POST `/merchant/products`

创建商品。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | ✅ | 商品名称 |
| price | float | ✅ | 价格，必须大于 0 |
| description | string | ❌ | 商品描述 |
| currency | string | ❌ | 币种，默认 CNY |
| stock | int | ❌ | 库存，-1 表示不限 |
| images | array[string] | ❌ | 图片 URL 列表 |
| category | string | ❌ | 分类 |
| tags | array[string] | ❌ | 标签 |
| sku | string | ❌ | SKU 编码 |
| attributes | object | ❌ | 自定义属性 |

**Response (201 Created):** 完整的商品对象。

#### GET `/merchant/products/{id}`

获取商品详情。

**Response:** 商品对象。

#### PUT `/merchant/products/{id}`

编辑商品（全量更新）。

**Request Body:** 同创建商品。

**Response:** 更新后的商品对象。

#### DELETE `/merchant/products/{id}`

删除商品。

**Response:**
```json
{
  "message": "商品已删除"
}
```

#### POST `/merchant/products/{id}/publish`

上架商品（需审核通过后操作）。

**Response:**
```json
{
  "message": "商品已上架"
}
```

#### POST `/merchant/products/{id}/unpublish`

下架商品。

**Response:**
```json
{
  "message": "商品已下架"
}
```

**商品状态流转：**

```text
创建 → pending（待审核）→ approved（已通过）→ published（已上架）
                            ↘ rejected（已驳回）
published → unpublish（下架）→ publish（重新上架）
```

---

### 4.4 订单管理

#### GET `/merchant/orders`

获取订单列表。

**Query Parameters:**

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| offset | int | 0 | 偏移量 |
| limit | int | 20 | 每页数量 |
| status | string | - | 筛选：`created` / `pending` / `paid` / `fulfilled` / `completed` / `cancelled` / `refunded` |

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "order_no": "ord_xxx",
      "product_name": "iPhone 15 Pro Max",
      "quantity": 1,
      "total_amount": 9999.00,
      "paid_amount": 9999.00,
      "status": "paid",
      "payment_channel": "sand",
      "paid_at": "2025-01-01T00:30:00+08:00",
      "contact_phone": "138xxxxxxxx",
      "contact_address": "收货地址",
      "remark": "请尽快发货",
      "created_at": "2025-01-01T00:00:00+08:00"
    }
  ],
  "total": 1
}
```

#### GET `/merchant/orders/{id}`

获取订单详情。

**Response:** 完整订单对象。

#### POST `/merchant/orders/{id}/fulfill`

确认履约（发货或提供服务后操作）。

**Response:**
```json
{
  "message": "订单已履约"
}
```

**订单状态流转：**

```text
created → pending → paid → fulfilled → completed
                                       ↘ refunded
created/cancelled
pending/cancelled
```

| 状态 | 含义 | 商户操作 |
|------|------|----------|
| `created` | 已创建，等待支付 | 等待 |
| `pending` | 支付中 | 等待 |
| `paid` | 已付款，待处理 | 确认履约 |
| `fulfilled` | 已履约 | 等待系统完成 |
| `completed` | 已完成 | 交易结束 |
| `cancelled` | 已取消 | - |
| `refunded` | 已退款 | - |

---

### 4.5 财务管理

#### GET `/merchant/settlements`

分账记录列表。

**Query Parameters:** offset, limit

**Response:**
```json
{
  "data": [
    {
      "id": "a1b2c3d4e5f67890",
      "settlement_no": "stl_xxx",
      "merchant_id": "mch_xxx",
      "order_id": "ord_xxx",
      "order_amount": 9999.00,
      "platform_fee": 99.99,
      "merchant_amount": 9899.01,
      "actual_amount": 9899.01,
      "channel": "sand",
      "status": "settled",
      "created_at": "2025-01-01T00:00:00+08:00"
    }
  ],
  "total": 1
}
```

#### GET `/merchant/payments`

收款记录列表。

**Query Parameters:** offset, limit

**Response:**
```json
{
  "data": [
    {
      "id": "pay_xxx",
      "merchant_id": "mch_xxx",
      "order_id": "ord_xxx",
      "channel": "sand",
      "amount": 9999.00,
      "currency": "CNY",
      "status": "paid",
      "paid_at": "2025-01-01T00:30:00+08:00",
      "created_at": "2025-01-01T00:00:00+08:00"
    }
  ],
  "total": 1
}
```

#### GET `/merchant/refunds`

退款记录列表。

**Query Parameters:** offset, limit, status

**Response:**
```json
{
  "data": [
    {
      "id": "a1b2c3d4e5f67890",
      "refund_no": "rfd_xxx",
      "merchant_id": "mch_xxx",
      "order_id": "ord_xxx",
      "amount": 9999.00,
      "reason": "商品有问题",
      "status": "pending",
      "created_at": "2025-01-01T00:00:00+08:00"
    }
  ],
  "total": 1
}
```

#### GET `/merchant/bills/export`

账单导出。

**Response:**
```json
{
  "message": "账单导出任务已创建",
  "export_url": "/merchant/bills/export/latest.csv"
}
```

---

### 4.6 商户配置

#### GET `/merchant/config/payment`

查看支付通道配置。

**Response:**
```json
{
  "data": {
    "id": "cfg_xxx",
    "merchant_id": "mch_xxx",
    "default_pay_channel": "sand",
    "pay_channels": "[\"sand\",\"wechat\"]"
  }
}
```

#### PUT `/merchant/config/payment`

更新支付通道配置。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| default_pay_channel | string | ❌ | 默认支付通道 |
| pay_channels | array[string] | ❌ | 可用支付通道列表 |

**Response:** 更新后的配置对象。

#### GET `/merchant/config/oauth`

查看 OAuth 配置。

**Response:**
```json
{
  "data": {
    "client_id": null,
    "redirect_uris": "[\"https://agent.callback.url\"]"
  }
}
```

#### PUT `/merchant/config/oauth`

更新 OAuth 回调地址。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| redirect_uris | array[string] | ❌ | OAuth 回调 URL 列表 |

**Response:**
```json
{
  "data": {
    "redirect_uris": ["https://agent.callback.url"]
  }
}
```

#### GET `/merchant/config/api-keys`

API Key 列表。

**Response:**
```json
{
  "data": [
    {
      "key_id": "ak_xxx",
      "merchant_id": "mch_xxx",
      "name": "my-key",
      "rate_limit": 60,
      "status": true,
      "created_at": "2025-01-01T00:00:00+08:00"
    }
  ]
}
```

#### POST `/merchant/config/api-keys`

创建新的 API Key。

**Request Body:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | ✅ | API Key 名称 |

**Response (201 Created):**
```json
{
  "key_id": "ak_xxx",
  "name": "my-key",
  "api_key": "sk_live_xxxxxxxxxxxx",
  "rate_limit": 60,
  "created_at": "2025-01-01T00:00:00+08:00"
}
```

> `api_key` 明文仅在此处返回，请妥善保存。

#### DELETE `/merchant/config/api-keys/{id}`

删除 API Key。

**Response:**
```json
{
  "message": "API Key 已删除"
}
```

---

## 5. 全局模型

### 5.1 商品对象

```json
{
  "id": "uuid",
  "product_id": "prod_xxx",
  "merchant_id": "mch_xxx",
  "name": "商品名称",
  "description": "商品描述",
  "price": 99.00,
  "currency": "CNY",
  "stock": 100,
  "images": "[\"https://...\"]",
  "category": "分类",
  "tags": "[\"标签1\",\"标签2\"]",
  "sku": "SKU_CODE",
  "attributes": "{\"color\":\"red\"}",
  "status": "published",
  "created_at": "2025-01-01T00:00:00+08:00",
  "updated_at": "2025-01-01T00:00:00+08:00"
}
```

**status 枚举：** `pending` / `approved` / `rejected` / `published` / `unpublished`

### 5.2 订单对象

```json
{
  "id": "uuid",
  "order_no": "ord_xxx",
  "merchant_id": "mch_xxx",
  "user_id": "user_xxx",
  "product_id": "prod_xxx",
  "product_name": "商品名称",
  "quantity": 1,
  "unit_price": 99.00,
  "total_amount": 99.00,
  "paid_amount": 99.00,
  "currency": "CNY",
  "status": "paid",
  "payment_order_id": "pay_xxx",
  "payment_order_no": "PO20250101001",
  "payment_channel": "sand",
  "paid_at": "2025-01-01T00:30:00+08:00",
  "fulfilled_at": null,
  "fulfilled_by": "",
  "contact_phone": "138xxxxxxxx",
  "contact_address": "收货地址",
  "remark": "备注",
  "created_at": "2025-01-01T00:00:00+08:00",
  "updated_at": "2025-01-01T00:00:00+08:00"
}
```

**status 枚举：** `created` / `pending` / `paid` / `fulfilled` / `completed` / `cancelled` / `refunded`

### 5.3 商户对象

```json
{
  "id": "uuid",
  "merchant_id": "mch_xxx",
  "name": "店铺名称",
  "description": "店铺描述",
  "logo": "https://...",
  "contact_name": "联系人",
  "contact_phone": "13800138000",
  "contact_email": "email@example.com",
  "contact_address": "地址",
  "business_license": "营业执照 URL",
  "settlement_bank": "结算银行",
  "settlement_account": "结算账号",
  "status": "approved",
  "balance": 0,
  "created_at": "2025-01-01T00:00:00+08:00",
  "updated_at": "2025-01-01T00:00:00+08:00"
}
```

**status 枚举：** `pending` / `approved` / `rejected` / `disabled`

### 5.4 入驻申请对象

```json
{
  "onboarding_id": "onb_xxx",
  "merchant_id": null,
  "business_name": "店铺名称",
  "contact_name": "联系人",
  "contact_phone": "13800138000",
  "contact_email": "email@example.com",
  "business_license_url": "https://...",
  "id_card_front_url": "https://...",
  "id_card_back_url": "https://...",
  "settlement_bank": "中国工商银行",
  "settlement_account": "6222021234567890123",
  "settlement_account_name": "张三",
  "bank_code": "ICBC",
  "status": "submitted",
  "rejection_reason": null,
  "submitted_at": "2025-01-01T00:00:00+08:00",
  "reviewed_at": null
}
```

**status 枚举：** `submitted` / `under_review` / `approved` / `rejected`

---

## 6. 错误码

| HTTP 状态码 | code | 说明 |
|-----------|------|------|
| 400 | `INVALID_PARAMETER` | 请求参数校验失败 |
| 400 | `REFUND_WINDOW_EXPIRED` | 超过退款期限 |
| 401 | `UNAUTHORIZED` | 缺少认证信息 |
| 401 | `INVALID_TOKEN` | Token 无效或签名验证失败 |
| 401 | `TOKEN_EXPIRED` | Token 已过期，请重新授权 |
| 402 | `PAYMENT_REQUIRED` | 支付失败或支付方式不可用 |
| 403 | `FORBIDDEN` | 商户不可用或无权限 |
| 404 | `MERCHANT_NOT_FOUND` | 商户不存在或已禁用 |
| 404 | `PRODUCT_NOT_FOUND` | 商品不存在或已下架 |
| 404 | `ORDER_NOT_FOUND` | 订单不存在 |
| 429 | `RATE_LIMIT_EXCEEDED` | 请求频率超限 |
| 500 | `INTERNAL_ERROR` | 服务器内部错误 |

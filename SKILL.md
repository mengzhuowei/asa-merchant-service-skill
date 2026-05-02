---
name: asa-merchant-api
description: 使用 ASA Merchant Service 商户 API 完成商品浏览、下单、支付、退款、邮箱验证码登录以及商户后台管理。当用户提出电商交易流程或商户运营接口需求时使用。
---

# ASA Merchant API Skill

## 目标

将用户的业务诉求准确映射为 ASA Merchant Service API 调用步骤，并输出可直接执行的请求方案与预期响应检查点。

## 读取资料

先读取 [references/api-external.md](references/api-external.md) 作为唯一接口事实来源。

## 服务信息

- Base host: `http://192.168.6.174:8080`
- ASA 协议前缀: `/shop/{merchant_id}`
- 商户后台前缀: `/merchant`

## 鉴权规则

- try 协议无需鉴权。
- 其余 `/shop/{merchant_id}` 接口使用以下其一：
  - `Authorization: Bearer <access_token>`
  - `X-API-Key: <api_key>`
- `/merchant` 后台接口使用：
  - `Authorization: Bearer <merchant_jwt>`

## 执行流程

1. 识别用户目标属于哪类流程：连通性检测、商品浏览、下单、支付、退款、邮箱登录、后台管理。
2. 提取关键参数：`merchant_id`、`product_id`、`order_id`、`payment_order_id`、`refund_id`、分页参数等。
3. 如果缺少关键参数，先提出最小必要补充；若可推断，优先按已有上下文继续。
4. 输出请求方案时，必须包含：
   - HTTP 方法
   - 完整路径
   - 必要请求头
   - Query 或 JSON Body
   - 成功响应关键字段
5. 返回错误时，按文档错误码给出排查建议（优先鉴权、参数、资源不存在、限流）。

## 常用任务映射

### 连通性与调试

- 健康检查: `POST /shop/{merchant_id}/try/ping`
- 回显测试: `POST /shop/{merchant_id}/try/echo`
- 运行状态: `POST /shop/{merchant_id}/try/stats`

### 客户侧交易流

1. 查商品: `GET /shop/{merchant_id}/products`
2. 看详情: `GET /shop/{merchant_id}/products/{product_id}`
3. 创建订单: `POST /shop/{merchant_id}/orders`
4. 创建支付单: `POST /shop/{merchant_id}/payment/orders`
5. 查询支付状态: `GET /shop/{merchant_id}/payment/orders/{payment_order_id}`
6. 必要时取消订单: `POST /shop/{merchant_id}/orders/{order_id}/cancel`

### 退款流

1. 发起退款: `POST /shop/{merchant_id}/payment/refunds`
2. 查询退款: `GET /shop/{merchant_id}/payment/refunds/{refund_id}`

### 邮箱验证码登录流

1. 发送验证码: `POST /shop/{merchant_id}/auth/auth-email/requestEmailLoginCode`
2. 校验验证码: `POST /shop/{merchant_id}/auth/auth-email/verifyEmailLoginCode`
3. 刷新会话: `POST /shop/{merchant_id}/auth/auth-email/refreshAuthSession`
4. 获取用户信息: `GET /shop/{merchant_id}/auth/auth-email/getAuthUserInfo`
5. 登出会话: `POST /shop/{merchant_id}/auth/auth-email/logoutAuthSession`

### 商户后台流

- 认证: `/merchant/auth/*`
- 入驻: `/merchant/merchant/*`
- 商品管理: `/merchant/products*`
- 订单管理: `/merchant/orders*`
- 财务: `/merchant/settlements`、`/merchant/payments`、`/merchant/refunds`、`/merchant/bills/export`
- 配置: `/merchant/config/payment`、`/merchant/config/oauth`、`/merchant/config/api-keys`

## 输出规范

- 时间字段统一按 ISO 8601 解释。
- 列表接口统一按 `{ data, total }` 处理。
- 回答中优先给“最短可跑通路径”，再给可选扩展步骤。
- 不虚构文档未定义字段。

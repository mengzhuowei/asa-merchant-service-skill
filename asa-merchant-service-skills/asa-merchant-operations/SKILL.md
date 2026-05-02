---
name: asa-merchant-operations
description: 用于商户后台日常运营，包括商品管理、订单履约、财务查询、支付配置和 API Key 管理。当用户提到“商户运营管理”时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, product, order, finance, config]
---

# asa-merchant-operations

## 目标

覆盖商户后台高频运营动作，提供可审计、可回溯的管理流程。

## 前置条件

- 已通过 `asa-merchant-auth` 获取 JWT Token

## 能力范围

### 商品管理

- 列表：`GET /merchant/products`
- 创建：`POST /merchant/products`
- 详情：`GET /merchant/products/{id}`
- 更新：`PUT /merchant/products/{id}`
- 删除：`DELETE /merchant/products/{id}`
- 上下架：`POST /merchant/products/{id}/publish|unpublish`

### 订单管理

- 列表/详情：`GET /merchant/orders`、`GET /merchant/orders/{id}`
- 履约：`POST /merchant/orders/{id}/fulfill`

### 财务管理

- 分账：`GET /merchant/settlements`
- 收款：`GET /merchant/payments`
- 退款：`GET /merchant/refunds`
- 账单导出：`GET /merchant/bills/export`

### 配置管理

- 支付配置：`GET/PUT /merchant/config/payment`
- OAuth 配置：`GET/PUT /merchant/config/oauth`
- API Key 管理：`GET/POST/DELETE /merchant/config/api-keys`

## 执行规则

1. 所有写操作先展示变更摘要并征得确认。
2. 商品操作遵循状态流转：`pending -> approved -> published`。
3. 订单仅在 `paid` 后执行履约。
4. 创建 API Key 后立即提示用户安全保存（仅返回一次明文）。

## 失败处理

- 401/403：回到 `asa-merchant-auth`
- 404：明确对象不存在
- 429：退避重试
- 500：标记平台异常并建议稍后重试

## 运营输出模板

- `操作对象`：商品/订单/财务/配置
- `执行动作`：查询/创建/更新/删除/导出
- `结果`：成功/失败 + 关键字段
- `后续建议`：是否需要继续流程或人工处理

---
name: asa-shop-catalog-order
description: 用于 ASA shop 协议的商品浏览、商品详情、创建订单、查询订单、取消订单。当用户想“看商品”“下单”“查订单”“取消订单”时触发。
version: 1.1.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, shop, product, order]
---

# asa-shop-catalog-order

## 目标

在 `shop` 协议下完成从选品到订单生命周期管理的闭环。

## 前置条件

- 已知 `merchant_id`
- 已具备认证信息之一：
  - `Authorization: Bearer <access_token>`
  - `X-API-Key: <api_key>`
- 服务地址默认使用 `http://192.168.6.174:8080`

## 关键接口

- `GET /shop/{merchant_id}/products`
- `GET /shop/{merchant_id}/products/{product_id}`
- `POST /shop/{merchant_id}/orders`
- `GET /shop/{merchant_id}/orders/{order_id}`
- `POST /shop/{merchant_id}/orders/{order_id}/cancel`

## 执行步骤

1. 浏览商品：读取商品列表，仅面向“已上架商品”，支持 `offset/limit`，其中 `limit` 最大 100。
2. 查看详情：按 `product_id` 拉取详细信息并总结卖点、价格、库存、分类和图片。
3. 创建订单前确认：确认 `product_id`、`quantity`（最小 1）、联系方式、地址、备注。
4. 调用创建订单接口并返回 `order_id/order_no/total_amount/status`。
5. 如用户要求，查询订单状态；需要取消时，先收集取消原因，再调用取消接口。

## 字段与响应要点

- 商品详情包含 `name`、`description`、`price`、`currency`、`stock`、`images`、`category`、`sku`
- `tags` 与 `attributes` 在响应里是 JSON 字符串，必要时先解析后再总结
- 订单创建体至少需要 `product_id` 和 `quantity`
- 订单详情除基础字段外，可能包含 `paid_amount`、`paid_at`、`fulfilled_at`
- 取消订单需要请求体：`{"reason":"..."}`，不要发空 body

## 状态解释

- `created`：已创建，待支付
- `pending`：支付处理中
- `paid`：已支付
- `fulfilled`：已履约
- `completed`：已完成
- `cancelled`：已取消
- `refunded`：已退款

## 失败处理

- `INVALID_PARAMETER`：指出具体字段并引导修正
- `PRODUCT_NOT_FOUND` / `ORDER_NOT_FOUND`：提醒检查 ID
- `UNAUTHORIZED` / `TOKEN_EXPIRED`：切换到认证技能修复
- `RATE_LIMIT_EXCEEDED`：按每分钟 100 次的限流约束退避重试

## 安全要求

- 写操作前必须二次确认用户意图
- 不暴露用户手机号、地址等隐私字段到无关上下文

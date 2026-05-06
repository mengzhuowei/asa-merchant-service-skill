---
name: asa-shop-catalog-order
description: 用于 ASA shop 协议的商品浏览、商品详情、创建订单、查询订单、取消订单。当用户想"看商品""下单""查订单""取消订单"时触发。
version: 2.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, shop, product, order]
---

# asa-shop-catalog-order

## 目标

在 `shop` 协议下完成从选品到订单生命周期管理的闭环。

> **注意**：本协议下所有接口当前为 🔜 桩接口（返回 501），尚未在 Phase 1 实现。

## 前置条件

- 已知 `merchant_id`
- ASA 协议 Phase 1 无需额外鉴权
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`

## 关键接口

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/shop/{merchant_id}/products` | 🔜 桩接口 |
| GET | `/shop/{merchant_id}/products/{product_id}` | 🔜 桩接口 |
| POST | `/shop/{merchant_id}/orders` | 🔜 桩接口 |
| GET | `/shop/{merchant_id}/orders/{order_id}` | 🔜 桩接口 |
| POST | `/shop/{merchant_id}/orders/{order_id}/cancel` | 🔜 桩接口 |

## 执行步骤

1. 浏览商品：读取商品列表，仅面向"已上架商品"，支持 `page/page_size`，其中 `page_size` 默认 20，最大 100。
2. 查看详情：按 `product_id` 拉取详细信息并总结卖点、价格、库存、分类和图片。
3. 创建订单前确认：确认 `product_id`、`quantity`（最小 1）、联系方式、地址、备注。
4. 调用创建订单接口并返回 `order_id`、`total_amount`、`status`。
5. 如用户要求，查询订单状态；需要取消时，先收集取消原因，再调用取消接口。

## 字段与响应要点

- 商品详情预期包含 `product_id`、`merchant_id`、`name`、`description`、`price`、`stock`、`images`、`category`、`tags`、`sku`、`attributes`、`status`、`created_at`、`updated_at`
- `tags` 为字符串数组，`attributes` 为 JSON 对象
- 订单创建体至少需要 `product_id` 和 `quantity`
- 取消订单需要请求体：`{"reason":"..."}`，不要发空 body

## 状态说明

订单状态的具体枚举值将在该接口实现后确定（Phase 1 仅定义端点，返回 501）。

## 失败处理

- `INVALID_PARAMETER`：指出具体字段并引导修正
- `PRODUCT_NOT_FOUND` / `ORDER_NOT_FOUND`：提醒检查 ID
- `UNAUTHORIZED` / `TOKEN_EXPIRED`：切换到认证技能修复
- `RATE_LIMIT_EXCEEDED`：按每分钟 100 次的限流约束退避重试

## 安全要求

- 写操作前必须二次确认用户意图
- 不暴露用户手机号、地址等隐私字段到无关上下文

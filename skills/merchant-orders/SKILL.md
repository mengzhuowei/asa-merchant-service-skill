---
name: merchant-orders
description: 处理商户订单管理接口，包括订单列表、订单详情与履约确认。
---

# Merchant Orders Skill

当用户涉及“查询订单、查看订单详情、确认履约/发货”时使用本技能。

## 先读取

1. `skills/shared/references/input-contract.md`
2. `skills/shared/references/endpoint-map.md`
3. `skills/shared/references/error-contract.md`

## 接口范围

- `GET /merchant/orders`
- `GET /merchant/orders/{id}`
- `POST /merchant/orders/{id}/fulfill`

## 查询参数

- `offset`
- `limit`
- `status`（`created`/`pending`/`paid`/`fulfilled`/`completed`/`cancelled`/`refunded`）

## 履约建议

只有在订单已支付（通常为 `paid`）时才执行 `fulfill`，避免非法状态迁移。


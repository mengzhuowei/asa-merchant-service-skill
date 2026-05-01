---
name: merchant-products
description: 处理商户商品管理接口，包括商品列表、创建、详情、更新、删除、上架和下架。
---

# Merchant Products Skill

当用户涉及“商品增删改查、上架下架”时使用本技能。

## 先读取

1. `skills/shared/references/input-contract.md`
2. `skills/shared/references/endpoint-map.md`
3. `skills/shared/references/error-contract.md`

## 接口范围

- `GET /merchant/products`
- `POST /merchant/products`
- `GET /merchant/products/{id}`
- `PUT /merchant/products/{id}`
- `DELETE /merchant/products/{id}`
- `POST /merchant/products/{id}/publish`
- `POST /merchant/products/{id}/unpublish`

## 常用参数

- 列表查询：`offset`、`limit`、`status`
- 创建/更新：`name`、`price`、`description`、`currency`、`stock`、`images`、`category`、`tags`、`sku`、`attributes`

## 业务约束

- `price` 必须大于 0
- `stock = -1` 表示不限库存
- 上架前通常需通过审核（`approved`）


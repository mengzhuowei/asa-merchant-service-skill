---
name: merchant-finance
description: 处理商户财务相关接口，包括分账记录、收款记录、退款记录与账单导出。
---

# Merchant Finance Skill

当用户涉及“财务流水、分账、收款、退款、导出账单”时使用本技能。

## 先读取

1. `skills/shared/references/input-contract.md`
2. `skills/shared/references/endpoint-map.md`
3. `skills/shared/references/error-contract.md`

## 接口范围

- `GET /merchant/settlements`
- `GET /merchant/payments`
- `GET /merchant/refunds`
- `GET /merchant/bills/export`

## 查询参数

- 分账/收款：`offset`、`limit`
- 退款：`offset`、`limit`、`status`

## 输出建议

1. 列表接口返回 `data + total`
2. 导出接口重点返回 `export_url`


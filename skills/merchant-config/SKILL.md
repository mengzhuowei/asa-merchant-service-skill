---
name: merchant-config
description: 处理商户配置接口，包括支付配置、OAuth 配置与 API Key 管理。
---

# Merchant Config Skill

当用户涉及“支付配置、OAuth 回调地址、API Key 管理”时使用本技能。

## 先读取

1. `skills/shared/references/input-contract.md`
2. `skills/shared/references/endpoint-map.md`
3. `skills/shared/references/error-contract.md`

## 接口范围

- `GET /merchant/config/payment`
- `PUT /merchant/config/payment`
- `GET /merchant/config/oauth`
- `PUT /merchant/config/oauth`
- `GET /merchant/config/api-keys`
- `POST /merchant/config/api-keys`
- `DELETE /merchant/config/api-keys/{id}`

## 关键字段

- 支付配置：`default_pay_channel`、`pay_channels`
- OAuth 配置：`redirect_uris`
- API Key 创建：`name`

## 安全要求

- `POST /merchant/config/api-keys` 返回的 `api_key` 明文只出现一次，必须提醒调用方立即保存。


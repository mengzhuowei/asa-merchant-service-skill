---
name: merchant-onboarding
description: 处理商户入驻申请与审核进度查询，覆盖 /merchant/merchant/apply 与 /merchant/merchant/onboarding。
---

# Merchant Onboarding Skill

当用户涉及“提交入驻资料、查询入驻审核状态”时使用本技能。

## 先读取

1. `skills/shared/references/input-contract.md`
2. `skills/shared/references/endpoint-map.md`
3. `skills/shared/references/error-contract.md`

## 接口范围

- `POST /merchant/merchant/apply`
- `GET /merchant/merchant/onboarding`

## 入驻申请必填字段

- `business_name`
- `business_license_url`
- `id_card_front_url`
- `id_card_back_url`
- `contact_name`
- `contact_phone`
- `contact_email`
- `settlement_bank`
- `settlement_account`
- `settlement_account_name`

## 状态解释

- `submitted`: 已提交，待审核
- `under_review`: 审核中
- `approved`: 审核通过
- `rejected`: 审核驳回（查看 `rejection_reason`）


---
name: asa-merchant-onboarding
description: 用于商户入驻申请与审核进度查询。当用户提到“商户入驻/开店申请/审核进度”时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, onboarding]
---

# asa-merchant-onboarding

## 目标

帮助商户提交完整入驻资料并持续跟踪审核状态。

## 前置条件

- 已通过 `asa-merchant-auth` 获取后台 JWT Token

## 关键接口

- `POST /merchant/merchant/apply`
- `GET /merchant/merchant/onboarding`

## 执行步骤

1. 采集并校验入驻字段完整性。
2. 提交入驻申请并记录 `onboarding_id`。
3. 定期查询审核状态，向用户同步进度。
4. 若被驳回，展示 `rejection_reason` 并给出补充建议。

## 状态解释

- `submitted`：已提交，待审核
- `under_review`：审核中
- `approved`：通过并生成 `merchant_id`
- `rejected`：驳回，需修正后重提

## 安全要求

- 身份证、银行卡、营业执照链接属于敏感信息，最小化展示
- 不在公共频道输出完整结算账号

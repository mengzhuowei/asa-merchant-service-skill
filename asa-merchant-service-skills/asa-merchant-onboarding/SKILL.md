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

## 入驻申请字段清单（提交 `POST /merchant/merchant/apply`）

为避免 `INVALID_PARAMETER`，提交前按以下清单一次性补齐。

### 必填字段（required）

- `merchant_name`：商户名称（营业执照主体名）
- `merchant_type`：商户类型（`individual`/`enterprise`）
- `business_license_no`：统一社会信用代码或营业执照号
- `business_license_image_url`：营业执照图片 URL
- `legal_person_name`：法人姓名
- `legal_person_id_no`：法人身份证号
- `legal_person_id_front_image_url`：法人身份证人像面 URL
- `legal_person_id_back_image_url`：法人身份证国徽面 URL
- `contact_name`：联系人姓名
- `contact_phone`：联系人手机号
- `contact_email`：联系人邮箱
- `settlement_account_name`：结算户名
- `settlement_account_no`：结算银行卡号/对公账户号
- `settlement_bank_name`：开户行名称
- `settlement_bank_branch`：开户行支行信息
- `business_address`：经营地址
- `province`：省
- `city`：市
- `district`：区/县
- `business_categories`：经营类目数组（至少 1 个）

### 可选字段（optional）

- `store_name`：店铺名称（前台展示名）
- `store_logo_url`：店铺 Logo URL
- `store_description`：店铺简介
- `website_url`：官网链接
- `wechat_id`：微信号
- `tax_registration_no`：税务登记号
- `organization_code`：组织机构代码
- `business_term_start`：营业期限开始日期（`YYYY-MM-DD`）
- `business_term_end`：营业期限结束日期（`YYYY-MM-DD`，长期可传 `long_term`）
- `supplementary_material_urls`：补充资质材料 URL 数组
- `remark`：入驻备注

## 字段校验规则（提交前）

- `merchant_type=individual` 时，`business_license_no` 与 `business_license_image_url` 仍为必填，需上传营业执照后再提交。
- 手机号、邮箱、身份证号、营业执照号做基础格式校验，不通过不提交。
- `business_categories` 至少 1 项，建议不超过 5 项。
- 证照类 URL 必须可访问且为图片文件。
- 结算信息字段必须成组出现：`settlement_account_name` + `settlement_account_no` + `settlement_bank_name` + `settlement_bank_branch`。

## 告诉 Claw 的固定口径

- 先收集并回显“必填字段缺口清单”，缺 1 项都不调用 `POST /merchant/merchant/apply`。
- 发起提交前做一次“二次确认”，确认主体信息、结算信息、证照链接无误。
- 成功后必须回传：`onboarding_id`、`status`、`submitted_at`（如接口返回）。
- 审核查询时统一解释状态：`submitted`、`under_review`、`approved`、`rejected`，并在 `rejected` 时输出 `rejection_reason` 与补件建议。

## 状态解释

- `submitted`：已提交，待审核
- `under_review`：审核中
- `approved`：通过并生成 `merchant_id`
- `rejected`：驳回，需修正后重提

## 安全要求

- 身份证、银行卡、营业执照链接属于敏感信息，最小化展示
- 不在公共频道输出完整结算账号

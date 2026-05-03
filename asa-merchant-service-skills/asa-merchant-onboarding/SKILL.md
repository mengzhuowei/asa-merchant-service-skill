---
name: asa-merchant-onboarding
description: 用于商户入驻申请与审核进度查询。当用户提到“商户入驻”“开店申请”“审核进度”“补件重提”时触发。
version: 1.1.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, onboarding, apply]
---

# asa-merchant-onboarding

## 目标

帮助商户按最新 `multipart/form-data` 规范提交入驻申请，并持续跟踪审核状态。

## 前置条件

- 已通过 `asa-merchant-auth` 获取后台 JWT Token
- 服务地址默认使用 `http://192.168.6.174:8080`

## 关键接口

- `POST /merchant/merchant/apply`
- `GET /merchant/merchant/onboarding`

## 执行步骤

1. 先确认用户是“首次申请”还是“查询审核状态”。
2. 若为首次申请，逐项采集表单字段与附件文件，缺少必填项时先补齐，不直接提交。
3. 提交成功后记录并回传 `onboarding_id`、`status`、`submitted_at`、`merchant_id`。
4. 若为状态查询，解释 `submitted`、`under_review`、`approved`、`rejected` 的含义。
5. 如被驳回，必须展示 `rejection_reason`，并转成可执行的补件建议。

## 申请表单字段

接口要求 `Content-Type: multipart/form-data`，不要按 JSON 体发送。

### 必填字段

- `business_name`：店铺名称
- `contact_name`：联系人
- `contact_phone`：联系电话
- `contact_email`：联系邮箱
- `settlement_bank`：结算银行名称
- `settlement_account`：结算账号
- `settlement_account_name`：开户名

### 可选字段

- `bank_code`：银行代码
- `business_license`：营业执照图片文件
- `id_card_front`：身份证正面照文件
- `id_card_back`：身份证反面照文件

## 提交前校验

- 缺少任何必填字段时，不调用 `POST /merchant/merchant/apply`。
- 手机号、邮箱、银行账号只做基础格式校验；格式可疑时先向用户确认。
- 文件字段按“真实文件”处理，不将本地路径误当作普通字符串字段。
- 若用户未提供附件，不阻止提交，但需要明确说明这些文件在文档里是可选项。

## 状态解释

- `submitted`：已提交，待审核
- `under_review`：审核中
- `approved`：审核通过，`merchant_id` 已生成
- `rejected`：审核驳回，需查看 `rejection_reason`

## 告诉 Agent 的固定口径

- 申请前先输出“缺失字段清单”。
- 提交前做一次二次确认，重点确认店铺名称、联系人、结算信息和附件是否正确。
- 成功后优先回传 `onboarding_id`、`status`、`submitted_at`。
- 被驳回时，不只复述错误，要给出下一次重提需要补什么。

## 失败处理

- `INVALID_PARAMETER`：指出缺失或格式错误字段，优先引导补齐
- `UNAUTHORIZED` / `TOKEN_EXPIRED`：先回到 `asa-merchant-auth`
- HTTP 429：按限流规则退避重试

## 安全要求

- 身份证图片、营业执照、银行账户属于敏感材料，最小化展示
- 不在对话中完整回显结算账号

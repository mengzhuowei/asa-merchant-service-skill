---
name: asa-merchant-onboarding
description: 用于商户入驻申请与审核管理。当用户提到"商户入驻""开店申请""审核进度""商户审核"时触发。
version: 2.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, onboarding, sysadmin]
---

# asa-merchant-onboarding

## 目标

帮助商户完成入驻申请，并持续跟踪审核状态。

> **注意**：Phase 1 API 尚未提供商户自助入驻接口（`/merchant/merchant/apply` 等端点不在当前 API 文档中）。商户入驻审核功能通过运营后台 `/sysadmin` 下的接口管理。以下端点均为 🔜 桩接口（返回 501），将在后续 Phase 实现。

## 前置条件

- 已通过 `asa-merchant-auth` 获取后台 JWT Token（商户后台操作）
- 或已通过 `asa-sysadmin` 获取运营后台 JWT Token（运营审核操作）
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`

## 关键接口

### 商户自助侧（未来 Phase）

> 当前 API 文档尚未定义以下端点，以下为 Phase 规划。

| 方法 | 路径 | 状态 |
|------|------|------|
| POST | `/merchant/merchant/apply` | 🔜 待实现 |
| GET | `/merchant/merchant/onboarding` | 🔜 待实现 |

### 运营审核侧（sysadmin）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/sysadmin/merchants` | 🔜 桩接口 |
| GET | `/sysadmin/merchants/{id}` | 🔜 桩接口 |
| POST | `/sysadmin/merchants/{id}/approve` | 🔜 桩接口 |
| POST | `/sysadmin/merchants/{id}/reject` | 🔜 桩接口 |
| POST | `/sysadmin/merchants/{id}/disable` | 🔜 桩接口 |
| POST | `/sysadmin/merchants/{id}/enable` | 🔜 桩接口 |

## 执行步骤

1. 先确认用户是"首次申请"还是"查询审核状态"。
2. 首次申请当前无法通过 API 自助完成——告知用户入驻 API 正在开发中，当前需通过运营后台手动处理。
3. 若为状态查询且接口已可用，解释 `submitted`、`under_review`、`approved`、`rejected` 的含义。
4. 运营人员可通过 `asa-sysadmin` 技能执行审核操作。

## 状态解释（规划）

- `submitted`：已提交，待审核
- `under_review`：审核中
- `approved`：审核通过，`merchant_id` 已生成
- `rejected`：审核驳回，需查看 `rejection_reason`

## 失败处理

- `INVALID_PARAMETER`：指出缺失或格式错误字段，优先引导补齐
- `UNAUTHORIZED` / `TOKEN_EXPIRED`：先回到 `asa-merchant-auth` 或 `asa-sysadmin`
- HTTP 429：按限流规则退避重试

## 安全要求

- 身份证图片、营业执照、银行账户属于敏感材料，最小化展示
- 不在对话中完整回显结算账号

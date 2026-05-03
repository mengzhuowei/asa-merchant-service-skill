# ASA Merchant Service Skill

面向 **ASA Merchant Service** 的 AI Agent 技能集合项目，用于快速构建商家电商场景助手，覆盖从前台下单支付到商户后台运营的完整链路。

## 项目简介

本项目基于 `API_EXTERNAL.md`（v2.9，2026-05-01）设计，采用“一个能力一个技能模块”的方式组织，目标是让 Agent 能稳定完成：

- 接口连通性检测与调试
- 商品浏览、下单、查单、取消订单
- 支付方式查询、支付单创建、支付状态跟踪、退款
- 终端用户邮箱验证码登录与会话管理
- 商户后台登录、MFA、Token 刷新、登出
- 商户入驻申请与审核进度跟踪
- 商户日常运营管理（商品、订单、财务、配置）

当前仓库已按最新文档校正以下关键约束：

- 商户入驻使用 `multipart/form-data`，必填字段为 `business_name`、`contact_name`、`contact_phone`、`contact_email`、`settlement_bank`、`settlement_account`、`settlement_account_name`
- 入驻附件 `business_license`、`id_card_front`、`id_card_back` 为可选文件字段
- 商品列表仅返回已上架商品；分页 `limit` 最大为 `100`
- 取消订单需要显式提交 `reason`
- 退款查询接口当前至少保证返回 `refund_id`，不应臆造额外状态字段

## 技能模块

当前包含 7 个核心技能：

- `asa-api-try-protocol`：连通性检测与回显调试
- `asa-shop-catalog-order`：商品与订单全流程
- `asa-shop-payment-refund`：支付与退款流程
- `asa-shop-auth-email`：终端用户邮箱登录
- `asa-merchant-auth`：商户后台认证
- `asa-merchant-onboarding`：商户入驻与审核
- `asa-merchant-operations`：商户后台运营管理

## 推荐调用链

1. 首次接入排障：`asa-api-try-protocol` -> `asa-shop-catalog-order`
2. 购买支付流程：`asa-shop-catalog-order` -> `asa-shop-payment-refund`
3. 终端用户登录：`asa-shop-auth-email` -> `asa-shop-catalog-order`
4. 商户后台运营：`asa-merchant-auth` -> `asa-merchant-onboarding` / `asa-merchant-operations`

## 全局约定

- API 服务地址：`https://xnh4hygmay5j97sev9l3g6uxwoinf6b5vcyrt6b5we1mhr9vegv7u5ksfjg1.iepose.cn`
- ASA 协议 Base URL：`/shop/{merchant_id}`
- 商户后台 Base URL：`/merchant`
- 分页参数：`offset`（默认 0）、`limit`（默认 20，最大 100）
- 错误响应：`{"code":"ERROR_CODE","message":"错误描述"}`
- 限流策略：每分钟 100 次，遇到 `RATE_LIMIT_EXCEEDED`（HTTP 429）需退避重试
- 时间格式：ISO 8601，例如 `2025-01-01T00:00:00+08:00`
- `try` 协议无需认证，其余 ASA 协议接口需 Bearer Token 或 API Key

## 安全与使用建议

- `merchant_id`、`token`、`api_key` 建议放入安全存储，不在对话中明文回显
- 创建订单、创建支付单、退款、删除等写操作必须二次确认
- 商户入驻材料、身份证件、银行卡信息按敏感信息最小化展示
- 遇到 `401/403` 先修复认证，再重试业务接口
- 遇到 `404` 明确提示对象不存在，并建议检查相关 ID

## OpenClaw 集成

详细说明见：

- `asa-merchant-service-skills/OPENCLAW_INTEGRATION.md`
- `asa-merchant-service-skills/OPENCLAW_SYSTEM_PROMPT_TEMPLATE.md`
- `asa-merchant-service-skills/OPENCLAW_SYSTEM_PROMPT_TEMPLATE_CUSTOMER_SERVICE.md`
- `asa-merchant-service-skills/OPENCLAW_SYSTEM_PROMPT_TEMPLATE_AFTERSALES_REFUND.md`

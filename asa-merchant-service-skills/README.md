# ASA Merchant Service Skills

基于 `API_EXTERNAL.md`（v2.9，2026-05-01）设计的一组可组合技能，用于 AI Agent 对接 ASA Merchant Service。

## 技能目录

- `asa-api-try-protocol`：连通性检测与回显调试
- `asa-shop-catalog-order`：商品浏览、下单、查单、取消订单
- `asa-shop-payment-refund`：支付方式查询、支付单创建、支付状态跟踪、退款
- `asa-shop-auth-email`：终端用户邮箱验证码登录会话
- `asa-merchant-auth`：商户后台登录、MFA、刷新、登出
- `asa-merchant-onboarding`：商户入驻申请与进度跟踪
- `asa-merchant-operations`：商品、订单、财务、配置管理

## 推荐调用链

1. 用户首次接入：`asa-api-try-protocol` -> `asa-shop-catalog-order`
2. 发起购买支付：`asa-shop-catalog-order` -> `asa-shop-payment-refund`
3. 终端用户邮箱登录：`asa-shop-auth-email` -> `asa-shop-catalog-order`
4. 商户后台运营：`asa-merchant-auth` -> `asa-merchant-onboarding` / `asa-merchant-operations`

## 全局约定

- API 服务地址：`http://192.168.6.174:8080`
- ASA 协议 Base URL：`/shop/{merchant_id}`
- 商户后台 Base URL：`/merchant`
- 列表分页：`offset`（默认 0），`limit`（默认 20，最大 100）
- 错误响应：`{"code":"ERROR_CODE","message":"错误描述"}`
- 限流：每分钟 100 次，遇到 `RATE_LIMIT_EXCEEDED`（HTTP 429）需退避重试

## 落地建议

- 把 `merchant_id`、`token`、`api_key` 放到安全存储，不在对话中明文回显
- 对写操作（创建订单、创建支付单、退款等）必须向用户做二次确认
- 对 `401/403` 先做认证修复，再重试业务接口
- 对 `404` 明确告知对象不存在，并建议用户检查 ID


## OpenClaw 接入

- 详见 OPENCLAW_INTEGRATION.md（OpenClaw 风格安装与编排指南）


## 系统提示词模板

- 详见 OPENCLAW_SYSTEM_PROMPT_TEMPLATE.md（可直接复制到 OpenClaw）


- 详见 OPENCLAW_SYSTEM_PROMPT_TEMPLATE_CUSTOMER_SERVICE.md（客服助手语气版）


- 详见 OPENCLAW_SYSTEM_PROMPT_TEMPLATE_AFTERSALES_REFUND.md（售后退款专用）


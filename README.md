# ASA Merchant Service Skill

面向 **ASA Merchant Service** 的 AI Agent 技能集合项目，用于快速构建商家电商场景助手，覆盖从前台下单支付到商户后台运营的完整链路。

## 项目简介

本项目基于 [ASA Merchant Service API v0.1.0](E:\code\asa-merchant-service\API.md) 设计，采用"一个能力一个技能模块"的方式组织，目标是让 Agent 能稳定完成：

- 服务健康检查与就绪探测
- 接口连通性检测与调试
- 商品浏览、下单、查单、取消订单（🔜 桩）
- 支付方式查询、支付单创建、支付状态跟踪、退款（🔜 桩）
- 终端用户邮箱验证码登录与会话管理（🔜 桩）
- 商户后台登录、Token 刷新、登出
- 商户入驻申请与审核进度跟踪
- 商品管理（增删改查、上下架）
- 图片上传（单张/批量）
- Webhook 回调接收
- 运营后台管理

当前仓库已按 API v0.1.0 规范校正，关键约束：

- 商品 CRUD 使用 `application/json`，不要误发为 `multipart/form-data`
- 商品状态：`1` = 上架，`0` = 下架
- 分页使用 `page`/`page_size`，`page_size` 默认 20，最大 100
- 图片上传限制：最大 10MB，支持 jpg/jpeg/png/gif/webp/bmp/svg，批量最多 9 张
- ASA shop/payment/auth-email 协议均为 🔜 桩接口（返回 501）

## 技能模块

当前包含 11 个技能：

| 技能 | 状态 | 说明 |
|------|------|------|
| `asa-service-health` | ✅ | 健康检查与就绪探测 |
| `asa-api-try-protocol` | ✅ | 连通性检测与回显调试 |
| `asa-shop-catalog-order` | 🔜 | 商品与订单全流程 |
| `asa-shop-payment-refund` | 🔜 | 支付与退款流程 |
| `asa-shop-auth-email` | 🔜 | 终端用户邮箱登录 |
| `asa-merchant-auth` | ✅ | 商户后台认证（login/logout/me/refresh） |
| `asa-merchant-onboarding` | 🔜 | 商户入驻与审核（未来 Phase） |
| `asa-merchant-upload` | ✅ | 图片上传（单张/批量） |
| `asa-merchant-operations` | 混合 | 商品管理 ✅ / 订单·财务·配置 🔜 |
| `asa-webhook` | ✅ | Webhook 回调接收 |
| `asa-sysadmin` | 混合 | 运营登录 ✅ / 管理接口 🔜 |

## 推荐调用链

1. 健康检查：`asa-service-health`
2. 首次接入排障：`asa-api-try-protocol` -> `asa-shop-catalog-order`
3. 购买支付流程：`asa-shop-catalog-order` -> `asa-shop-payment-refund`
4. 终端用户登录：`asa-shop-auth-email` -> `asa-shop-catalog-order`
5. 商户后台运营：`asa-merchant-auth` -> `asa-merchant-upload` / `asa-merchant-operations`
6. 平台运营管理：`asa-sysadmin` -> 各管理模块

## 全局约定

- API 服务地址：`https://himall.dihub.cn/api/merchant`
- ASA 协议 Base URL：`/shop/{merchant_id}`
- 商户后台 Base URL：`/merchant`
- 运营后台 Base URL：`/sysadmin`
- Webhook Base URL：`/webhooks`
- 分页参数：`page`（默认 1）、`page_size`（默认 20，最大 100）
- 限流策略：每分钟 100 次，遇到 `RATE_LIMIT_EXCEEDED`（HTTP 429）需退避重试
- 鉴权：商户后台/运营后台使用 JWT Bearer Token，ASA 协议 Phase 1 无需鉴权
- 错误响应：`{"code":"ERROR_CODE","message":"错误描述"}`

## 安全与使用建议

- `merchant_id`、`token`、`api_key` 建议放入安全存储，不在对话中明文回显
- 创建订单、创建支付单、退款、删除等写操作必须二次确认
- 身份证件、银行卡信息、结算账号按敏感信息最小化展示
- 遇到 `401/403` 先修复认证，再重试业务接口
- 遇到 `404` 明确提示对象不存在，并建议检查相关 ID

## OpenClaw 集成

详细说明见：

- `asa-merchant-service-skills/OPENCLAW_INTEGRATION.md`
- `asa-merchant-service-skills/OPENCLAW_SYSTEM_PROMPT_TEMPLATE.md`
- `asa-merchant-service-skills/OPENCLAW_SYSTEM_PROMPT_TEMPLATE_CUSTOMER_SERVICE.md`
- `asa-merchant-service-skills/OPENCLAW_SYSTEM_PROMPT_TEMPLATE_AFTERSALES_REFUND.md`

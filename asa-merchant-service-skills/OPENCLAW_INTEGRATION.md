# OpenClaw 集成指南

本文档提供 `asa-merchant-service-skills` 在 OpenClaw 风格环境中的接入方式。

## 1) 目录结构（OpenClaw 风格）

建议在 OpenClaw skills 目录下保持“每个技能一个目录 + `SKILL.md`”的结构：

```text
~/.openclaw/workspace/skills/
  asa-api-try-protocol/
    SKILL.md
  asa-shop-catalog-order/
    SKILL.md
  asa-shop-payment-refund/
    SKILL.md
  asa-shop-auth-email/
    SKILL.md
  asa-merchant-auth/
    SKILL.md
  asa-merchant-onboarding/
    SKILL.md
  asa-merchant-operations/
    SKILL.md
```

## 2) 安装方式

### 方式 A：手动复制（推荐）

把本仓库目录下的这些技能目录复制到 OpenClaw skills 目录：

- `asa-api-try-protocol`
- `asa-shop-catalog-order`
- `asa-shop-payment-refund`
- `asa-shop-auth-email`
- `asa-merchant-auth`
- `asa-merchant-onboarding`
- `asa-merchant-operations`

源目录：

`E:/code/asa-merchant-service-skill/asa-merchant-service-skills/`

### 方式 B：按需安装单个技能

如果你只需要前台下单支付链路，可只安装：

- `asa-shop-catalog-order`
- `asa-shop-payment-refund`

如果你只做商户后台运营，可只安装：

- `asa-merchant-auth`
- `asa-merchant-onboarding`
- `asa-merchant-operations`

## 3) 运行前配置

在 Agent 运行配置中准备以下信息：

- `ASA_BASE_URL`：`http://192.168.6.174:8080`
- `merchant_id`：目标商户 ID
- 认证头之一：
  - `Authorization: Bearer <access_token>`
  - `X-API-Key: <api_key>`
- 商户后台管理场景需要 JWT：`Authorization: Bearer <merchant_jwt>`

建议：

- 凭证走密钥管理或安全变量，不放到普通对话文本。
- 写操作启用“二次确认”，例如创建订单、创建支付单、退款、删除商品等。

## 4) 推荐触发词（OpenClaw 风格）

你可以把这些短语加入 OpenClaw 的技能触发提示：

- `asa-api-try-protocol`：`连通性检测`、`ping`、`接口可用吗`、`回显测试`
- `asa-shop-catalog-order`：`看商品`、`商品详情`、`下单`、`查订单`、`取消订单`
- `asa-shop-payment-refund`：`发起支付`、`查支付状态`、`关闭支付单`、`申请退款`
- `asa-shop-auth-email`：`邮箱验证码登录`、`刷新会话`、`退出登录`
- `asa-merchant-auth`：`商户后台登录`、`MFA验证`、`刷新后台token`
- `asa-merchant-onboarding`：`提交入驻`、`查入驻审核`
- `asa-merchant-operations`：`商品管理`、`订单履约`、`财务查询`、`API Key管理`

## 5) 编排链路（推荐）

### 前台购买链路

1. `asa-api-try-protocol`：先做 ping/echo 排查联通性
2. `asa-shop-catalog-order`：商品浏览 -> 创建订单
3. `asa-shop-payment-refund`：创建支付单 -> 轮询支付状态
4. 支付异常时继续在 `asa-shop-payment-refund` 处理关闭/退款

### 终端用户登录链路

1. `asa-shop-auth-email` 请求邮箱验证码
2. `asa-shop-auth-email` 校验验证码拿会话 token
3. 继续调用 `asa-shop-catalog-order` / `asa-shop-payment-refund`

### 商户运营链路

1. `asa-merchant-auth`：登录/MFA
2. `asa-merchant-onboarding`：提交入驻或查审核
3. `asa-merchant-operations`：商品、订单、财务、配置日常管理

## 6) 最小可运行验收

建议按下面顺序做一次 smoke test：

1. `POST /shop/{merchant_id}/try/ping` 成功返回 `status=ok`
2. `GET /shop/{merchant_id}/products` 能拿到列表
3. 创建一笔测试订单（小金额）
4. 创建支付单并查询状态
5. 商户后台登录后查询 `GET /merchant/auth/me`

通过以上 5 步，可认为 OpenClaw 接入基本可用。

## 7) 故障排查

- `401/INVALID_TOKEN/TOKEN_EXPIRED`：先修复认证，再重试业务接口
- `403/FORBIDDEN`：检查商户状态和权限
- `404/*_NOT_FOUND`：检查 `merchant_id`、`product_id`、`order_id`
- `429/RATE_LIMIT_EXCEEDED`：做退避重试，避免并发突刺
- `500/INTERNAL_ERROR`：标记平台异常，建议稍后再试

## 8) 安全基线

- 不输出完整 `token`、`api_key`、结算账号等敏感信息
- 写操作必须二次确认
- 仅在必要范围暴露用户手机号、地址、证件图片链接
- 禁止伪造接口成功结果

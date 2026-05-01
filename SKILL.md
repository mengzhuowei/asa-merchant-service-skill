---
name: asa-merchant-service
description: 用于调用 ASA Merchant Service 的商户后台 API（/merchant），覆盖认证、入驻、商品、订单、财务、配置。用户提出商户运营后台操作时触发。
---

# ASA Merchant Service Skill

本技能是商户后台 API 的总入口，面向“我要在商户后台做某个操作”的请求。

## 适用范围

- 认证与会话：`/merchant/auth/*`
- 入驻流程：`/merchant/merchant/*`
- 商品管理：`/merchant/products*`
- 订单管理：`/merchant/orders*`
- 财务管理：`/merchant/settlements`、`/merchant/payments`、`/merchant/refunds`、`/merchant/bills/export`
- 商户配置：`/merchant/config/*`

## 先读取的参考文档

1. `skills/shared/references/input-contract.md`
2. `skills/shared/references/endpoint-map.md`
3. `skills/shared/references/error-contract.md`
4. `skills/shared/references/merchant-facing-messages.md`

## 调用工作流

1. 先补齐输入契约：`base_url`、认证信息、业务参数。
2. 根据用户意图在 endpoint map 里定位唯一接口。
3. 组装请求：`method + path + headers + query + body`。
4. 发起调用；若当前运行环境无法发起 HTTP 请求，则返回可直接执行的请求规格。
5. 用统一响应格式返回结果，并在失败时给出下一步建议。

## 输出格式

始终返回结构化结果：

```json
{
  "request": {
    "method": "GET|POST|PUT|DELETE",
    "url": "完整 URL",
    "headers": {},
    "query": {},
    "body": {}
  },
  "response": {
    "status": 200,
    "data": {}
  },
  "next_action": "可选，给用户下一步操作建议"
}
```

## 面向商户的回复规范

- 返回结果给商户时，优先使用 `skills/shared/references/merchant-facing-messages.md` 的模板。
- 不展示命令、脚本名、目录、Token、环境变量等技术细节。
- 每次成功响应尽量附一条“下一步可直接说什么”的引导语。

## 子技能路由

- 认证相关优先使用：`skills/merchant-auth/SKILL.md`
- 入驻相关优先使用：`skills/merchant-onboarding/SKILL.md`
- 商品相关优先使用：`skills/merchant-products/SKILL.md`
- 订单相关优先使用：`skills/merchant-orders/SKILL.md`
- 财务相关优先使用：`skills/merchant-finance/SKILL.md`
- 配置相关优先使用：`skills/merchant-config/SKILL.md`

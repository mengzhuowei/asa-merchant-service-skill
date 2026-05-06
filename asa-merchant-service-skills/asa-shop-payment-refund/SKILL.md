---
name: asa-shop-payment-refund
description: 用于 ASA payment 协议的支付方式获取、支付单创建、支付状态查询、关闭支付单、退款申请与退款查询。当用户提到"支付""支付单""退款"时触发。
version: 2.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, payment, refund]
---

# asa-shop-payment-refund

## 目标

建立稳定的支付执行与退款处理流程，并对支付状态做可追踪反馈。

> **注意**：本协议下所有接口当前为 🔜 桩接口（返回 501），尚未在 Phase 1 实现。

## 前置条件

- 已知 `merchant_id`
- ASA 协议 Phase 1 无需额外鉴权
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`

## 关键接口

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/shop/{merchant_id}/payment/methods` | 🔜 桩接口 |
| POST | `/shop/{merchant_id}/payment/orders` | 🔜 桩接口 |
| GET | `/shop/{merchant_id}/payment/orders/{payment_order_id}` | 🔜 桩接口 |
| POST | `/shop/{merchant_id}/payment/orders/{payment_order_id}/close` | 🔜 桩接口 |
| POST | `/shop/{merchant_id}/payment/refunds` | 🔜 桩接口 |
| GET | `/shop/{merchant_id}/payment/refunds/{refund_id}` | 🔜 桩接口 |

## 执行步骤

1. 获取支付方式并给出渠道建议。
2. 创建支付单时确认 `order_id` 与 `channel`，并返回 `payment_order_id`、金额、状态。
3. 根据用户指令轮询支付状态，直到成功、失败或超时。
4. 超时或用户放弃时，可关闭支付单。
5. 需要退款时，采集 `order_id`、`amount`、`reason`，创建退款申请并跟踪状态。

## 输出模板

- `支付方式`：可用渠道列表
- `支付单`：ID、金额、状态、更新时间
- `退款单`：申请结果、退款单号、当前状态
- `结论`：是否建议继续支付/关闭支付单/人工介入

## 失败处理

- `PAYMENT_REQUIRED`：提示切换支付方式或重试
- `REFUND_WINDOW_EXPIRED`：明确超出退款时限
- `RATE_LIMIT_EXCEEDED`：限流退避
- `UNAUTHORIZED` / `TOKEN_EXPIRED`：切换到认证技能修复

## 安全要求

- 不记录 API Key 和 Token
- 退款属于高风险写操作，必须显式确认
- 不把支付状态"推断成成功"，除非查询接口已明确返回成功态

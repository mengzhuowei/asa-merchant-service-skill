---
name: asa-shop-payment-refund
description: 用于 ASA payment 协议的支付方式获取、支付单创建、支付状态查询、关闭支付单、退款申请与退款查询。当用户提到“支付”“支付单”“退款”时触发。
version: 1.1.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, payment, refund]
---

# asa-shop-payment-refund

## 目标

建立稳定的支付执行与退款处理流程，并对支付状态做可追踪反馈。

## 前置条件

- 已知 `merchant_id`
- 已有 `order_id`（创建支付单时必需）
- 已具备 OAuth Token 或 API Key
- 服务地址默认使用 `http://192.168.6.174:8080`

## 关键接口

- `GET /shop/{merchant_id}/payment/methods`
- `POST /shop/{merchant_id}/payment/orders`
- `GET /shop/{merchant_id}/payment/orders/{payment_order_id}`
- `POST /shop/{merchant_id}/payment/orders/{payment_order_id}/close`
- `POST /shop/{merchant_id}/payment/refunds`
- `GET /shop/{merchant_id}/payment/refunds/{refund_id}`

## 执行步骤

1. 获取支付方式并给出渠道建议（`sand`/`wechat`/`alipay`）。
2. 创建支付单时必须确认 `order_id` 与 `channel`，并返回 `payment_order_id`、金额、状态。
3. 根据用户指令轮询支付状态，直到成功、失败或超时。
4. 超时或用户放弃时，可关闭支付单。
5. 需要退款时，采集 `order_id`、`amount`、`reason`，创建退款申请并跟踪状态。

## 字段与响应要点

- 支付方式接口返回 `channel`、`name`、`type`
- 创建支付单的 `channel` 仅使用文档列出的 `sand`、`wechat`、`alipay`
- 支付单创建成功默认返回 `201 Created`，初始状态通常为 `pending`
- 退款查询接口当前示例只保证返回 `refund_id`，不要臆造更多状态字段

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
- 不把支付状态“推断成成功”，除非查询接口已明确返回成功态

---
name: asa-webhook
description: 用于接收支付平台和配送平台推送的回调通知。当用户提到"webhook""回调""支付回调""订单回调"时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, webhook, callback, payment, order]
---

# asa-webhook

## 目标

处理外部平台（支付通道、配送平台）推送的异步回调通知，确保订单和支付状态及时同步。

## Base URL

- `/webhooks`
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`
- 无需鉴权（内部回调）

## 关键接口

| 方法 | 路径 | 状态 |
|------|------|------|
| POST | `/webhooks/{merchant_id}/orders` | ✅ 已实现 |
| POST | `/webhooks/{merchant_id}/payments` | ✅ 已实现 |

## 执行步骤

### POST /webhooks/{merchant_id}/orders

接收支付平台/配送平台推送的订单状态变更通知。

路径参数：`merchant_id` — 商户唯一标识。

响应示例：

```json
{
  "code": 0,
  "message": "success",
  "data": { "status": "received", "message": "订单回调已接收" }
}
```

### POST /webhooks/{merchant_id}/payments

接收支付通道推送的支付结果通知。

路径参数：`merchant_id` — 商户唯一标识。

响应示例：

```json
{
  "code": 0,
  "message": "success",
  "data": { "status": "received", "message": "支付回调已接收" }
}
```

## 输出模板

- `回调类型`：订单回调 / 支付回调
- `商户`：merchant_id
- `接收状态`：received / failed
- `后续动作`：是否需要触发下游业务逻辑

## 注意事项

- 这两个接口为服务端被动接收，Agent 通常不需要主动调用
- 排查"订单或支付状态不同步"问题时，可确认 webhook 是否被正确接收
- 当前 Phase 1 接口返回固定确认响应，具体回调体结构将在后续 Phase 完善

## 失败处理

- `MERCHANT_NOT_FOUND` (404)：merchant_id 无效
- HTTP 5xx：标记平台异常，建议查看服务日志

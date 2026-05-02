---
name: asa-api-try-protocol
description: 用于 ASA 协议 try 接口的健康检查、回显调试和服务统计读取。当用户提到“连通性检测”“ping”“调试请求”时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, try, healthcheck, debug]
---

# asa-api-try-protocol

## 目标

在不依赖认证的前提下验证服务可用性，帮助 Agent 快速定位“接口不可达 / 参数传递异常 / 服务状态异常”。

## 输入

- `merchant_id`（必需）
- `echo_payload`（可选，用于 echo）
- `service_base_url`（可选，默认 `http://192.168.6.174:8080`）

## 执行步骤

1. 调用 `POST /shop/{merchant_id}/try/ping` 检查基础连通性。
2. 若用户需要参数透传验证，调用 `POST /shop/{merchant_id}/try/echo`。
3. 若用户需要服务状态，调用 `POST /shop/{merchant_id}/try/stats`。
4. 结果用结构化方式返回：接口、状态码、关键字段、结论。

## 输出模板

- `连通性`：成功/失败
- `Ping`：`status`、`timestamp`
- `Echo`：请求体与回显差异
- `Stats`：`uptime`、`version`、资源占用摘要
- `下一步建议`：若失败，提示认证/网络/merchant_id 检查路径

## 失败处理

- HTTP 404：提示 `MERCHANT_NOT_FOUND`
- HTTP 429：指数退避重试（最多 3 次）
- HTTP 5xx：报告服务异常并建议稍后重试

## 约束

- 不伪造检查结果
- 不把调试原始数据写入持久化日志（除非用户明确要求）

---
name: asa-service-health
description: 用于 ASA Merchant Service 健康检查和就绪探测。当用户提到"健康检查""服务状态""就绪检查""服务是否正常"时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, health, readiness, monitoring]
---

# asa-service-health

## 目标

提供轻量级健康检查能力，用于服务可用性探测和监控集成。

## Base URL

- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`
- 无需鉴权

## 关键接口

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/health` | ✅ 已实现 |
| GET | `/health/ready` | ✅ 已实现 |

## 执行步骤

### GET /health

检查服务基础健康状态。

响应示例：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "status": "ok",
    "version": "0.1.0",
    "timestamp": "2026-05-05T10:30:00Z"
  }
}
```

关键字段：`status`（ok/error）、`version`、`timestamp`。

### GET /health/ready

检查服务就绪状态（如数据库连接、依赖服务可达）。

响应示例：

```json
{
  "code": 0,
  "message": "success",
  "data": { "status": "ready" }
}
```

## 输出模板

- `健康状态`：ok / error
- `就绪状态`：ready / not ready
- `服务版本`：version
- `检查时间`：timestamp
- `下一步建议`：若不健康，建议检查服务日志和依赖服务状态

## 失败处理

- 连接超时：检查服务是否启动，网络是否可达
- HTTP 5xx：服务内部异常，查看服务日志
- `status != "ok"` 或 `!= "ready"`：服务可能正在启动或依赖异常

## 使用场景

- 部署后冒烟测试
- CI/CD 流水线健康检查
- 负载均衡器 / K8s 探针
- 排查 "接口不可达" 时作为第一步诊断

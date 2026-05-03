---
name: asa-merchant-operations
description: 用于商户后台日常运营，包括商品管理、订单履约，以及财务和配置类后台操作。当用户提到“商户运营管理”“商品管理”“订单履约”时触发。
version: 1.1.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, product, order, finance, config]
---

# asa-merchant-operations

## 目标

覆盖商户后台高频运营动作，提供可审计、可回溯的管理流程。

## 前置条件

- 已通过 `asa-merchant-auth` 获取 JWT Token
- 服务地址默认使用 `http://192.168.6.174:8080`

## 能力范围

### 商品管理

- 列表：`GET /merchant/products`
- 创建：`POST /merchant/products`
- 详情：`GET /merchant/products/{id}`
- 更新：`PUT /merchant/products/{id}`
- 删除：`DELETE /merchant/products/{id}`
- 上下架：`POST /merchant/products/{id}/publish|unpublish`

### 订单管理

- 列表/详情：`GET /merchant/orders`、`GET /merchant/orders/{id}`
- 履约：`POST /merchant/orders/{id}/fulfill`

### 财务管理

- 最新 API 文档包含“财务管理”章节
- 调用前先核对具体端点、查询参数和返回字段，再执行查询或导出

### 配置管理

- 最新 API 文档包含“商户配置”章节
- 调用前先核对具体端点和字段，再执行读写操作

## 执行规则

1. 所有写操作先展示变更摘要并征得确认。
2. 商品操作遵循状态流转：`pending -> approved -> published`。
3. 订单仅在 `paid` 后执行履约。
4. 商品创建与更新使用 `multipart/form-data`，不要误发为纯 JSON。
5. 财务与配置类操作若缺少字段定义，先回查文档，不臆造请求体。

## 失败处理

- 401/403：回到 `asa-merchant-auth`
- 404：明确对象不存在
- 429：退避重试
- 500：标记平台异常并建议稍后重试

## 运营输出模板

- `操作对象`：商品/订单/财务/配置
- `执行动作`：查询/创建/更新/删除/导出
- `结果`：成功/失败 + 关键字段
- `后续建议`：是否需要继续流程或人工处理

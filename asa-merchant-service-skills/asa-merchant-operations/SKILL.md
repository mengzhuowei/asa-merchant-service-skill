---
name: asa-merchant-operations
description: 用于商户后台日常运营，包括商品管理、图片上传，以及订单、财务和配置类后台操作。当用户提到"商户运营管理""商品管理""订单履约"时触发。
version: 2.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, product, order, finance, config]
---

# asa-merchant-operations

## 目标

覆盖商户后台高频运营动作，提供可审计、可回溯的管理流程。

## 前置条件

- 已通过 `asa-merchant-auth` 获取 JWT Token
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`

## 能力范围

### 商品管理（✅ 全部已实现）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/merchant/products` | ✅ 已实现 |
| POST | `/merchant/products` | ✅ 已实现 |
| GET | `/merchant/products/{id}` | ✅ 已实现 |
| PUT | `/merchant/products/{id}` | ✅ 已实现 |
| DELETE | `/merchant/products/{id}` | ✅ 已实现 |
| POST | `/merchant/products/{id}/publish` | ✅ 已实现 |
| POST | `/merchant/products/{id}/unpublish` | ✅ 已实现 |

商品状态：`1` = 上架，`0` = 下架。

### 图片上传（✅ 全部已实现）

详见独立技能 `asa-merchant-upload`。

### 订单管理（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/merchant/orders` | 🔜 桩接口 |
| GET | `/merchant/orders/{id}` | 🔜 桩接口 |
| POST | `/merchant/orders/{id}/fulfill` | 🔜 桩接口 |

### 财务管理（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/merchant/settlements` | 🔜 桩接口 |
| GET | `/merchant/payments` | 🔜 桩接口 |
| GET | `/merchant/refunds` | 🔜 桩接口 |
| GET | `/merchant/bills/export` | 🔜 桩接口 |

### 配置管理（🔜 桩接口）

| 方法 | 路径 | 状态 |
|------|------|------|
| GET | `/merchant/config/payment` | 🔜 桩接口 |
| PUT | `/merchant/config/payment` | 🔜 桩接口 |
| GET | `/merchant/config/oauth` | 🔜 桩接口 |
| PUT | `/merchant/config/oauth` | 🔜 桩接口 |
| GET | `/merchant/config/api-keys` | 🔜 桩接口 |
| POST | `/merchant/config/api-keys` | 🔜 桩接口 |
| DELETE | `/merchant/config/api-keys/{id}` | 🔜 桩接口 |

## 商品管理详细规范

### GET /merchant/products

查询参数：`page`（默认 1）、`page_size`（默认 20，最大 100）、`status`（0=下架, 1=上架，不传查全部）。

`merchant_id` 从 JWT Token 中提取，只能查看本商户商品。

### POST /merchant/products

`Content-Type: application/json`。`product_id` 自动生成（`prod_` 前缀）。

请求体：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 商品名称 |
| price | number | 是 | 价格（元），必须 > 0 |
| description | string | 否 | 商品描述 |
| stock | int | 否 | 库存，默认 -1（不限量） |
| images | string[] | 否 | 图片 URL 列表，最多 9 张 |
| category | string | 否 | 商品类目 |
| tags | string[] | 否 | 搜索标签 |
| sku | string | 否 | 商户自有 SKU |
| attributes | object | 否 | 扩展属性 |

成功返回 201。

### PUT /merchant/products/{id}

所有字段可选，只传需要更新的字段。`price` 必须 > 0。

### DELETE /merchant/products/{id}

软删除。

### POST /merchant/products/{id}/publish

上架商品，status 置为 1。

### POST /merchant/products/{id}/unpublish

下架商品，status 置为 0。

## 执行规则

1. 所有写操作先展示变更摘要并征得确认。
2. 商品创建与更新使用 `application/json`，不要误发为 `multipart/form-data`。
3. 订单仅在支付完成后执行履约。
4. 财务与配置类操作当前均为桩接口（返回 501），调用前向用户说明。
5. 所有接口通过 `Authorization: Bearer <token>` 鉴权，`merchant_id` 由 JWT 自动确定。

## 失败处理

- 401/403：回到 `asa-merchant-auth`
- 404：明确对象不存在（`MERCHANT_NOT_FOUND` / `PRODUCT_NOT_FOUND` / `ORDER_NOT_FOUND`）
- 429：退避重试
- 500：标记平台异常并建议稍后重试

## 运营输出模板

- `操作对象`：商品/订单/财务/配置
- `执行动作`：查询/创建/更新/删除/导出
- `结果`：成功/失败 + 关键字段
- `后续建议`：是否需要继续流程或人工处理

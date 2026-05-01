# Merchant API Endpoint Map

Base URL: `/merchant`

## 1. 认证

| 场景 | 方法 | 路径 | 认证 |
|---|---|---|---|
| 注册商户管理员 | POST | `/merchant/auth/register` | 无 |
| 登录 | POST | `/merchant/auth/login` | 无 |
| MFA 验证 | POST | `/merchant/auth/mfa/verify` | 无 |
| 刷新 Token | POST | `/merchant/auth/refresh` | 无 |
| 登出 | POST | `/merchant/auth/logout` | 无 |
| 当前账号信息 | GET | `/merchant/auth/me` | Bearer |

## 2. 入驻

| 场景 | 方法 | 路径 | 认证 |
|---|---|---|---|
| 提交入驻申请 | POST | `/merchant/merchant/apply` | Bearer |
| 查询入驻进度 | GET | `/merchant/merchant/onboarding` | Bearer |

## 3. 商品

| 场景 | 方法 | 路径 | 认证 |
|---|---|---|---|
| 商品列表 | GET | `/merchant/products` | Bearer |
| 创建商品 | POST | `/merchant/products` | Bearer |
| 商品详情 | GET | `/merchant/products/{id}` | Bearer |
| 更新商品 | PUT | `/merchant/products/{id}` | Bearer |
| 删除商品 | DELETE | `/merchant/products/{id}` | Bearer |
| 上架商品 | POST | `/merchant/products/{id}/publish` | Bearer |
| 下架商品 | POST | `/merchant/products/{id}/unpublish` | Bearer |

## 4. 订单

| 场景 | 方法 | 路径 | 认证 |
|---|---|---|---|
| 订单列表 | GET | `/merchant/orders` | Bearer |
| 订单详情 | GET | `/merchant/orders/{id}` | Bearer |
| 履约确认 | POST | `/merchant/orders/{id}/fulfill` | Bearer |

## 5. 财务

| 场景 | 方法 | 路径 | 认证 |
|---|---|---|---|
| 分账记录 | GET | `/merchant/settlements` | Bearer |
| 收款记录 | GET | `/merchant/payments` | Bearer |
| 退款记录 | GET | `/merchant/refunds` | Bearer |
| 账单导出 | GET | `/merchant/bills/export` | Bearer |

## 6. 配置

| 场景 | 方法 | 路径 | 认证 |
|---|---|---|---|
| 查看支付配置 | GET | `/merchant/config/payment` | Bearer |
| 更新支付配置 | PUT | `/merchant/config/payment` | Bearer |
| 查看 OAuth 配置 | GET | `/merchant/config/oauth` | Bearer |
| 更新 OAuth 配置 | PUT | `/merchant/config/oauth` | Bearer |
| API Key 列表 | GET | `/merchant/config/api-keys` | Bearer |
| 创建 API Key | POST | `/merchant/config/api-keys` | Bearer |
| 删除 API Key | DELETE | `/merchant/config/api-keys/{id}` | Bearer |


# Merchant API Input Contract

本文件定义商户后台 API 调用时的标准输入。

## 1) 连接信息

```json
{
  "base_url": "http://192.168.6.174:8080",
  "api_group": "merchant"
}
```

- `base_url` 默认来自 API 文档，可被运行环境覆盖。
- 商户后台固定前缀：`/merchant`。

## 2) 认证信息

商户后台统一使用 JWT Bearer：

```json
{
  "auth": {
    "type": "bearer",
    "token": "<jwt-token>"
  }
}
```

说明：
- `POST /merchant/auth/register|login|mfa/verify|refresh|logout` 可在无 Bearer 下调用。
- 其他 `/merchant/*` 接口都需要 Bearer。

## 3) 请求参数标准结构

```json
{
  "intent": "自然语言目标，例如：创建商品",
  "path_params": {},
  "query": {},
  "body": {}
}
```

## 4) 分页约定

所有列表接口默认分页参数：

```json
{
  "offset": 0,
  "limit": 20
}
```

约束：
- `limit` 最大 100。

## 5) 时间与金额

- 时间统一 ISO 8601（示例：`2025-01-01T00:00:00+08:00`）
- 金额字段统一十进制数值（如 `9999.00`）


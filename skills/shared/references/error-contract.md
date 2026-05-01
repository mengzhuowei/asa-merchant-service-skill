# Merchant API Error Contract

所有 API 错误响应统一格式：

```json
{
  "code": "ERROR_CODE",
  "message": "错误描述"
}
```

## 常见错误码

| HTTP | code | 含义 |
|---|---|---|
| 400 | `INVALID_PARAMETER` | 参数校验失败 |
| 400 | `REFUND_WINDOW_EXPIRED` | 超过退款期限 |
| 401 | `UNAUTHORIZED` | 缺少认证信息 |
| 401 | `INVALID_TOKEN` | Token 无效或签名失败 |
| 401 | `TOKEN_EXPIRED` | Token 过期 |
| 402 | `PAYMENT_REQUIRED` | 支付失败或不可用 |
| 403 | `FORBIDDEN` | 无权限或商户不可用 |
| 404 | `MERCHANT_NOT_FOUND` | 商户不存在或已禁用 |
| 404 | `PRODUCT_NOT_FOUND` | 商品不存在或已下架 |
| 404 | `ORDER_NOT_FOUND` | 订单不存在 |
| 429 | `RATE_LIMIT_EXCEEDED` | 请求频率超限 |
| 500 | `INTERNAL_ERROR` | 服务器内部错误 |

## 处理规则

1. `401 INVALID_TOKEN|TOKEN_EXPIRED`：优先执行登录或刷新 Token。
2. `400 INVALID_PARAMETER`：返回缺失/非法字段列表并重试。
3. `404`：确认 path 参数是否正确，再提示用户资源不存在。
4. `429`：建议退避重试（例如 3-10 秒）。


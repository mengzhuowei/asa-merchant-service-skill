---
name: merchant-auth
description: 处理商户后台认证流程，包括注册、登录、MFA、刷新 Token、登出与当前账号查询。
---

# Merchant Auth Skill

当用户涉及“登录、注册、刷新 token、MFA、退出登录、查看当前账号”时使用本技能。

## 先读取

1. `skills/shared/references/input-contract.md`
2. `skills/shared/references/endpoint-map.md`
3. `skills/shared/references/error-contract.md`

## 接口范围

- `POST /merchant/auth/register`
- `POST /merchant/auth/login`
- `POST /merchant/auth/mfa/verify`
- `POST /merchant/auth/refresh`
- `POST /merchant/auth/logout`
- `GET /merchant/auth/me`

## 参数最小校验

- 注册：`username`、`password`、`merchant_name`
- 登录：`username`、`password`
- MFA：`temp_token`、`mfa_code`
- 刷新：`token`

## 执行策略

1. 先执行登录并获取 token。
2. 若返回 `mfa_required=true`，继续执行 MFA 验证并更新 token。
3. 后续调用受保护接口时统一注入 `Authorization: Bearer <token>`。
4. 若返回 `TOKEN_EXPIRED`，先执行 refresh 或重新登录。


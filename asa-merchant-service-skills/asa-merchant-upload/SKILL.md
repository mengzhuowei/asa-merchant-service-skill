---
name: asa-merchant-upload
description: 用于商户后台图片上传，支持单张和批量上传。当用户提到"上传图片""上传商品图""批量上传"时触发。
version: 1.0.0
metadata:
  author: asa-merchant-service-skill
  tags: [asa, merchant, upload, images]
---

# asa-merchant-upload

## 目标

为商户后台提供图片上传能力，支持阿里云 OSS 和本地存储自动降级。

## 前置条件

- 已通过 `asa-merchant-auth` 获取 JWT Token
- 服务地址默认使用 `https://himall.dihub.cn/api/merchant`

## 关键接口

| 方法 | 路径 | 状态 | Content-Type |
|------|------|------|------|
| POST | `/merchant/upload` | ✅ 已实现 | multipart/form-data |
| POST | `/merchant/upload/batch` | ✅ 已实现 | multipart/form-data |

## 上传限制

- 单文件最大 10MB
- 支持格式：jpg / jpeg / png / gif / webp / bmp / svg
- 文件名自动重命名为 UUID
- 批量上传最多 9 张

## 存储策略

- 配置了完整 OSS 环境变量（`OSS_ENDPOINT` + `OSS_ACCESS_KEY_ID` + `OSS_ACCESS_KEY_SECRET` + `OSS_BUCKET`）则上传至 OSS
- 否则默认保存到本地 `./uploads` 目录，通过 `/uploads/` 路径访问

## 执行步骤

### POST /merchant/upload（单张）

1. 确认文件路径和格式符合要求。
2. 以 `multipart/form-data` 发送，字段名 `file`。
3. 成功后返回 `url`、`filename`、`size`。

请求示例：

```
POST /merchant/upload
Content-Type: multipart/form-data

file: <binary>
```

成功响应：

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "url": "https://himall.dihub.cn/api/merchant/uploads/merchants/mch_demo001/2026/05/uuid.jpg",
    "filename": "uuid.jpg",
    "size": 102400
  }
}
```

### POST /merchant/upload/batch（批量）

1. 确认所有文件符合格式和大小要求，最多 9 张。
2. 以 `multipart/form-data` 发送，字段名 `files`。
3. 返回数组，每项包含 `url`、`filename`、`size`。

## 错误处理

| 错误码 | HTTP | 说明 |
|--------|------|------|
| `FILE_TOO_LARGE` | 400 | 文件大小超过 10MB |
| `INVALID_FILE_TYPE` | 400 | 文件格式不支持 |
| `UNAUTHORIZED` / `TOKEN_EXPIRED` | 401 | 回到 `asa-merchant-auth` 修复 |

## 输出模板

- `上传数量`：单张/批量 N 张
- `上传结果`：成功 M 张 / 失败 K 张
- `图片 URL`：成功上传的访问地址列表
- `失败原因`：（如有）逐条说明

## 安全要求

- 上传前校验文件格式与大小，避免无效请求
- 返回的 URL 不包含敏感凭证信息

# Alipay Payment Skills 项目分析报告

## 1. 项目概述

**Alipay Payment Skills** 是由蚂蚁集团（Alipay 官方）维护的 AI Agent 支付技能集合，专为 AI 智能体（AI Agent）提供支付宝支付能力的无缝集成。该项目采用 Apache 2.0 开源协议，目前已有 7 次提交，Star 数 7。

### 项目定位

该项目将传统的支付宝支付能力封装为 AI Agent 可调用的 Skill（技能），使 AI Agent 能够：
- 引导用户完成支付能力开通
- 处理支付宝收银台支付流程
- 支持 HTTP 402 协议实现付费资源购买
- 接收用户问题反馈

---

## 2. 项目架构

### 2.1 整体结构

```
payment-skills/
├── alipay-aipay-product-intro/     # AI 支付产品介绍技能
│   └── SKILL.md
├── alipay-authenticate-wallet/     # 钱包认证技能
│   └── SKILL.md
├── alipay-pay-for-service/         # 支付服务处理技能
│   └── SKILL.md
├── alipay-pay-for-402-service/     # HTTP 402 协议支付技能
│   └── SKILL.md
├── alipay-payment-feedback/        # 问题反馈技能
│   └── SKILL.md
├── LICENSE
├── LEGAL.md
└── README.md
```

### 2.2 技能模块说明

| 技能名称 | 功能描述 | 触发场景 |
|---------|---------|---------|
| `alipay-aipay-product-intro` | 支付宝智能体钱包/AI支付产品介绍 | 用户询问 AI 支付、智能体钱包相关问题 |
| `alipay-authenticate-wallet` | 钱包绑定、授权与管理 | 用户要求开启支付功能、检查开通状态、解绑钱包 |
| `alipay-pay-for-service` | 支付处理与状态轮询 | 收到收银台链接或用户表达支付意愿 |
| `alipay-pay-for-402-service` | HTTP 402 协议支付处理 | HTTP 请求返回 402 Payment Required |
| `alipay-payment-feedback` | 问题上报与反馈 | 支付流程失败且无法自行修复 |

---

## 3. 核心技术特点

### 3.1 Skill 标准格式

每个技能采用统一的 **SKILL.md** 格式定义，包含：

```yaml
name: 技能名称
description: 技能描述与触发条件
version: 版本号
metadata:
  author: openclaw
  requires: [npm, curl]
  bins: [alipay-bot]
  tags: [payment, alipay, 支付]
```

### 3.2 CLI 工具驱动

项目核心依赖 `@alipay/agent-payment` npm 包，提供 `alipay-bot` 命令行工具：

| 命令 | 功能 |
|-----|-----|
| `alipay-bot check-wallet` | 检查钱包开通状态 |
| `alipay-bot apply-wallet` | 申请开通支付能力 |
| `alipay-bot bind-wallet -c <授权码>` | 绑定钱包 |
| `alipay-bot close-wallet` | 关闭/解绑钱包 |
| `alipay-bot submit-payment` | 提交支付 |
| `alipay-bot query-payment-status` | 查询支付状态 |
| `alipay-bot 402-buyer-pay` | 402 协议支付 |
| `alipay-bot problem-feedback` | 问题反馈 |

### 3.3 HTTP 402 协议支持

项目实现了 **A2M 智能收协议（基于 HTTP 402 Payment Required）**：

```
请求资源 → curl https://aipayapi.alipay.com/merchant/aipay/introduce
     ↓
响应状态码判断：
  200 → 免费/已付费资源，直接展示
  402 → 付费资源，需要完成支付
  4xx/5xx → 服务异常
```

402 支付流程：
1. 提取 `Payment-Needed` 响应头
2. 保存到文件
3. 调用 `alipay-bot 402-buyer-pay` 发起支付
4. 用户完成支付后查询状态
5. 携带 paymentProof 重试原始请求
6. 发送履约回执

---

## 4. 安全机制

### 4.1 供应链安全

- **npm 包锁定**：固定版本 `@1.0.0`，禁止使用 `@latest`
- **完整性校验**：使用 SHA-512 哈希验证包完整性
  ```
  npm view @alipay/agent-payment@1.0.0 dist.integrity
  # 预期值：sha512-/Ss+hS75CLYcwC8/jOj2kXzqIoJb7oKGrsiwnqly0EWVTxzD7QY5HxmFuj4anQfHVjnoh77qc2vUYiEAj0zfCA==
  ```
- **scope 验证**：`@alipay` scope 由 Ant Group 持有，确保官方发布

### 4.2 输入安全

| 输入参数 | 安全措施 | 防护目标 |
|---------|---------|---------|
| `--payment-link` | 域名白名单校验 + 单引号包裹 | 防止 shell 注入和 URL 伪造 |
| `-p (shortUrl)` | 必须来自 CLI 返回值，禁止用户构造 | 防止参数篡改 |
| `--reason` | 单引号包裹 + 内容转义 | 防止 shell 注入 |
| `--intent-summary` | 仅接受固定字段结构化文本 | 防止数据注入 |

### 4.3 URL 安全处理

- **一次性签名 URL**：包含加密签名，具有时效性（约5分钟）
- **用户绑定**：链接与用户支付账号绑定
- **日志保护**：不将支付链接写入持久化日志
- **原样输出要求**：任何字符修改都会导致签名校验失败

### 4.4 环境变量白名单

仅允许传递以下环境变量：
- `AIPAY_OUTPUT_CHANNEL`：渠道标识
- `AIPAY_SESSION_ID`：会话唯一标识
- `AIPAY_FRAMEWORK`：调用框架名称
- `AIPAY_MODEL`：模型名称
- `AIPAY_OS`：操作系统

**禁止** 传递 API 密钥、访问令牌、数据库凭证等敏感环境变量。

---

## 5. 技能协作机制

### 5.1 技能调用链

```
alipay-aipay-product-intro
    ↓ (需要支付时)
alipay-pay-for-402-service
    ↓ (需要授权时)
alipay-authenticate-wallet
    ↓ (遇到问题时)
alipay-payment-feedback
```

### 5.2 状态流转

```
用户发起支付
    ↓
alipay-pay-for-service 检测到收银台链接
    ↓
Step 1: check-wallet 检查钱包状态
    ↓
├── 已开通已授权 → Step 2: submit-payment
├── 已申请未授权 → 调用 alipay-authenticate-wallet → 授权完成后继续
└── 未开通 → 调用 alipay-authenticate-wallet → 开通后继续

Step 2: submit-payment 提交支付
    ↓
展示支付二维码/链接给用户
    ↓
用户完成支付
    ↓
Step 3: query-payment-status 查询状态
    ↓
支付成功 → 流程结束
```

---

## 6. 环境适配

### 6.1 多渠道支持

通过 `AIPAY_OUTPUT_CHANNEL` 环境变量适配不同 IM 平台：
- `feishu`：飞书
- `discord`：Discord
- `telegram`：Telegram
- `whatsapp`：WhatsApp
- `slack`：Slack
- `webchat`：网页聊天

### 6.2 跨平台兼容

- 支持操作系统：`ios`、`android`、`linux`、`windows`、`mac`
- 支持多种 AI 框架：`openclaw`、`nanobot`

### 6.3 输出格式适配

- Markdown 文本原样输出
- 二维码图片通过 `MEDIA:` 行处理
- 链接格式根据渠道自动适配

---

## 7. 安装与部署

### 7.1 一键安装（推荐）

```bash
npx -y @alipay/agent-payment@latest install
```

### 7.2 手动安装

```bash
# 安装单个技能
cp -r alipay-authenticate-wallet ~/.openclaw/workspace/skills/

# 或安装所有技能
cp -r alipay-* ~/.openclaw/workspace/skills/
```

### 7.3 单独安装 CLI

```bash
npx -y @alipay/agent-payment@latest install-cli
```

---

## 8. 与 OpenClaw 框架集成

### 8.1 框架适配

项目针对 **OpenClaw** AI Agent 框架设计，支持：
- 自动触发：技能根据上下文自动触发
- 工具调用：通过 `exec` 工具执行 CLI 命令
- 消息整合：支持 Markdown 文本 + 图片整合输出

### 8.2 ClawHub 分发

每个技能都发布在 ClawHub 市场：
- https://clawhub.ai/alipay/alipay-aipay-product-intro
- https://clawhub.ai/alipay/alipay-authenticate-wallet
- https://clawhub.ai/alipay/alipay-pay-for-service
- https://clawhub.ai/alipay/alipay-pay-for-402-service
- https://clawhub.ai/alipay/alipay-payment-feedback

---

## 9. 设计亮点

### 9.1 模块化设计

- 每个技能职责单一，便于维护和扩展
- 技能之间通过标准接口协作
- 支持独立部署和使用

### 9.2 安全优先

- 多层安全校验机制
- 完整性校验防止供应链攻击
- 白名单机制限制危险操作
- URL 原样输出保护签名有效性

### 9.3 透明执行

- 每个步骤执行前告知用户
- 错误信息如实报告
- 不隐瞒或伪造执行结果

### 9.4 用户体验优化

- 清晰的错误处理指引
- 完善的边界条件处理
- 多渠道输出适配

---

## 10. 适用场景

| 场景 | 适用技能 |
|-----|---------|
| AI Agent 需要向用户收取费用 | `alipay-pay-for-service`、`alipay-pay-for-402-service` |
| AI Agent 需要验证用户支付能力 | `alipay-authenticate-wallet` |
| AI Agent 提供付费资源 | `alipay-aipay-product-intro` + `alipay-pay-for-402-service` |
| 用户反馈支付问题 | `alipay-payment-feedback` |

---

## 11. 总结

Alipay Payment Skills 是一个设计精良的 AI Agent 支付技能集合，具有以下特点：

1. **标准化**：采用统一的 SKILL.md 格式，易于理解和扩展
2. **安全可靠**：多层安全机制保护支付流程
3. **协作流畅**：技能之间无缝衔接
4. **适配性强**：支持多种渠道和平台
5. **官方维护**：由支付宝官方提供，长期维护保障

该项目为 AI Agent 开发者提供了便捷的支付集成方案，是 AI Agent 商业化落地的重要基础设施。
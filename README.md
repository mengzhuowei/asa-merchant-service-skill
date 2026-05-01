# ASA Merchant Service Skill

面向商户后台 API（`/merchant`）的一套标准 Skill 项目，可被 Claw/Codex 类 Agent 安装并调用。

## 项目介绍

本项目把商户后台能力拆成可复用技能，覆盖：
- 认证与会话（注册、登录、MFA、刷新、登出）
- 入驻申请与进度查询
- 商品管理（增删改查、上下架）
- 订单管理（列表、详情、履约）
- 财务管理（分账、收款、退款、账单导出）
- 商户配置（支付、OAuth、API Key）

## 目录说明

```text
.
├── SKILL.md                               # 总入口技能
├── agents/openai.yaml                     # 总技能 UI/调用元数据
├── skills/
│   ├── merchant-auth/
│   ├── merchant-onboarding/
│   ├── merchant-products/
│   ├── merchant-orders/
│   ├── merchant-finance/
│   ├── merchant-config/
│   └── shared/references/                 # 输入契约、端点映射、错误码、商户话术
└── scripts/
    ├── auto-install-from-git.ps1
    ├── auto-install-from-git.sh
    ├── install.ps1
    └── install.sh
```

## 安装命令

### 1) Windows（最简一行，推荐）

```powershell
irm "https://raw.githubusercontent.com/mengzhuowei/asa-merchant-service-skill/main/scripts/auto-install-from-git.ps1" | iex
```

说明：默认会从 `main` 分支安装 `asa-merchant-service`，并强制升级到最新版本。

### 2) Linux / macOS（最简一行，推荐）

```bash
curl -fsSL "https://raw.githubusercontent.com/mengzhuowei/asa-merchant-service-skill/main/scripts/auto-install-from-git.sh" | bash
```

说明：同样默认安装并更新到最新版本。

### 3) Windows（本地仓库安装）

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 -SkillName "asa-merchant-service" -ForceUpgrade
```

### 4) Linux / macOS（本地仓库安装）

```bash
bash ./scripts/install.sh asa-merchant-service . "" true
```

## 使用方式

安装后在 Agent 中直接调用：
- `$asa-merchant-service`（总入口）
- 或按子场景调用：`$merchant-auth`、`$merchant-products`、`$merchant-orders` 等

典型可直接说：
- 查今天订单
- 创建并上架一个商品
- 导出本月账单

## 商户端回复规范

项目内置“商户可读”话术模板，避免暴露技术细节：
- `skills/shared/references/merchant-facing-messages.md`


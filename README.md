# ASA Merchant API Skill

基于 `ASA Merchant Service` 外部接口文档构建的标准化 SKILL 项目，可用于让 AI Agent 在商户业务场景下稳定执行商品、订单、支付、退款与商户后台管理相关流程。

## 项目目标

- 提供可被 Claw 生态工具快速识别的标准技能入口。
- 将复杂 API 文档沉淀为可执行的调用流程与输出规范。
- 保持文件命名规范，避免因命名不一致导致安装器扫描失败。

## 适用场景

当用户需要以下能力时可触发本技能：

- 商品浏览与详情查询
- 下单与订单状态查询
- 支付单创建、支付状态查询、关闭支付单
- 退款申请与退款状态查询
- 邮箱验证码登录流程
- 商户后台（认证、入驻、商品、订单、财务、配置）接口调用

## 项目结构

```text
asa-merchant-service-skill/
├─ SKILL.md
└─ references/
   └─ api-external.md
```

## 文件说明

- `SKILL.md`
  - 技能标准入口文件。
  - 包含 frontmatter（`name`、`description`）与执行规则。
- `references/api-external.md`
  - API 事实来源文档。
  - 技能执行时作为接口定义与字段校验依据。

## 安装与使用

1. 将本目录作为一个完整 skill 包放入 Claw 支持的 skills 目录。
2. 确保目录内存在 `SKILL.md`（安装器会优先识别该文件）。
3. 在对话中提出商户 API 相关任务，技能会按 `SKILL.md` 的流程执行。

## 技能执行原则

- 先读取 `references/api-external.md`，再生成请求方案。
- 请求方案必须包含：方法、路径、请求头、参数或请求体、关键响应字段。
- 缺少关键参数时仅补问必要信息。
- 遇到错误时按文档错误码优先排查鉴权、参数、资源状态与限流。

## 兼容性说明

本项目遵循通用 SKILL 命名约定：

- 入口文件名固定为 `SKILL.md`
- 技能名使用小写连字符（`asa-merchant-api`）
- 引用文档采用小写连字符命名（`api-external.md`）

可兼容主流 Claw 系工具（如 OpenClaw、Qclaw）对标准 Skill 包的扫描与安装。

## 后续维护建议

- 接口变更后，仅更新 `references/api-external.md` 与 `SKILL.md` 的流程映射。
- 保持文件命名规则不变，避免引入大写下划线风格命名。
- 增加新接口时，优先补充“任务映射”与“关键响应字段”。

# ASA Merchant Service Skills Installer

这个仓库现在已经支持通过 `npx` 安装技能目录。

## 使用方式

发布到 npm 后，用户可执行：

```bash
npx -y @your-scope/asa-merchant-service-skills install
```

指定安装目录：

```bash
npx -y @your-scope/asa-merchant-service-skills install --target /path/to/skills
```

也可通过环境变量指定目录：

```bash
OPENCLAW_SKILLS_DIR=/path/to/skills npx -y @your-scope/asa-merchant-service-skills install
```

默认安装目录：

```text
~/.openclaw/workspace/skills
```

## 发布前要改的内容

1. 修改 [package.json](E:/code/asa-merchant-service-skill/package.json) 的 `name`（替换 `@your-scope/...`）。
2. 视需要修改 `license`、`version`、`description`。
3. 登录 npm 并发布：

```bash
npm publish --access public
```

## 安装逻辑说明

- CLI 会扫描 `asa-merchant-service-skills/` 下所有包含 `SKILL.md` 的子目录。
- 只安装技能目录，不会把模板文档复制到目标目录。

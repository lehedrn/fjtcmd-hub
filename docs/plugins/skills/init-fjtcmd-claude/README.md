# init-fjtcmd-claude

为 fjtcmd-hub 项目生成 CLAUDE.md 文件的 Skill。

## 使用场景

- 协作者 clone 项目后，需要根据本地环境生成 CLAUDE.md
- 项目根目录路径与模板中不一致时

## 安装

### 本项目开发者

```bash
# Linux/macOS
bash docs/plugins/skills/init-fjtcmd-claude/install.sh

# Windows
docs\plugins\skills\init-fjtcmd-claude\install.bat
```

### 外部使用者

1. 下载 `init-fjtcmd-claude` 目录
2. 复制到项目的 `.claude/skills/` 下
3. Skill 无需额外配置

## 卸载

```bash
# 本项目开发者
bash docs/plugins/skills/init-fjtcmd-claude/uninstall.sh

# 外部使用者
rm -rf .claude/skills/init-fjtcmd-claude
```

## 使用方式

```bash
# 自动检测项目根目录
/fjtcmd-hub-init-claude

# 指定项目根目录
/fjtcmd-hub-init-claude --project-root /path/to/project
```

## 生成的文件

| 文件 | 位置 | 说明 |
|------|------|------|
| CLAUDE.md | 项目根目录 | AI 行为契约文件 |

## 模板说明

模板文件 `assets/CLAUDE-TEMPLATE.md` 中包含一个占位符：

```
{{PROJECT_ROOT}}
```

执行时会自动替换为实际的项目根目录路径。

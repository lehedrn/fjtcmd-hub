# Claude Code Skills

Skill 插件集合。Skill 是扩展 Claude Code 能力的功能模块。

## 可用 Skills

| 插件 | 说明 | 用途 | 安装 |
|------|------|------|------|
| [fjtcmd-hub-dev-simple](./fjtcmd-hub-dev-simple/) | 功能开发全流程引导 | 需求分析→代码生成→部署验证 | `bash fjtcmd-hub-dev-simple/install.sh` |
| [init-fjtcmd-claude](./init-fjtcmd-claude/) | 生成 CLAUDE.md | 初始化项目 AI 行为契约 | `bash init-fjtcmd-claude/install.sh` |

## 安装方式

```bash
# 进入具体插件目录查看安装说明
cd docs/plugins/skills/{plugin-name}
cat README.md
```

## 添加新 Skill

1. 创建子目录 `docs/plugins/skills/{skill-name}/`
2. 添加 SKILL.md、README.md、install.sh、install.bat 等
3. 更新本文件的"可用 Skills"表格

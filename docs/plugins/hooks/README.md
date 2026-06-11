# Claude Code Hooks

Hook 插件集合。Hook 是在特定时机自动执行的脚本。

## 可用 Hooks

| 插件 | 说明 | 触发时机 | 安装 |
|------|------|---------|------|
| [record-history](./record-history/) | 自动记录对话历史 | `Stop` | `bash record-history/install.sh` |

## 安装方式

```bash
# 进入具体插件目录查看安装说明
cd docs/plugins/hooks/{plugin-name}
cat README.md
```

## 添加新 Hook

1. 创建子目录 `docs/plugins/hooks/{hook-name}/`
2. 添加 README.md、install.sh、install.bat 等
3. 更新本文件的"可用 Hooks"表格

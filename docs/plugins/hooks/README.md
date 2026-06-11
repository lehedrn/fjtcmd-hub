# Claude Code Hooks

本项目提供的 Claude Code Hook 插件集合。

## 可用插件

| 插件 | 说明 | 文档 |
|------|------|------|
| [Record History](./record-history.md) | 自动记录对话历史 | [查看](./record-history.md) |

## 快速安装

### Record History Hook

```bash
# 一键安装
bash docs/plugins/hooks/install-record-history.sh
```

详细安装说明请参考 [record-history.md](./record-history.md)。

## 目录结构

```
docs/plugins/hooks/
├── README.md                      # 本文件
├── record-history.md              # Record History 插件文档
├── install-record-history.sh      # 一键安装脚本
├── settings-example.json          # settings.local.json 配置示例
└── assets/
    └── record-history.js          # Hook 脚本源文件
```

## 什么是 Hook？

Hook 是 Claude Code 的事件钩子机制，可以在特定时机自动执行脚本。

### 支持的事件

| 事件 | 触发时机 |
|------|---------|
| `Stop` | Claude 完成回复后 |
| `PostToolUse` | 工具调用完成后 |
| `PreToolUse` | 工具调用前 |

### 配置位置

```
.claude/settings.local.json
```

## 手动配置

如果不使用安装脚本，可以手动配置：

1. 复制 Hook 脚本到 `.claude/hooks/`
2. 编辑 `.claude/settings.local.json` 添加 hook 配置
3. 参考 `settings-example.json` 示例

## 卸载

删除对应的 Hook 脚本和 settings 中的配置即可。

# Record History Hook

自动记录 Claude Code 对话历史到 `docs/history/{username}/` 目录。

## 安装

```bash
# Linux/macOS
bash docs/plugins/hooks/record-history/install.sh

# Windows
docs\plugins\hooks\record-history\install.bat
```

## 卸载

```bash
# Linux/macOS
bash docs/plugins/hooks/record-history/uninstall.sh

# Windows
docs\plugins\hooks\record-history\uninstall.bat
```

## 功能

- 自动记录每轮对话的用户问题和 Claude 回复
- 按用户分目录存储（`docs/history/{username}/`）
- 从 `git config user.name` 获取用户名
- 如果无法获取用户名，安装时会询问
- 自动去重（基于消息 UUID）
- 单文件最大 500 行，自动分卷

## 文件结构

```
docs/history/{username}/
├── history-20260612-1.md
├── history-20260612-2.md
└── ...
```

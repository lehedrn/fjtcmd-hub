# Claude Code Hooks

Claude Code Hook 插件集合。每个插件有独立的子目录。

## 可用插件

| 插件 | 说明 | 目录 |
|------|------|------|
| record-history | 自动记录对话历史 | [record-history/](./record-history/) |

## 安装插件

进入对应插件目录，查看 README 了解安装方式：

```bash
# 示例：安装 record-history
cd docs/plugins/hooks/record-history

# Linux/macOS
bash install.sh

# Windows
install.bat
```

## 目录结构

```
docs/plugins/hooks/
├── README.md                    # 本文件
└── record-history/              # Record History 插件
    ├── README.md                # 插件说明
    ├── install.sh               # Linux/macOS 安装脚本
    ├── install.bat              # Windows 安装脚本
    ├── uninstall.sh             # Linux/macOS 卸载脚本
    ├── uninstall.bat            # Windows 卸载脚本
    └── assets/
        └── record-history.js    # Hook 脚本
```

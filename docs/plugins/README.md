# Claude Code Plugins

Claude Code 插件集合，包括 Hooks 和 Skills 两种类型。

## 插件类型

| 类型 | 说明 | 目录 |
|------|------|------|
| Hooks | 事件钩子，自动执行脚本 | [hooks/](./hooks/) |
| Skills | 功能技能，扩展 Claude 能力 | [skills/](./skills/) |

## 目录结构

```
docs/plugins/
├── README.md              # 本文件（插件总索引）
├── hooks/                 # Hook 插件
│   ├── README.md          # Hook 插件索引
│   └── {hook-name}/       # 具体 Hook
│       └── README.md      # Hook 详细说明
└── skills/                # Skill 插件
    ├── README.md          # Skill 插件索引
    └── {skill-name}/      # 具体 Skill
        └── README.md      # Skill 详细说明
```

## 添加新插件

1. 确定插件类型（Hook 或 Skill）
2. 在对应目录下创建子目录
3. 添加 README.md、安装/卸载脚本
4. 更新对应类型的索引 README.md

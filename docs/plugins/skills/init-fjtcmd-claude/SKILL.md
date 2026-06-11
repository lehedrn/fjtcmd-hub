# init-fjtcmd-claude

生成 fjtcmd-hub 项目的 CLAUDE.md 文件。

## 功能

- 自动检测项目根目录
- 从模板生成 CLAUDE.md
- 支持自定义项目根目录路径

## 使用方式

```bash
/fjtcmd-hub-init-claude
```

或指定项目根目录：

```bash
/fjtcmd-hub-init-claude --project-root /custom/path/to/project
```

## 执行流程

1. 检测或询问项目根目录路径
2. 读取模板文件 `assets/CLAUDE-TEMPLATE.md`
3. 替换模板中的 `{{PROJECT_ROOT}}` 占位符
4. 写入 CLAUDE.md 到项目根目录
5. 确认生成结果

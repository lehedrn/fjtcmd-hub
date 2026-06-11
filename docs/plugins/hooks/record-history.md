# Record History Hook

自动记录 Claude Code 对话历史到 `docs/history/{username}/` 目录。

## 功能特性

- ✅ 自动记录每轮对话的用户问题和 Claude 回复
- ✅ 按用户分目录存储，避免多人协作冲突
- ✅ 从 `git config user.name` 获取用户名
- ✅ 自动去重（基于消息 UUID）
- ✅ 单文件最大 500 行，自动分卷

## 文件结构

```
docs/history/{username}/
├── history-20260612-1.md    # 第 1 卷
├── history-20260612-2.md    # 第 2 卷（超过 500 行时自动创建）
└── .transcript-latest.jsonl # 持久化 transcript 副本
```

## 安装方式

### 方式一：使用安装脚本（推荐）

```bash
bash docs/plugins/hooks/install-record-history.sh
```

### 方式二：手动安装

#### 1. 复制 Hook 脚本

```bash
# 确保 hooks 目录存在
mkdir -p .claude/hooks

# 复制脚本
cp docs/plugins/hooks/assets/record-history.js .claude/hooks/

# 添加执行权限
chmod +x .claude/hooks/record-history.js
```

#### 2. 配置 settings.local.json

编辑 `.claude/settings.local.json`，在 `hooks` 部分添加：

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "node .claude/hooks/record-history.js"
          }
        ]
      }
    ]
  }
}
```

> **注意**：如果 `settings.local.json` 中已有 `hooks` 配置，请合并而非覆盖。

#### 3. 创建历史目录

```bash
# 获取当前 git 用户名
USERNAME=$(git config user.name)

# 创建用户专属目录
mkdir -p docs/history/${USERNAME}
```

## 验证安装

运行以下命令检查配置：

```bash
# 检查脚本是否存在
ls -la .claude/hooks/record-history.js

# 检查 settings 配置
grep -A 10 '"Stop"' .claude/settings.local.json

# 检查历史目录
ls docs/history/
```

## 配置说明

### Hook 触发时机

| 事件 | 说明 |
|------|------|
| `Stop` | Claude 完成回复后触发 |

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `PROJECT_ROOT` | 项目根目录（可选） | 自动检测 |

### 用户名获取优先级

1. `git config user.name`
2. 环境变量 `USER`
3. 环境变量 `USERNAME`
4. 回退值 `unknown`

## 卸载

```bash
# 删除 hook 脚本
rm .claude/hooks/record-history.js

# 从 settings.local.json 中移除 Stop hook 配置

# 可选：删除历史记录
# rm -rf docs/history/
```

## 故障排查

### 问题：历史记录没有生成

**检查项**：
1. 脚本是否有执行权限：`ls -la .claude/hooks/record-history.js`
2. settings.local.json 配置是否正确
3. 查看 Claude Code 日志是否有错误

### 问题：权限错误

```bash
chmod +x .claude/hooks/record-history.js
```

### 问题：JSON 解析错误

检查 settings.local.json 格式是否正确：

```bash
cat .claude/settings.local.json | python3 -m json.tool
```

## 相关文件

| 文件 | 说明 |
|------|------|
| `.claude/hooks/record-history.js` | Hook 脚本 |
| `.claude/settings.local.json` | Hook 配置 |
| `docs/history/{username}/` | 历史记录存储目录 |

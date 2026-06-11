# fjtcmd-hub-dev-simple

fjtcmd-hub 项目功能开发全流程引导 Skill。从需求分析到代码生成、业务实现、集成部署、验证测试，一站式完成。

## 功能特性

- ✅ **标准模板**：CRUD 单表、Tree 树表、Sub 主子表（独立页面模式）
- ✅ **简单业务模板**：CRUD + 状态流转 + 业务校验 + 自定义接口
- ✅ **环境自动探测**：首次使用时自动检测数据库、端口、CLI 工具
- ✅ **配置持久化**：环境信息保存到 `config.json`，后续免重复配置
- ✅ **逻辑删除支持**：自动检测 `del_flag` 字段，生成前后端逻辑删除代码
- ✅ **TS 索引合并**：自动合并 `index-bak.ts` 到 `types/api/index.ts`
- ✅ **路由自动集成**：主子表路由自动插入 `router/index.ts`
- ✅ **模拟数据生成**：自动生成 20 条合理中文测试数据
- ✅ **curl 测试脚本**：自动生成 API 自动化测试脚本

---

## 安装

### 方式一：本项目开发者（已 clone 仓库）

直接运行安装脚本：

```bash
# Linux/macOS
bash docs/plugins/skills/fjtcmd-hub-dev-simple/install.sh

# Windows
docs\plugins\skills\fjtcmd-hub-dev-simple\install.bat
```

### 方式二：外部使用者（单独获取 Skill）

#### 步骤 1：下载 Skill 文件

从本仓库下载 `fjtcmd-hub-dev-simple` 目录，或手动复制以下文件：

```
fjtcmd-hub-dev-simple/
├── SKILL.md
├── README.md
├── QUICK_REFERENCE.md
├── CHANGELOG.md
├── config.template.json
├── assets/
├── examples/
├── references/
├── scripts/
└── tests/
```

#### 步骤 2：放置到目标项目

```bash
# 将 skill 目录复制到项目的 .claude/skills/ 下
cp -r fjtcmd-hub-dev-simple /path/to/your-project/.claude/skills/
```

#### 步骤 3：初始化配置

```bash
cd /path/to/your-project
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/verify_env.py --init
```

---

## 卸载

```bash
# 本项目开发者
bash docs/plugins/skills/fjtcmd-hub-dev-simple/uninstall.sh

# 外部使用者（手动删除）
rm -rf .claude/skills/fjtcmd-hub-dev-simple
```

---

## 使用方式

安装完成后，在 Claude Code 中调用：

```bash
# 最简调用（交互式）
/fjtcmd-hub-dev-simple 我要做一个学生管理功能

# 带参数调用
/fjtcmd-hub-dev-simple 商品管理 --module demo --business goods --template crud
```

---

## 前置要求

使用此 Skill 的项目需要满足：

| 依赖 | 说明 |
|------|------|
| Python 3.6+ | 工具脚本运行 |
| Java 17+ | 代码生成 CLI |
| MySQL | 本地或 Docker |
| Node.js + pnpm | 前端构建 |
| fjtcmd-hub-generator-cli | 代码生成器（已编译） |

> **注意**：此 Skill 专为 fjtcmd-hub 项目设计，其他 RuoYi-Vue 项目需要调整配置。

---

## 相关文档

| 文档 | 说明 |
|------|------|
| [SKILL.md](./SKILL.md) | Skill 主入口（流程编排） |
| [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) | 快速参考卡片 |
| [CHANGELOG.md](./CHANGELOG.md) | 版本更新日志 |
| [references/](./references/) | 各阶段详细参考文档 |

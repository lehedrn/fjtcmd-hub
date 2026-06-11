---
name: fjtcmd-hub-dev-simple
version: 1.1.0
description: |
  fjtcmd-hub 项目功能开发全流程引导助手。覆盖标准模板（CRUD 单表、Tree 树表、Sub 主子表）和简单业务模板（CRUD + 状态流转 + 业务校验 + 自定义接口）。
  当用户需要开发新功能、创建新模块、做 CRUD 管理页面、写业务管理界面、生成代码、开发数据维护功能时使用此 skill。
  触发关键词：开发功能、新增模块、CRUD、数据管理、代码生成、建表、业务开发、学生管理、商品管理、订单管理、分类管理、审批流程、状态流转。
  即使用户只是说"帮我做一个XX管理功能"或"我需要管理XX数据"，也应该触发此 skill。
---

# fjtcmd-hub-dev-simple

fjtcmd-hub 项目功能开发全流程引导助手。从需求分析到代码生成、业务实现、集成部署、验证测试，一站式完成。

## 覆盖范围

| 模板类型 | 适用场景 | 代码生成 |
|---------|---------|---------|
| **标准模板 - CRUD** | 单表增删改查（学生管理、商品管理） | 完整自动生成 |
| **标准模板 - Tree** | 树形结构（部门管理、分类管理） | 完整自动生成 |
| **标准模板 - Sub** | 主子表独立页面（客户→商品） | 完整自动生成 |
| **简单业务模板** | CRUD + 状态流转 + 自定义接口（文章审核） | 生成 CRUD + TODO 标注实现 |

## 调用参数

```bash
# 自然语言（推荐）
/fjtcmd-hub-dev-simple 我要做一个学生管理功能，管理姓名、性别、年龄、生日

# 带参数
/fjtcmd-hub-dev-simple 学生管理 --module demo --business student --template crud
```

可选参数：`--module` `--business` `--template` `--target` `--doc-path` `--parent-menu` `--skip-env`

---

## 执行流程概览

**详细步骤请参考 `references/workflow.md`。**

```
Step 0  环境握手   → 检查/生成 config.json，验证 DB 连接
Step 1  需求分析   → 推断模板、字段、字典；生成 DDL + YAML + 需求文档
Step 2  代码生成   → 建表、菜单查询、CLI 生成、拷贝、TS 索引合并
Step 2b TODO实现   → （仅简单业务）标注 TODO → 逐一实现前后端
Step 3  集成部署   → 菜单 SQL、全量编译、重启服务
Step 4  验证文档   → 20条模拟数据、curl 测试、交互记录
```

每个阶段读取对应的 `references/phaseN-*.md` 获取详细指导。

---

## 工具脚本

| 脚本 | 用途 | 常用命令 |
|------|------|---------|
| `verify_env.py` | 环境验证 | `--init` / `--quick` |
| `validate_config.py` | 配置校验 | `--fix` |
| `db_executor.py` | SQL 执行 | `exec --file` / `query --sql` |
| `menu_tool.py` | 菜单管理 | `query` / `create` / `tree` |
| `copy_code.py` | 代码拷贝 | `--source` `--target-module` |
| `merge_ts_index.py` | TS 索引合并 | `--bak` `--target` |
| `merge_router.py` | 路由集成 | `--bak` `--target` |

---

## 关键规范速查

**中间目录**：`generate/{module}/{business}/`（含 DDL、YAML、output/）

**拷贝映射**：
- `output/main/java/...` → `fjtcmd-hub-{module}/src/main/java/...`
- `output/main/resources/...` → `fjtcmd-hub-{module}/src/main/resources/...`
- `output/vue/api/...` → `fjtcmd-hub-ui/src/api/...`
- `output/vue/types/api/...`（排除 index-bak.ts） → `fjtcmd-hub-ui/src/types/api/...`
- `output/vue/views/...` → `fjtcmd-hub-ui/src/views/...`

**模拟数据量**：单表/树表 20 条；主子表主 20×子 20（共 420 条）

**SQL 执行**：必须指定 `--default-character-set=utf8mb4`，使用 `db_executor.py` 自动处理

---

## 交互原则

1. **先推断 → 再询问 → 后确认**：主动推断完整设计，展示后询问修改
2. **每步确认**：每个产出物都等用户确认后再继续
3. **文件即时生成**：确认后立即写入文件
4. **命令展示再执行**：执行前展示给用户确认
5. **阶段自动流转**：完成后自动询问是否进入下一阶段

---

## 参考文档索引

| 文档 | 路径 | 何时读取 |
|------|------|---------|
| 详细执行流程 | `references/workflow.md` | 流程执行时 |
| 项目约定速查 | `references/project-conventions.md` | 每阶段开始 |
| 阶段1：需求分析 | `references/phase1-requirement.md` | Step 1 |
| 阶段2：代码生成 | `references/phase2-codegen.md` | Step 2 |
| 阶段2b：TODO实现 | `references/phase2b-todo.md` | Step 2b |
| TODO模式参考 | `references/todo-patterns.md` | Step 2b 标注时 |
| 阶段3：集成部署 | `references/phase3-integration.md` | Step 3 |
| 阶段4：验证文档 | `references/phase4-verification.md` | Step 4 |
| Maven子模块指南 | `references/module-creation-guide.md` | 新建模块时 |
| 快速参考卡片 | `QUICK_REFERENCE.md` | 快速查阅时 |
| 使用示例 | `examples/` | 参考案例时 |

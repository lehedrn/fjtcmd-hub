# 详细执行流程

**读取时机**：SKILL.md 激活后按需参考
**前置文档**：`references/project-conventions.md`

---

## Step 0：环境握手

**每次 skill 激活时首先执行。**

1. 检查 `config.json` 是否存在：

```bash
cat .claude/skills/fjtcmd-hub-dev-simple/config.json 2>/dev/null
```

2. **如果 config.json 存在**：
   - 读取配置
   - 快速验证 DB 连接（执行 `scripts/verify_env.py --quick`）
   - 验证成功 → 直接进入 Step 1
   - 验证失败 → 提示"环境配置可能需要更新"，询问是否重新配置

3. **如果 config.json 不存在**（首次使用）：
   - 执行 `python .claude/skills/fjtcmd-hub-dev-simple/scripts/verify_env.py --init`
   - 脚本自动探测：
     - 读取 `fjtcmd-hub-admin/src/main/resources/application-druid.yml` → DB 连接信息
     - 读取 `fjtcmd-hub-admin/src/main/resources/application.yml` → 后端端口
     - 读取 `fjtcmd-hub-ui/vite.config.ts` → 前端端口
     - 检查 CLI JAR 是否存在
   - 展示探测结果，逐项询问用户确认
   - 用户可修改任何项
   - 确认后自动写入 `config.json`
   - 额外询问：默认作者名、默认目标模块、需求文档基础路径

4. **向用户展示环境摘要**：

```
环境信息确认：
┌────────────┬───────────────────────┐
│ 数据库      │ fjtcmd_hub@localhost:3306 │
│ 后端端口    │ 18081                 │
│ 前端端口    │ 3888                  │
│ CLI JAR    │ ✅ 存在               │
│ DB 连接     │ ✅ 正常               │
└────────────┴───────────────────────┘
```

---

## Step 1：需求分析

**读取参考文档**：`references/phase1-requirement.md`

按文档引导完成：
1. 了解功能描述（必填参数 `description` 或交互式询问）
2. 推断模板类型（CRUD / Tree / Sub / Business）
3. 推断字段设计、索引
4. 字典设计（是否需要新建字典）
5. 展示字段展示范围（列表/表单/查询）
6. 确认 formColNum、目标模块、上级菜单位置
7. 产出文件写入 `generate/{module}/{business}/`

**产出物**：
- `generate/{module}/{business}/{business}.sql` — DDL
- `generate/{module}/{business}/{business}.yml` — YAML 配置
- `generate/{module}/{business}/{business}_dict.sql` — 字典 SQL（如有）
- `{doc-path}` — 需求文档（默认 `docs/requirements/{module}/{business}.md`）

完成后询问用户确认，确认后进入 Step 2。

---

## Step 2：代码生成与文件集成

**读取参考文档**：`references/phase2-codegen.md`

按文档引导完成：
1. 检查/创建目标 Maven 模块（参考 `references/module-creation-guide.md`）
2. 执行 DDL 建表（`scripts/db_executor.py exec --file ...`）
3. 执行字典 SQL（`scripts/db_executor.py exec --file ...`）
4. 查询/创建上级菜单（`scripts/menu_tool.py query/create`）
5. 更新 YAML 的 parentMenuId
6. CLI 生成到 `generate/{module}/{business}/output/`
7. 用户确认生成结果
8. 拷贝到目标模块（`scripts/copy_code.py`）
9. 合并 TS 索引（`scripts/merge_ts_index.py`）
10. 集成子表路由（`scripts/merge_router.py`，仅主子表时）

完成后展示集成结果，确认后进入下一步。

**如果是简单业务模板** → 进入 Step 2b
**如果是标准模板** → 进入 Step 3

---

## Step 2b：TODO 标注与实现（仅简单业务模板）

**读取参考文档**：`references/phase2b-todo.md` 和 `references/todo-patterns.md`

按文档引导完成：
1. 在已拷贝的代码中标注 //TODO（Service/Controller/前端）
2. 展示 TODO 清单给用户确认
3. 逐一实现后端 TODO（ServiceImpl → Controller）
4. 逐一实现前端 TODO（API → index.vue）
5. 全部完成后全量编译验证
6. 用户确认

完成后进入 Step 3。

---

## Step 3：集成部署

**读取参考文档**：`references/phase3-integration.md`

按文档引导完成：
1. 执行菜单 SQL（`scripts/db_executor.py exec --file ...`）
2. 全量编译后端（`./scripts/build/backend.sh clean-install`）
3. 重启后端（`./scripts/dev/backend.sh start`）
4. 重启前端（`./scripts/dev/frontend.sh start`）
5. 用户刷新缓存 + 确认菜单显示

完成后进入 Step 4。

---

## Step 4：验证与文档

**读取参考文档**：`references/phase4-verification.md`

按文档引导完成：
1. 生成模拟数据 SQL（单表/树表 20 条，主子表主 20×子 20）
2. 执行模拟数据（`scripts/db_executor.py exec --file ...`）
3. 生成 curl 测试脚本（参考 `assets/curl-test-template.sh`）
4. 执行 curl 测试
5. 生成功能测试清单
6. 生成交互记录 → `docs/changelogs/{module}/{business}/{YYYY-MM-DD}.md`

完成后询问用户是否开始新功能开发。

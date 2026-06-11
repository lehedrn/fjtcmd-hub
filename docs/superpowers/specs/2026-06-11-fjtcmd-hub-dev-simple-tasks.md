# fjtcmd-hub-dev-simple 实施任务清单

**关联设计文档**: `docs/superpowers/specs/2026-06-11-fjtcmd-hub-dev-simple-skill-design.md`
**日期**: 2026-06-11
**状态**: 待确认

---

## 任务总览

```
总计 18 个任务，预计 120-150 分钟

Phase A：基础骨架（3 个任务）
├─ A1  创建目录结构                          [2min]
├─ A2  编写 SKILL.md                        [10min]
└─ A3  编写 config.json 初始模板              [3min]

Phase B：工具脚本（6 个任务）
├─ B1  scripts/verify_env.py                 [8min]
├─ B2  scripts/db_executor.py                [8min]
├─ B3  scripts/menu_tool.py                  [8min]
├─ B4  scripts/copy_code.py                  [5min]
├─ B5  scripts/merge_ts_index.py             [5min]
└─ B6  scripts/merge_router.py               [5min]

Phase C：参考文档（8 个任务）
├─ C1  references/project-conventions.md     [5min]
├─ C2  references/phase1-requirement.md      [10min]
├─ C3  references/phase2-codegen.md          [10min]
├─ C4  references/phase2b-todo.md            [10min]
├─ C5  references/todo-patterns.md           [5min]
├─ C6  references/phase3-integration.md      [5min]
├─ C7  references/phase4-verification.md     [10min]
└─ C8  references/module-creation-guide.md   [5min]

Phase D：资产模板（1 个任务，含 3 个文件）
└─ D1  assets/（curl模板 + 字典SQL + 模拟数据规则） [5min]
```

---

## 实施顺序

```
A1 → A2 → A3 → B1 → B2 → B3 → B4 → B5 → B6 → C1 → C2 → C3 → C4 → C5 → C6 → C7 → C8 → D1
```

---

## 依赖关系

```
实施依赖（必须先完成）：
  A1 → 所有其他任务（目录必须先存在）
  A2 → C2~C8（阶段文档需与 SKILL.md 结构对齐）
  C1 → C2~C8（各阶段文档引用项目约定）
  C5 → C4（phase2b-todo 引用 todo-patterns）

运行时依赖（脚本间调用，不影响实施顺序）：
  B3 menu_tool 使用 B2 db_executor 的连接模式
  B1 verify_env 生成 config.json，所有脚本运行时读取
```

---

## 任务详细说明

### Phase A：基础骨架

| 编号 | 任务 | 时间 | 产出文件 | 说明 |
|------|------|------|---------|------|
| A1 | 创建目录结构 | 2min | 所有子目录 | mkdir -p 一次性创建 |
| A2 | 编写 SKILL.md | 10min | SKILL.md | 含 frontmatter（name/description/触发条件）、流程编排、参数解析、阶段调度、环境握手逻辑 |
| A3 | 编写 config.json 初始模板 | 3min | config.json | 带注释的 JSON 模板，标注各字段含义 |

### Phase B：工具脚本

| 编号 | 任务 | 时间 | 产出文件 | 关键功能 |
|------|------|------|---------|---------|
| B1 | verify_env.py | 8min | scripts/verify_env.py | 读取 application-druid.yml 推断DB配置；尝试 mysql/docker exec 连接；检查 CLI JAR；首次运行生成 config.json |
| B2 | db_executor.py | 8min | scripts/db_executor.py | 子命令 exec/query/sql；自动适配 docker/本地；强制 charset=utf8mb4；读取 config.json |
| B3 | menu_tool.py | 8min | scripts/menu_tool.py | 子命令 query/create/children；调用 db_executor 模式执行 SQL；返回 menu_id |
| B4 | copy_code.py | 5min | scripts/copy_code.py | 参数 source/target-module；按映射规则拷贝；目标文件冲突时警告 |
| B5 | merge_ts_index.py | 5min | scripts/merge_ts_index.py | 参数 bak/target；提取 export 行；去重检查；追加到模块分组 |
| B6 | merge_router.py | 5min | scripts/merge_router.py | 参数 bak/target；提取路由对象；name 去重；插入 dynamicRoutes 末尾 |

### Phase C：参考文档

| 编号 | 任务 | 时间 | 产出文件 | 核心内容 |
|------|------|------|---------|---------|
| C1 | project-conventions.md | 5min | references/project-conventions.md | 路径映射表、端口、包名前缀、模块列表、CLI 命令格式、SQL 执行规范 |
| C2 | phase1-requirement.md | 10min | references/phase1-requirement.md | 需求分析引导流程：推断模板类型、字段设计、字典判断、展示范围确认、产出文件规范 |
| C3 | phase2-codegen.md | 10min | references/phase2-codegen.md | 代码生成流程：模块检查/创建、DDL执行、菜单查询、CLI执行、拷贝、TS索引合并、路由集成 |
| C4 | phase2b-todo.md | 10min | references/phase2b-todo.md | TODO标注流程：标注位置、标注格式、实现顺序（后端→前端）、编译验证时机 |
| C5 | todo-patterns.md | 5min | references/todo-patterns.md | TODO 注释模式参考：Service校验、状态流转、Controller接口、前端条件按钮、API函数 |
| C6 | phase3-integration.md | 5min | references/phase3-integration.md | 菜单SQL执行、全量编译、服务重启、缓存刷新确认 |
| C7 | phase4-verification.md | 10min | references/phase4-verification.md | 模拟数据生成规则（20条/主子表420条）、curl测试脚本生成、测试清单、交互记录 |
| C8 | module-creation-guide.md | 5min | references/module-creation-guide.md | Maven子模块创建步骤、pom.xml模板、依赖检查、父POM更新、admin依赖添加 |

### Phase D：资产模板

| 编号 | 任务 | 时间 | 产出文件 | 说明 |
|------|------|------|---------|------|
| D1 | 编写资产模板 | 5min | assets/curl-test-template.sh | curl 测试脚本框架（登录→CRUD→导出） |
| | | | assets/dict-sql-template.sql | 字典类型+字典数据 INSERT 模板 |
| | | | assets/mock-data-rules.md | 数据生成规则（中文、字典覆盖、外键对应、时间范围） |

---

## 大文件写入策略

以下文件预计超过 200 行，实施时分段写入（每段 100-200 行）：

| 文件 | 预计行数 | 分段策略 |
|------|---------|---------|
| SKILL.md | ~250行 | 分 2 段：frontmatter+主流程 / 阶段调度+参数 |
| phase1-requirement.md | ~250行 | 分 2 段：推断规则+字段展示 / 产出规范+字典 |
| phase2-codegen.md | ~200行 | 分 2 段：生成+拷贝 / 集成（TS索引+路由） |
| phase2b-todo.md | ~200行 | 分 2 段：标注流程 / 实现流程 |
| phase4-verification.md | ~200行 | 分 2 段：模拟数据+curl / 测试清单+文档 |

---

## 自检记录

| 检查项 | 状态 | 备注 |
|--------|------|------|
| 设计文档覆盖完整性 | ✅ | 方案中每个模块都有对应任务 |
| 文件清单完整性 | ✅ | 18 个文件 = 18 个任务 |
| 任务粒度合规 | ✅ | 全部在 2-10min 范围内 |
| 依赖关系正确 | ✅ | 已修正 B 系列脚本间的虚假依赖 |
| 实施顺序合理 | ✅ | A→B→C→D 逻辑清晰 |
| 大文件分段策略 | ✅ | 已标注 5 个需分段的文件 |
| 无遗漏任务 | ✅ | 脚本/文档/模板全覆盖 |

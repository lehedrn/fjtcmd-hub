# fjtcmd-hub-dev-simple Skill 设计方案

**版本**: v4（最终版）
**日期**: 2026-06-11
**状态**: 待实施

---

## 1. Skill 定位

fjtcmd-hub-dev-simple 是一个引导式开发助手 skill，AI 按照标准化流程引导用户完成从需求到上线的全链路开发。

**覆盖范围**：
- **标准模板**：CRUD 单表、Tree 树表、Sub 主子表（独立页面模式）
- **简单业务模板**：标准 CRUD + 状态流转 + 业务校验 + 自定义接口

**核心能力**：
- 需求分析 → 字段推断 → DDL/YAML 生成
- 代码生成 CLI 调度 → 中间目录确认 → 自动拷贝集成
- 简单业务 TODO 标注 → 逐一实现前后端代码
- 环境探测 → 配置持久化 → 后续免重复

---

## 2. 目录结构

```
.claude/skills/fjtcmd-hub-dev-simple/
├── SKILL.md                            # 主入口（流程编排 + 阶段调度）
├── config.json                         # 环境配置（首次激活后自动生成）
├── scripts/
│   ├── verify_env.py                   # 环境验证 + config 生成
│   ├── db_executor.py                  # SQL 统一执行器（自动适配 docker/本地）
│   ├── menu_tool.py                    # 菜单查询/创建/列表
│   ├── copy_code.py                    # 代码拷贝（中间目录→目标模块）
│   ├── merge_ts_index.py              # 合并 index-bak.ts → types/api/index.ts
│   └── merge_router.py                # 合并 route-index-bak.ts → router/index.ts
├── references/
│   ├── phase1-requirement.md           # 阶段1：需求分析
│   ├── phase2-codegen.md              # 阶段2：代码生成与文件集成
│   ├── phase2b-todo.md                # 阶段2b：TODO 标注与实现（简单业务专用）
│   ├── phase3-integration.md          # 阶段3：集成部署
│   ├── phase4-verification.md         # 阶段4：验证与文档
│   ├── project-conventions.md         # 项目约定速查
│   ├── module-creation-guide.md       # Maven 子模块创建指南
│   └── todo-patterns.md              # TODO 标注模式参考
└── assets/
    ├── curl-test-template.sh           # curl 测试脚本模板
    ├── dict-sql-template.sql           # 字典 SQL 模板
    └── mock-data-rules.md             # 模拟数据生成规则
```

---

## 3. 参数体系

### 3.1 持久化配置（config.json）

首次激活后自动探测并保存，后续使用直接读取：

```json
{
  "database": {
    "host": "localhost",
    "port": 3306,
    "name": "ry-vue",
    "user": "root",
    "password": "lihaidong",
    "dockerContainer": "mysql8",
    "charset": "utf8mb4"
  },
  "server": {
    "backendPort": 18081,
    "frontendPort": 3888
  },
  "generator": {
    "cliJarPath": "fjtcmd-hub-generator-cli/target/fjtcmd-hub-generator-cli.jar",
    "defaultAuthor": "fjtcmd",
    "defaultPackagePrefix": "com.fjtcmd.hub",
    "defaultTablePrefix": "sys_",
    "defaultTplWebType": "element-plus-typescript"
  },
  "paths": {
    "projectRoot": "/home/workspaces/com/ztq/tcmd/fjtcmd-hub",
    "requirementsBase": "docs/requirements",
    "generateBase": "generate"
  },
  "modules": {
    "available": ["demo", "biz"],
    "defaultTarget": "demo"
  }
}
```

### 3.2 调用参数

| 参数 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `description` | ✅ | 交互式询问 | 功能描述（自然语言） |
| `--module` | ❌ | 交互式询问 | 模块名（demo/biz/cms） |
| `--business` | ❌ | 从描述推断 | 业务名（student/article） |
| `--template` | ❌ | 从描述推断 | crud / tree / sub / business |
| `--target` | ❌ | config.defaultTarget | 目标 Maven 模块 |
| `--doc-path` | ❌ | `{requirementsBase}/{module}/{business}.md` | 需求文档自定义路径 |
| `--parent-menu` | ❌ | 交互式查询 | 上级菜单名称或 ID |
| `--skip-env` | ❌ | false | 跳过环境验证 |

### 3.3 运行时推导

| 推导项 | 推导依据 | 用户可改 |
|--------|---------|---------|
| 模板类型 | 描述中是否含层级/关联 | ✅ |
| 表名 | module + business | ✅ |
| 字段设计 | 描述中的字段 | ✅ |
| 字典选择 | 字段语义 | ✅ |
| formColNum | 字段数量 | ✅ |
| parentMenuId | 数据库查询 | ✅ |

---

## 4. 完整流程

### 4.1 标准模板流程

```
Step 0：环境握手
  ├─ 检查 config.json 是否存在
  │   ├─ 存在 → 读取 → 快速验证 DB 连接
  │   └─ 不存在 → 自动探测 → 用户确认 → 写入 config.json
  ├─ 读取 application-druid.yml 推断 DB 信息
  ├─ 尝试 mysql 连接（自动识别 docker/本地）
  ├─ 读取 application.yml 推断后端端口
  ├─ 读取 vite.config.ts 推断前端端口
  └─ 向用户展示并确认环境信息

Step 1：需求分析
  ├─ 了解功能描述
  ├─ 推断模板类型（CRUD/Tree/Sub）
  ├─ 推断字段设计、索引
  ├─ 字典设计
  │   ├─ 识别枚举字段
  │   ├─ 检查现有字典是否可复用
  │   └─ 需新字典 → 生成字典 SQL
  ├─ 展示字段展示范围（列表/表单/查询）
  ├─ 确认 formColNum、目标模块、上级菜单位置
  └─ 产出写入 generate/{module}/{business}/

Step 2：代码生成与文件集成
  ├─ 2a 检查/创建目标 Maven 模块
  ├─ 2b 执行 DDL 建表
  ├─ 2c 执行字典 SQL（如有）
  ├─ 2d 查询/创建上级菜单（menu_tool.py）
  ├─ 2e 更新 YAML parentMenuId
  ├─ 2f CLI 生成到 generate/{module}/{business}/output/
  ├─ 2g 用户确认
  ├─ 2h 拷贝到目标模块（copy_code.py）
  ├─ 2i 合并 TS 索引（merge_ts_index.py）
  ├─ 2j 集成子表路由（merge_router.py，仅主子表）
  └─ 2k 展示集成结果

Step 3：集成部署
  ├─ 执行菜单 SQL（db_executor.py）
  ├─ 全量编译后端
  ├─ 重启后端 + 前端
  └─ 用户刷新缓存确认

Step 4：验证与文档
  ├─ 生成模拟数据（单表/树表 20 条，主子表主 20 × 子 20）
  ├─ 执行模拟数据 SQL
  ├─ 生成 curl 测试脚本 → 执行
  ├─ 生成功能测试清单
  └─ 生成交互记录
```

### 4.2 简单业务模板流程

```
Step 0：环境握手（同上）

Step 1：需求分析（含业务规则）
  ├─ 了解功能描述 + 业务规则
  ├─ 推断模板类型 + 自定义接口清单
  ├─ 字典设计
  ├─ 识别业务逻辑点 → TODO 计划清单
  └─ 产出：DDL + YAML + 字典SQL + 需求文档 + TODO清单

Step 2：代码生成与文件集成（同标准模板 2a~2k）

Step 2b：TODO 标注与实现 ⭐
  ├─ 2b-1 在代码中标注 //TODO
  │   ├─ ServiceImpl：业务校验、状态流转、自定义方法
  │   ├─ Controller：自定义接口方法
  │   ├─ 前端 index.vue：条件按钮
  │   └─ 前端 API：自定义接口函数
  ├─ 2b-2 展示 TODO 清单确认
  ├─ 2b-3 逐一实现后端 TODO
  ├─ 2b-4 逐一实现前端 TODO
  ├─ 2b-5 全部完成后全量编译验证
  └─ 2b-6 用户确认

Step 3：集成部署（同标准模板）
Step 4：验证与文档（同标准模板）
```

---

## 5. 工具脚本设计

所有脚本统一使用 Python，通过读取 config.json 获取环境信息。

### 5.1 verify_env.py
- 读取 application-druid.yml 推断 DB 配置
- 尝试 mysql 连接（docker/本地自适应）
- 检查 CLI JAR 存在
- 首次运行时生成 config.json

### 5.2 db_executor.py
- 统一 SQL 执行入口
- 自动适配 docker exec / 本地 mysql
- 强制 --default-character-set=utf8mb4
- 支持 exec（执行文件）、query（查询）、sql（直接执行）

### 5.3 menu_tool.py
- query：按名称/类型查询菜单
- create：创建菜单并返回 menu_id
- children：展示菜单树

### 5.4 copy_code.py
- 从中间目录 output/ 拷贝到目标模块
- 后端 Java + Mapper XML + 前端 API/Views/Types
- 目标文件已存在且不同时打印警告

### 5.5 merge_ts_index.py
- 读取 index-bak.ts 中的 export 行
- 对比 types/api/index.ts 去重
- 追加新行到对应模块分组

### 5.6 merge_router.py
- 读取 route-index-bak.ts 路由对象
- 检查 name 去重
- 插入 dynamicRoutes 数组末尾

---

## 6. 关键规则

### 6.1 模拟数据
- 单表/树表：20 条
- 主子表：主表 20 条 + 每条主表 20 条子表（共 420 条）
- 数据质量：合理中文、覆盖字典选项、外键严格对应

### 6.2 拷贝映射
```
output/main/java/...       → fjtcmd-hub-{module}/src/main/java/...
output/main/resources/...  → fjtcmd-hub-{module}/src/main/resources/...
output/vue/api/...         → fjtcmd-hub-ui/src/api/...
output/vue/types/api/...   → fjtcmd-hub-ui/src/types/api/...（排除 index-bak.ts）
output/vue/views/...       → fjtcmd-hub-ui/src/views/...
```

### 6.3 中间目录
```
generate/{module}/{business}/
├── {business}.sql
├── {business}.yml
├── {business}_dict.sql（如有）
└── output/（CLI 生成）
```

### 6.4 编译策略
- 全量编译：`./scripts/build/backend.sh clean-install`
- TODO 实现完成后统一编译一次

### 6.5 文件覆盖
- 中间目录：默认允许覆盖
- 目标模块：已有文件且内容不同时警告用户确认

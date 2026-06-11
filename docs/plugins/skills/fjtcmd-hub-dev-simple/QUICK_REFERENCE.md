# 快速参考卡片

fjtcmd-hub-dev-simple 一页速查。打印或快速查阅使用。

---

## 调用方式

```bash
/fjtcmd-hub-dev-simple {功能描述} [--module demo] [--business student] [--template crud]
```

---

## 流程速查

| 步骤 | 动作 | 关键脚本/文档 |
|------|------|--------------|
| **0** | 环境验证 | `verify_env.py --init/--quick` |
| **1** | 需求分析 → DDL+YAML | `phase1-requirement.md` |
| **2** | 代码生成+拷贝 | `db_executor.py` `menu_tool.py` `copy_code.py` |
| **2b** | TODO 实现（业务模板） | `phase2b-todo.md` `todo-patterns.md` |
| **3** | 编译+重启 | `build/backend.sh` `dev/backend.sh` |
| **4** | 模拟数据+测试 | `phase4-verification.md` `curl-test-template.sh` |

---

## 脚本速查

```bash
# 环境
python3 scripts/verify_env.py --init          # 首次初始化
python3 scripts/verify_env.py --quick         # 快速验证
python3 scripts/validate_config.py            # 校验配置
python3 scripts/validate_config.py --fix      # 自动修复配置

# SQL
python3 scripts/db_executor.py exec --file <sql>    # 执行文件
python3 scripts/db_executor.py exec --sql "<sql>"   # 执行语句
python3 scripts/db_executor.py query --sql "<sql>"  # 查询并展示

# 菜单
python3 scripts/menu_tool.py query --name "XX" [--type M]  # 查询
python3 scripts/menu_tool.py create --name "XX" --parent-id 0 --type M --path xx  # 创建
python3 scripts/menu_tool.py tree                           # 查看菜单树

# 代码集成
python3 scripts/copy_code.py --source <output/> --target-module demo --business student
python3 scripts/merge_ts_index.py --bak <index-bak.ts> --target <types/api/index.ts>
python3 scripts/merge_router.py --bak <route-index-bak.ts> --target <router/index.ts>
```

---

## 构建与部署

### Linux/macOS

```bash
# 后端
./scripts/build/backend.sh clean-install     # 全量编译
./scripts/dev/backend.sh start|stop|restart  # 启停
./scripts/dev/backend.sh status|logs         # 状态/日志

# 前端
./scripts/build/frontend.sh install          # 安装依赖
./scripts/dev/frontend.sh start|stop         # 启停
```

### Windows

```batch
:: 后端
scripts\build\backend.bat clean-install      :: 全量编译
scripts\dev\backend.bat start|stop|restart   :: 启停
scripts\dev\backend.bat status|logs          :: 状态/日志

:: 前端
scripts\build\frontend.bat install           :: 安装依赖
scripts\dev\frontend.bat start|stop          :: 启停
```

> **AI 注意**：执行脚本前需检测操作系统，选择对应的 .sh 或 .bat 版本。详见 `references/project-conventions.md` 第 13 节。

---

## 端口与连接

| 服务 | 端口 | 地址 |
|------|------|------|
| 后端 | 18081 | http://localhost:18081 |
| 前端 | 3888 | http://localhost:3888 |
| MySQL | 3306 | Docker `mysql8`，数据库 `fjtcmd_hub` |
| Redis | 6379 | Docker `redis` |

---

## 文件路径

| 类别 | 路径 |
|------|------|
| 中间目录 | `generate/{module}/{business}/` |
| CLI 输出 | `generate/{module}/{business}/output/` |
| 后端代码 | `fjtcmd-hub-{module}/src/main/java/...` |
| 前端 API | `fjtcmd-hub-ui/src/api/{module}/` |
| 前端页面 | `fjtcmd-hub-ui/src/views/{module}/` |
| 前端类型 | `fjtcmd-hub-ui/src/types/api/{module}/` |
| 需求文档 | `docs/requirements/{module}/{business}.md` |
| 交互记录 | `docs/changelogs/{module}/{business}/{YYYY-MM-DD}.md` |
| 测试脚本 (Linux) | `scripts/test/curl/test-{module}-{business}.sh` |
| 测试脚本 (Windows) | `scripts\test\curl\test-{module}-{business}.bat` |

---

## 故障排查

| 问题 | 排查 |
|------|------|
| 菜单不显示 | 检查菜单 SQL 是否执行；登录后刷新缓存 |
| 接口 401 | 检查权限标识是否正确；检查用户角色是否有权限 |
| 前端 404 | 检查文件是否拷贝到正确位置；检查路由是否配置 |
| 字典不显示 | 检查字典 SQL 是否执行；检查 dictType 是否正确 |
| 编译失败 | 检查 Java 代码语法；检查 import 是否正确 |
| 配置错误 | 运行 `validate_config.py`；必要时 `--fix` 或重新 `--init` |

---

## 模板类型判断

| 特征 | 模板 |
|------|------|
| 纯数据维护 | CRUD |
| 有层级/分类 | Tree |
| 一对多关联 | Sub |
| 有状态流转 | 简单业务 |

---

## 数据量

- 单表/树表模拟数据：**20 条**
- 主子表：**主表 20 条 × 子表 20 条/主 = 420 条**

---

## 相关文档

| 文档 | 说明 |
|------|------|
| `SKILL.md` | 主入口 |
| `README.md` | 完整使用说明 |
| `CHANGELOG.md` | 版本变更历史 |
| `references/workflow.md` | 详细执行流程 |
| `examples/` | 使用示例 |
| `tests/` | 单元测试 |

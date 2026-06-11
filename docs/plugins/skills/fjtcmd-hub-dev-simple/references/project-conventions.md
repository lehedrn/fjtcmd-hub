# 项目约定速查

本文档汇总 fjtcmd-hub 项目的关键约定，供各阶段参考。

---

## 1. 模块结构

| 模块 | Maven 目录 | 包名前缀 | 用途 |
|------|-----------|---------|------|
| 管理入口 | `fjtcmd-hub-admin/` | `com.fjtcmd.hub.web` | Spring Boot 启动类、通用 Controller |
| 通用工具 | `fjtcmd-hub-common/` | `com.fjtcmd.hub.common` | 工具类、异常、注解 |
| 核心框架 | `fjtcmd-hub-framework/` | `com.fjtcmd.hub.framework` | 安全配置、拦截器、数据源 |
| 系统管理 | `fjtcmd-hub-system/` | `com.fjtcmd.hub.system` | 用户、角色、菜单等 |
| 业务模块 | `fjtcmd-hub-biz/` | `com.fjtcmd.hub.biz` | 体彩门店业务功能 |
| 示例模块 | `fjtcmd-hub-demo/` | `com.fjtcmd.hub.demo` | 代码生成示例 |
| 定时任务 | `fjtcmd-hub-quartz/` | `com.fjtcmd.hub.quartz` | 定时任务 |
| 代码生成 | `fjtcmd-hub-generator/` | `com.fjtcmd.hub.generator` | Web 版代码生成 |
| 生成 CLI | `fjtcmd-hub-generator-cli/` | `com.fjtcmd.hub.generator.cli` | CLI 代码生成工具 |
| 前端 | `fjtcmd-hub-ui/` | — | Vue 3 + TypeScript 前端 |

## 2. 端口配置

| 服务 | 端口 | 配置文件 |
|------|------|---------|
| 后端 API | 18081 | `fjtcmd-hub-admin/src/main/resources/application.yml` |
| 前端开发 | 3888 | `fjtcmd-hub-ui/vite.config.ts` |
| MySQL | 3306 | Docker 容器 `mysql8` |
| Redis | 6379 | 本地或 Docker |

## 3. 数据库

| 项目 | 值 |
|------|-----|
| 数据库名 | `fjtcmd_hub` |
| 用户 | `root` |
| 密码 | `lihaidong`（从 application-druid.yml 读取） |
| 容器 | `mysql8`（Docker） |
| 字符集 | `utf8mb4` |
| 连接方式 | `docker exec -i mysql8 mysql --default-character-set=utf8mb4 -uroot -plihaidong fjtcmd_hub` |

**重要**：所有通过 docker exec 执行的 SQL 命令必须添加 `--default-character-set=utf8mb4`。

## 4. 代码生成 CLI

```bash
java -jar fjtcmd-hub-generator-cli/target/fjtcmd-hub-generator-cli.jar \
  --config <配置文件.yml> \
  --sql <DDL文件.sql> \
  --output <输出目录>
```

**模板类型**（YAML 中 `tplCategory` 字段，必须小写）：
- `crud` — 单表 CRUD
- `tree` — 树表
- `sub` — 主子表内嵌模式（旧）
- 主子表独立页面模式 — 使用 `crud` + `hasSubTable`/`isSubTable` 标记

**前端模板**（`tplWebType`）：统一使用 `element-plus-typescript`

## 5. 后端包结构

```
fjtcmd-hub-{module}/src/main/java/com/fjtcmd/hub/{module}/
├── controller/{ClassName}Controller.java
├── domain/{ClassName}.java
├── mapper/{ClassName}Mapper.java
├── service/I{ClassName}Service.java
└── service/impl/{ClassName}ServiceImpl.java
```

Mapper XML：
```
fjtcmd-hub-{module}/src/main/resources/mapper/{module}/{ClassName}Mapper.xml
```

## 6. 前端目录结构

```
fjtcmd-hub-ui/src/
├── api/{module}/{business}.ts           # API 接口
├── types/api/{module}/{business}.ts     # TypeScript 类型
├── types/api/index.ts                   # 类型统一导出（需合并 index-bak.ts）
├── views/{module}/{business}/
│   ├── index.vue                        # 列表页
│   └── view.vue                         # 详情页（如 genView: true）
└── router/index.ts                      # 路由配置（需集成 route-index-bak.ts）
```

## 7. 拷贝映射

| 源（CLI 输出） | 目标（项目目录） |
|--------------|----------------|
| `output/main/java/com/fjtcmd/hub/{module}/**` | `fjtcmd-hub-{module}/src/main/java/com/fjtcmd/hub/{module}/` |
| `output/main/resources/mapper/{module}/**` | `fjtcmd-hub-{module}/src/main/resources/mapper/{module}/` |
| `output/vue/api/{module}/**` | `fjtcmd-hub-ui/src/api/{module}/` |
| `output/vue/types/api/{module}/**`（排除 index-bak.ts） | `fjtcmd-hub-ui/src/types/api/{module}/` |
| `output/vue/views/{module}/**` | `fjtcmd-hub-ui/src/views/{module}/` |

## 8. 中间目录

```
generate/{module}/{business}/
├── {business}.sql              # DDL SQL
├── {business}.yml              # YAML 配置
├── {business}_dict.sql         # 字典 SQL（如有）
├── {business}_mock.sql         # 模拟数据（阶段4）
└── output/                     # CLI 生成输出
    ├── {business}Menu.sql
    ├── main/java/...
    ├── main/resources/...
    └── vue/...
```

## 9. 常用命令

```bash
# 后端编译
./scripts/build/backend.sh clean-install

# 后端启停
./scripts/dev/backend.sh start
./scripts/dev/backend.sh stop
./scripts/dev/backend.sh logs

# 前端启停
./scripts/dev/frontend.sh start
./scripts/dev/frontend.sh stop

# 代码生成 CLI
java -jar fjtcmd-hub-generator-cli/target/fjtcmd-hub-generator-cli.jar \
  --config generate/{module}/{business}/{business}.yml \
  --sql generate/{module}/{business}/{business}.sql \
  --output generate/{module}/{business}/output
```

## 10. 权限标识规范

格式：`{module}:{business}:{action}`

| 操作 | 权限标识 |
|------|---------|
| 查询列表 | `{module}:{business}:list` |
| 查询详情 | `{module}:{business}:query` |
| 新增 | `{module}:{business}:add` |
| 修改 | `{module}:{business}:edit` |
| 删除 | `{module}:{business}:remove` |
| 导出 | `{module}:{business}:export` |
| 导入 | `{module}:{business}:import` |

主子表子表权限：`{module}:{主表business}:{子表business}:{action}`

## 11. 菜单类型

| 类型 | 编码 | 说明 |
|------|------|------|
| 目录 | M | 一级/二级菜单分组 |
| 菜单 | C | 功能菜单页面 |
| 按钮 | F | 页面内的操作按钮 |

## 12. 字典命名

- 系统内置字典：`sys_` 前缀（如 `sys_user_sex`、`sys_normal_disable`）
- 业务自定义字典：`biz_` 前缀（如 `biz_student_hobby`、`biz_goods_type`）
- 格式：`{前缀}_{业务}_{字段}`

## 13. 跨平台脚本命令

项目提供 Linux/macOS (.sh) 和 Windows (.bat) 两套脚本，AI 执行时需根据操作系统选择对应脚本。

### 命令映射表

| 操作 | Linux/macOS | Windows |
|------|-------------|---------|
| 启动后端 | `./scripts/dev/backend.sh start` | `scripts\dev\backend.bat start` |
| 停止后端 | `./scripts/dev/backend.sh stop` | `scripts\dev\backend.bat stop` |
| 重启后端 | `./scripts/dev/backend.sh restart` | `scripts\dev\backend.bat restart` |
| 后端状态 | `./scripts/dev/backend.sh status` | `scripts\dev\backend.bat status` |
| 后端日志 | `./scripts/dev/backend.sh logs` | `scripts\dev\backend.bat logs` |
| 启动前端 | `./scripts/dev/frontend.sh start` | `scripts\dev\frontend.bat start` |
| 停止前端 | `./scripts/dev/frontend.sh stop` | `scripts\dev\frontend.bat stop` |
| 编译后端 | `./scripts/build/backend.sh clean-install` | `scripts\build\backend.bat clean-install` |
| 编译前端 | `./scripts/build/frontend.sh install` | `scripts\build\frontend.bat install` |
| 前端构建 | `./scripts/build/frontend.sh build:prod` | `scripts\build\frontend.bat build:prod` |
| 登录测试 | `./scripts/test/curl/test-login.sh` | `scripts\test\curl\test-login.bat` |
| 单表测试 | `./scripts/test/curl/test-demo-single.sh` | `scripts\test\curl\test-demo-single.bat` |
| 树表测试 | `./scripts/test/curl/test-demo-tree.sh` | `scripts\test\curl\test-demo-tree.bat` |
| 主子表测试 | `./scripts/test/curl/test-demo-master-detail.sh` | `scripts\test\curl\test-demo-master-detail.bat` |

### AI 执行规则

1. **检测操作系统**：通过 `uname` 命令或环境变量判断
   - Linux/macOS：`uname -s` 返回 `Linux` 或 `Darwin`
   - Windows：`uname -s` 返回 `MINGW*`/`MSYS*`/`CYGWIN*`，或环境变量 `OS=Windows_NT`

2. **选择脚本扩展名**：
   - Linux/macOS → `.sh`，使用 `./` 前缀
   - Windows → `.bat`，使用 `scripts\` 路径分隔符

3. **示例**：
   ```bash
   # AI 检测到 Windows 系统后，应执行：
   scripts\dev\backend.bat start
   
   # 而非：
   ./scripts/dev/backend.sh start  # Windows 下无法执行
   ```


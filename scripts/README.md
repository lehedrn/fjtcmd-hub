# 脚本目录说明

本目录包含 fjtcmd-hub 项目的各类自动化脚本，分为 `build`（构建）和 `dev`（开发环境）两个子目录。

## 目录结构

```
scripts/
├── build/                  # 构建脚本
│   ├── backend.sh         # 后端 Maven 构建脚本
│   └── frontend.sh        # 前端 pnpm 构建脚本
├── dev/                    # 开发环境脚本
│   ├── backend.sh         # 后端服务启停脚本
│   ├── frontend.sh        # 前端开发服务器启停脚本
│   ├── test_data.sql      # 测试数据初始化脚本
│   └── add_goods_data.sql # 商品数据批量添加脚本
├── test/                   # 接口测试脚本
│   └── curl/              # curl 接口测试
│       ├── test-login.sh          # 登录认证流程测试
│       ├── test-demo-single.sh    # Demo 单表测试（学生管理）
│       ├── test-demo-tree.sh      # Demo 树表测试（产品管理）
│       ├── test-demo-master-detail.sh # Demo 主子表测试（客户+商品）
│       └── README.md      # curl 测试说明
└── README.md              # 本文件
```

---

## 一、构建脚本（build/）

### 1.1 后端构建脚本 - `backend.sh`

后端 Maven 编译构建脚本，封装了常用的 Maven 命令。

**用法：**

```bash
./scripts/build/backend.sh <操作>
```

**支持的操作：**

| 操作 | 说明 | 对应 Maven 命令 |
|------|------|-----------------|
| `clean` | 清理 target 目录 | `mvn clean` |
| `compile` | 编译源码 | `mvn compile` |
| `package` | 打包（跳过测试） | `mvn package -DskipTests` |
| `install` | 编译并安装到本地仓库（跳过测试） | `mvn install -DskipTests` |
| `clean-install` | 清理后重新编译安装（跳过测试） | `mvn clean install -DskipTests` |
| `test` | 运行单元测试 | `mvn test` |

**使用示例：**

```bash
# 清理并重新构建
./scripts/build/backend.sh clean-install

# 仅编译源码
./scripts/build/backend.sh compile

# 打包部署版本
./scripts/build/backend.sh package

# 运行测试
./scripts/build/backend.sh test
```

**构建产物：**

- 打包完成后生成：`fjtcmd-hub-admin/target/fjtcmd-hub-admin.jar`

---

### 1.2 前端构建脚本 - `frontend.sh`

前端 pnpm 构建脚本，支持依赖安装、生产/预发布环境打包、清理等操作。

**用法：**

```bash
./scripts/build/frontend.sh <操作>
```

**支持的操作：**

| 操作 | 说明 |
|------|------|
| `install` | 安装前端依赖（使用 pnpm） |
| `build:prod` | 生产环境打包 |
| `build:stage` | 预发布环境打包 |
| `clean` | 清理 node_modules 和 dist 目录 |
| `clean-install` | 清理后重新安装依赖 |

**使用示例：**

```bash
# 首次使用，安装依赖
./scripts/build/frontend.sh install

# 生产环境打包
./scripts/build/frontend.sh build:prod

# 预发布环境打包
./scripts/build/frontend.sh build:stage

# 依赖问题排查：清理并重装
./scripts/build/frontend.sh clean-install
```

**构建产物：**

- 打包完成后生成：`fjtcmd-hub-ui/dist/` 目录

**注意事项：**

- 脚本会自动检测 pnpm 是否安装，未安装时会尝试全局安装
- 需要预先安装 Node.js 和 npm

---

## 二、开发环境脚本（dev/）

### 2.1 后端服务启停脚本 - `backend.sh`

后端开发环境一键启停脚本，支持服务启动、停止、重启、状态查看和日志查看。自动检查并启动依赖服务（MySQL、Redis Docker 容器）。

**用法：**

```bash
./scripts/dev/backend.sh <命令>
```

**支持的命令：**

| 命令 | 说明 |
|------|------|
| `start` | 启动后端服务 |
| `stop` | 停止后端服务 |
| `restart` | 重启后端服务 |
| `status` | 查看运行状态 |
| `logs` | 查看实时日志 |

**使用示例：**

```bash
# 启动后端服务
./scripts/dev/backend.sh start

# 查看服务状态
./scripts/dev/backend.sh status

# 查看实时日志
./scripts/dev/backend.sh logs

# 重启服务
./scripts/dev/backend.sh restart

# 停止服务
./scripts/dev/backend.sh stop
```

**服务信息：**

| 项目 | 值 |
|------|-----|
| 服务端口 | `18081` |
| 日志文件 | `logs/backend.log` |
| PID 文件 | `scripts/dev/.fjtcmd-hub-admin.pid` |
| 启动命令 | `mvn spring-boot:run -pl fjtcmd-hub-admin` |

**依赖服务：**

脚本会自动检查并尝试启动以下 Docker 容器：

- MySQL 容器：`mysql8`
- Redis 容器：`redis`

**启动检测：**

- 脚本会轮询日志文件，等待出现 "FjtcmdHub启动成功" 标志
- 启动超时时间：60 秒
- 如果检测到 "BUILD FAILURE" 或 "APPLICATION FAILED TO START" 则判定启动失败

---

### 2.2 前端开发服务器启停脚本 - `frontend.sh`

前端开发环境启停脚本，基于 Vite 开发服务器。

**用法：**

```bash
./scripts/dev/frontend.sh <命令>
```

**支持的命令：**

| 命令 | 说明 |
|------|------|
| `start` | 启动前端开发服务器 |
| `stop` | 停止前端开发服务器 |
| `restart` | 重启前端开发服务器 |
| `status` | 查看运行状态 |
| `logs` | 查看实时日志 |

**使用示例：**

```bash
# 启动前端开发服务器
./scripts/dev/frontend.sh start

# 查看服务状态
./scripts/dev/frontend.sh status

# 查看实时日志
./scripts/dev/frontend.sh logs

# 重启服务
./scripts/dev/frontend.sh restart

# 停止服务
./scripts/dev/frontend.sh stop
```

**服务信息：**

| 项目 | 值 |
|------|-----|
| 访问地址 | `http://localhost:3888` |
| 服务端口 | `3888` |
| 日志文件 | `logs/frontend.log` |
| PID 文件 | `scripts/dev/.fjtcmd-hub-ui.pid` |
| 启动命令 | `pnpm run dev` |

**启动检测：**

- 脚本会轮询日志文件，等待出现 "ready in" 标志（Vite 启动成功标志）
- 启动超时时间：15 秒

---

### 2.3 测试数据脚本

#### 2.3.1 完整测试数据 - `test_data.sql`

为项目的四个业务模块初始化测试数据，每个模块 30 条记录。

**数据内容：**

| 表名 | 说明 | 记录数 |
|------|------|--------|
| `sys_student` | 学生表 | 30 条 |
| `sys_product` | 产品表（树形结构） | 30 条（含父子关系） |
| `sys_customer` | 客户表 | 30 条 |
| `sys_goods` | 商品表 | 30 条（关联客户） |

**使用方法：**

```bash
# 连接到 MySQL 数据库
mysql -u root -p fjtcmd-hub

# 执行脚本
source /path/to/scripts/dev/test_data.sql
```

或通过 MySQL 命令行直接执行：

```bash
mysql -u root -p fjtcmd-hub < scripts/dev/test_data.sql
```

**注意事项：**

- 脚本会先清空现有数据，再插入新数据
- 执行前请确认数据库名称正确
- 生产环境请勿使用

#### 2.3.2 商品数据批量添加 - `add_goods_data.sql`

为每个客户批量添加 30 条商品数据，用于测试商品管理功能。

**数据内容：**

- 清空 `sys_goods` 表现有数据
- 为每个客户生成 30 条商品记录
- 商品名称包含 30 种预设商品（iPhone、MacBook、华为手机等）
- 随机生成重量、价格、日期、类型等属性

**使用方法：**

```bash
# 连接到 MySQL 数据库
mysql -u root -p fjtcmd-hub

# 执行脚本
source /path/to/scripts/dev/add_goods_data.sql
```

**数据规模：**

- 假设 30 个客户，将生成 30 × 30 = 900 条商品记录

**注意事项：**

- 脚本会先清空 `sys_goods` 表
- 需要先执行 `test_data.sql` 初始化客户数据
- 执行后可通过脚本末尾的查询语句验证数据

---

## 三、接口测试脚本（test/curl/）

基于 curl 的后端接口自动化测试脚本，用于开发调试时快速验证 API 可用性。

**前置条件：** `curl`、`jq` 已安装，后端服务已启动（端口 18081）

### 3.1 登录认证测试 - `test-login.sh`

完整的登录认证流程测试，覆盖登录→用户信息→路由菜单→退出登录→Token 失效验证。

```bash
./scripts/test/curl/test-login.sh
```

### 3.2 Demo 模块接口测试

按表类型拆分为 3 个独立脚本，覆盖 Demo 模块全部 CRUD + 导出接口：

| 脚本 | 表类型 | 模块 | 接口数 |
|------|--------|------|--------|
| `test-demo-single.sh` | 单表 | 学生管理 | 8 |
| `test-demo-tree.sh` | 树表 | 产品管理 | 8 |
| `test-demo-master-detail.sh` | 主子表 | 客户管理 + 商品管理 | 16 |

```bash
# 单表测试（学生管理）
./scripts/test/curl/test-demo-single.sh

# 树表测试（产品管理）
./scripts/test/curl/test-demo-tree.sh

# 主子表测试（客户管理 + 商品子表）
./scripts/test/curl/test-demo-master-detail.sh
```

> ⚠️ 脚本会实际写入数据库（新增/修改/删除），请在开发环境使用。详细说明参考 [test/curl/README.md](test/curl/README.md)

---

## 四、常用组合操作

### 4.1 首次搭建开发环境

```bash
# 1. 安装前端依赖
./scripts/build/frontend.sh install

# 2. 初始化测试数据
mysql -u root -p fjtcmd-hub < scripts/dev/test_data.sql

# 3. 启动后端服务
./scripts/dev/backend.sh start

# 4. 启动前端开发服务器
./scripts/dev/frontend.sh start
```

### 4.2 日常开发

```bash
# 启动开发环境
./scripts/dev/backend.sh start
./scripts/dev/frontend.sh start

# 查看状态
./scripts/dev/backend.sh status
./scripts/dev/frontend.sh status

# 查看日志
./scripts/dev/backend.sh logs
./scripts/dev/frontend.sh logs

# 停止开发环境
./scripts/dev/backend.sh stop
./scripts/dev/frontend.sh stop
```

### 4.3 构建部署

```bash
# 后端构建
./scripts/build/backend.sh clean-install
./scripts/build/backend.sh package

# 前端构建
./scripts/build/frontend.sh clean-install
./scripts/build/frontend.sh build:prod
```

---

## 五、注意事项

1. **执行权限**：首次使用需要给脚本添加执行权限
   ```bash
   chmod +x scripts/build/*.sh
   chmod +x scripts/dev/*.sh
   ```

2. **工作目录**：脚本会自动定位项目根目录，可在任意目录执行

3. **Docker 依赖**：后端启动脚本依赖 Docker 容器（mysql8、redis），请确保 Docker 已安装

4. **端口占用**：
   - 后端端口：`18081`
   - 前端端口：`3888`
   - 启动前请确保端口未被占用

5. **日志目录**：所有日志输出到项目根目录下的 `logs/` 目录

6. **数据备份**：执行 SQL 脚本前请备份重要数据

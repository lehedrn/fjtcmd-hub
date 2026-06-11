# fjtcmd-hub 新手环境搭建指南

> 面向首次接触本项目的开发者，从零到跑起来。

---

## 前置要求

| 软件 | 最低版本 | 说明 |
|------|----------|------|
| JDK | 17+ | 后端需要 Java 17 |
| Maven | 3.8+ | 后端构建工具 |
| Node.js | 18+ | 前端运行时 |
| pnpm | 8+ | 前端包管理器（`npm install -g pnpm`） |
| Docker | 20+ | **可选**，用于 Docker 方式安装 MySQL/Redis |
| Git | — | 代码管理 |

---

## 一、你的数据库配置

> 本项目需要 MySQL 和 Redis，请根据你的实际情况选择安装方式。
> 以下命令中的账号密码需要替换为你自己的。

在开始之前，先确认你的数据库配置：

| 配置项 | 你的值 |
|--------|--------|
| MySQL 主机 | `localhost`（默认） |
| MySQL 端口 | `3306`（默认） |
| MySQL 用户名 | `root`（默认，可自定义） |
| MySQL 密码 | *你自己设置的密码* |
| 数据库名 | `fjtcmd_hub`（固定，项目已配置） |
| Redis 主机 | `localhost`（默认） |
| Redis 端口 | `6379`（默认） |
| Redis 密码 | *你自己设置的密码* |

> ⚠️ 以下文档中的命令示例使用占位符，请替换为你的实际值：
> - `<MYSQL_USER>` — 你的 MySQL 用户名（如 `root`）
> - `<MYSQL_PASSWORD>` — 你的 MySQL 密码
> - `<REDIS_PASSWORD>` — 你的 Redis 密码
> - `<CONTAINER_NAME>` — 你的 MySQL 容器名（Docker 方式时）

---

## 二、安装 MySQL 和 Redis

### 2.1 检测本机是否已安装

```bash
# 检测 MySQL
which mysql mysqld 2>/dev/null && mysql --version || echo "MySQL 未安装"

# 检测 Redis
which redis-server 2>/dev/null && redis-server --version || echo "Redis 未安装"

# 检测 Docker（用于容器方式安装）
docker --version 2>/dev/null || echo "Docker 未安装"
```

根据检测结果，选择下面的安装方式。

---

### 2.2 方式 A：Docker 安装（推荐，不污染本机）

> 适合：本机未安装 MySQL/Redis，或不想直接安装的开发者。

#### 2.2.1 启动 MySQL 容器

```bash
docker run -d \
  --name <CONTAINER_NAME> \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=<MYSQL_PASSWORD> \
  -e MYSQL_DATABASE=fjtcmd_hub \
  -v mysql-data:/var/lib/mysql \
  mysql:8.4.5 \
  --character-set-server=utf8mb4 \
  --collation-server=utf8mb4_0900_ai_ci
```

> 说明：
> - `<CONTAINER_NAME>` 可自定义，如 `fjtcmd-mysql`
> - 容器启动时会自动创建 `fjtcmd_hub` 数据库
> - 字符集已设为 `utf8mb4`，避免中文乱码
> - 数据持久化到 Docker volume `mysql-data`

#### 2.2.2 启动 Redis 容器

```bash
docker run -d \
  --name fjtcmd-redis \
  -p 6379:6379 \
  -v redis-data:/data \
  redis:7.4.3 \
  redis-server --requirepass <REDIS_PASSWORD>
```

> 说明：
> - 数据持久化到 Docker volume `redis-data`
> - 需要设置密码，否则任何人都能连接

#### 2.2.3 验证

```bash
# 验证 MySQL
docker exec -i <CONTAINER_NAME> mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub -e "SELECT 1;"

# 验证 Redis
docker exec -i fjtcmd-redis redis-cli -a <REDIS_PASSWORD> ping
# 应输出 PONG
```

---

### 2.3 方式 B：本地安装

> 适合：本机已有 MySQL/Redis，或希望直接安装的开发者。

#### 2.3.1 安装 MySQL（Ubuntu/Debian）

```bash
sudo apt update
sudo apt install mysql-server -y

# 启动 MySQL
sudo systemctl start mysql
sudo systemctl enable mysql

# 设置 root 密码（如果未设置）
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '<MYSQL_PASSWORD>';"
```

#### 2.3.2 安装 Redis（Ubuntu/Debian）

```bash
sudo apt install redis-server -y

# 启动 Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# 设置密码（编辑配置文件）
sudo sed -i 's/^# requirepass .*/requirepass <REDIS_PASSWORD>/' /etc/redis/redis.conf
sudo systemctl restart redis-server
```

#### 2.3.3 创建数据库

```bash
mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> -e "CREATE DATABASE IF NOT EXISTS fjtcmd_hub DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
```

#### 2.3.4 验证

```bash
# 验证 MySQL
mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub -e "SELECT 1;"

# 验证 Redis
redis-cli -a <REDIS_PASSWORD> ping
# 应输出 PONG
```

---

## 三、导入数据库脚本

> 数据库 `fjtcmd_hub` 需要导入 **31 张表**：20 张若依业务表 + 11 张 Quartz 定时任务表。
> **⚠️ 导入时必须指定字符集**，否则中文数据可能出现问题。

### 3.1 Docker 方式

```bash
# 先导入主业务数据（带字符集声明）
docker exec -i <CONTAINER_NAME> mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub \
  --default-character-set=utf8mb4 < sql/fjtcmd_hub_20260417.sql

# 再导入 Quartz 定时任务表
docker exec -i <CONTAINER_NAME> mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub \
  --default-character-set=utf8mb4 < sql/quartz.sql
```

### 3.2 本地安装方式

```bash
# 先导入主业务数据（带字符集声明）
mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub \
  --default-character-set=utf8mb4 < sql/fjtcmd_hub_20260417.sql

# 再导入 Quartz 定时任务表
mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub \
  --default-character-set=utf8mb4 < sql/quartz.sql
```

### 3.3 验证导入结果

```bash
# 检查表数量（应为 31 张）
# Docker 方式：
docker exec -i <CONTAINER_NAME> mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub \
  --default-character-set=utf8mb4 -e "SHOW TABLES;" | wc -l

# 本地方式：
mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub \
  --default-character-set=utf8mb4 -e "SHOW TABLES;" | wc -l

# 检查中文数据是否正常（若依默认有一条测试数据）
# Docker 方式：
docker exec -i <CONTAINER_NAME> mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub \
  --default-character-set=utf8mb4 -e "SELECT user_name, nick_name FROM sys_user LIMIT 1;"

# 本地方式：
mysql -u<MYSQL_USER> -p<MYSQL_PASSWORD> fjtcmd_hub \
  --default-character-set=utf8mb4 -e "SELECT user_name, nick_name FROM sys_user LIMIT 1;"
# 应输出 `admin` 和对应的昵称
```

---

## 四、更新项目配置

> 如果你的 MySQL/Redis 账号密码与项目当前配置不同，需要更新配置文件。

编辑 `fjtcmd-hub-admin/src/main/resources/application.yml`，找到以下配置项并替换：

```yaml
# 数据源配置
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/fjtcmd_hub?useUnicode=true&characterEncoding=utf8mb4&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8
    username: <MYSQL_USER>          # 替换为你的 MySQL 用户名
    password: <MYSQL_PASSWORD>      # 替换为你的 MySQL 密码

  # Redis 配置
  redis:
    host: localhost
    port: 6379
    password: <REDIS_PASSWORD>      # 替换为你的 Redis 密码
```

---

## 五、后端环境

### 5.1 编译后端

```bash
cd /home/workspaces/com/ztq/tcmd/fjtcmd-hub

# 清理并编译安装所有模块
./scripts/build/backend.sh clean-install
```

也可手动执行：

```bash
mvn clean install -DskipTests
```

编译模块包括：`fjtcmd-hub-common`、`fjtcmd-hub-framework`、`fjtcmd-hub-system`、`fjtcmd-hub-quartz`、`fjtcmd-hub-generator`、`fjtcmd-hub-admin`。

### 5.2 启动后端

```bash
./scripts/dev/backend.sh start
```

后端启动后会监听 **18081** 端口（非默认 8080）。

启动过程：
1. 自动检查 Docker 中 MySQL 和 Redis 容器是否在运行（容器名为 `mysql8` 和 `redis`），未运行则自动拉起
2. 检查 18081 端口是否被占用，占用则自动 kill 旧进程
3. 使用 `mvn spring-boot:run -pl fjtcmd-hub-admin` 启动
4. 轮询日志检查 `若依启动成功` 标志，60 秒超时
5. 日志写入 `logs/backend.log`，每次启动自动清空

> ⚠️ 如果你使用的是**本地安装**的 MySQL/Redis（非 Docker），需要手动确保服务已启动。

### 5.3 其他后端命令

```bash
./scripts/dev/backend.sh stop      # 停止后端
./scripts/dev/backend.sh restart   # 重启后端
./scripts/dev/backend.sh status    # 查看运行状态
./scripts/dev/backend.sh logs      # 查看实时日志
```

---

## 六、前端环境

### 6.1 安装前端依赖

```bash
cd /home/workspaces/com/ztq/tcmd/fjtcmd-hub/fjtcmd-hub-ui

# 使用 pnpm 安装（首次需要）
pnpm install
```

本项目使用 **pnpm** 而非 npm，速度更快、磁盘占用更小。

### 6.2 启动前端开发服务器

```bash
./scripts/dev/frontend.sh start
```

前端启动后监听 **3888** 端口，自动打开浏览器。

启动过程：
1. 检查 3888 端口是否被占用，占用则自动 kill 旧进程
2. 使用 `pnpm run dev` 启动 Vite 开发服务器
3. 轮询日志检查 `ready in` 标志（Vite 启动成功标志）
4. 日志写入 `logs/frontend.log`，每次启动自动清空

### 6.3 其他前端命令

```bash
./scripts/dev/frontend.sh stop      # 停止前端
./scripts/dev/frontend.sh restart   # 重启前端
./scripts/dev/frontend.sh status    # 查看运行状态
./scripts/dev/frontend.sh logs      # 查看实时日志

# 生产打包
./scripts/build/frontend.sh build:prod

# 预发布打包
./scripts/build/frontend.sh build:stage
```

---

## 七、开发流程

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│ MySQL    │     │  后端    │     │  前端    │     │  浏览器   │
│ Redis    │ ──> │ :18081  │ <── │ :3888    │ <── │ localhost│
│          │     │         │     │ (Vite)   │     │ :3888    │
└──────────┘     └──────────┘     └──────────┘     └──────────┘
```

1. 确保 MySQL 和 Redis 运行正常（Docker 或本地安装均可）
2. 启动后端：`./scripts/dev/backend.sh start`
3. 启动前端：`./scripts/dev/frontend.sh start`
4. 浏览器访问 http://localhost:3888

---

## 八、脚本目录结构

```
scripts/
├── build/
│   ├── backend.sh    # 后端编译: clean|compile|package|install|clean-install|test
│   └── frontend.sh   # 前端编译: install|build:prod|build:stage|clean|clean-install
├── dev/
│   ├── backend.sh    # 后端启停: start|stop|restart|status|logs
│   ├── frontend.sh   # 前端启停: start|stop|restart|status|logs
│   ├── test_data.sql      # 测试数据初始化（4模块各30条）
│   └── add_goods_data.sql # 商品批量数据（每客户30条，共900条）
└── README.md         # 脚本详细使用指南
```

> 📖 脚本的完整使用说明请参考 [scripts/README.md](../../scripts/README.md)

---

## 九、常见坑点

| 问题 | 原因 | 解决 |
|------|------|------|
| 后端启动报 `BUILD FAILURE` | 端口 18081 被占用 | 脚本已自动处理，也可手动 `lsof -i :18081` 排查 |
| 前端请求接口超时 | 后端没有启动 | 先启动后端，前端通过 Vite proxy 将 `/dev-api` 代理到 `localhost:18081` |
| MySQL 中文显示 `???` | `docker exec` 终端 UTF-8 显示问题 | 数据本身不码，`--default-character-set=utf8mb4` 导入即可 |
| SQL 文件没有 `CHARSET` 声明 | 若依原生 SQL 未指定 | 导入时加 `--default-character-set=utf8mb4`，表会继承 MySQL 的 utf8mb4 |
| pnpm 安装后某些插件报错 | 隐式依赖问题 | 在 `fjtcmd-hub-ui/.npmrc` 中加 `shamefully-hoist=true`（通常不需要） |
| Redis 连接失败 | 未配置密码或密码错误 | 检查 `application.yml` 中 Redis 密码是否正确 |
| 后端连不上数据库 | `application.yml` 中数据库账号密码不匹配 | 确认配置与你设置的 MySQL 账号密码一致 |

---

## 十、快速检查清单

搭建完成后，逐项确认：

- [ ] MySQL 已安装并运行（Docker 或本地）
- [ ] Redis 已安装并运行（Docker 或本地）
- [ ] `fjtcmd_hub` 数据库已创建，包含 31 张表
- [ ] `application.yml` 中的 MySQL/Redis 账号密码与你设置的一致
- [ ] `./scripts/dev/backend.sh start` 启动成功，日志出现 `若依启动成功`
- [ ] `curl http://localhost:18081/captchaImage` 返回 JSON
- [ ] `./scripts/dev/frontend.sh start` 启动成功，日志出现 `ready in`
- [ ] 浏览器打开 http://localhost:3888 能看到登录页面

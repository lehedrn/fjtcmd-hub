<p align="center">
	<img alt="logo" src="https://oscimg.oschina.net/oscnet/up-d3d0a9303e11d522a06cd263f3079027715.png">
</p>
<h1 align="center" style="margin: 30px 0 30px; font-weight: bold;">fjtcmd-hub</h1>
<h4 align="center">体彩门店智慧互动信息管理平台 — 基于 RuoYi-Vue 二次开发</h4>
<p align="center">
	<a href="https://gitee.com/y_project/RuoYi-Vue"><img src="https://img.shields.io/badge/RuoYi-v3.9.2-brightgreen.svg"></a>
</p>

## 项目简介

fjtcmd-hub（体彩门店智慧互动信息）是一个基于若依（RuoYi-Vue）框架二次开发的项目，面向体彩门店提供智慧互动信息化管理。项目继承若依的用户、角色、权限等基础能力，在此基础上定制业务模块。

## 技术栈

**后端**：
- Java 17 + Spring Boot 4.0.3
- MyBatis + MyBatis-Spring-Boot-Starter 4.0.1
- Spring Security + JWT 认证
- MySQL 8.0 + Druid 连接池
- Redis 7（Lettuce 客户端）
- PageHelper 分页插件
- FastJSON2、Apache POI、SpringDoc OpenAPI

**前端**：
- Vue 3 + Vite 6
- Element Plus UI 组件库
- Pinia 状态管理 + Vue Router 4
- Axios、ECharts、VueQuill

## 目录结构

```
fjtcmd-hub/
├── fjtcmd-hub-admin/         # Web 入口模块（Spring Boot 启动类）
├── fjtcmd-hub-framework/     # 核心框架（安全配置、拦截器、数据源等）
├── fjtcmd-hub-system/        # 系统模块（用户、角色、菜单等业务）
├── fjtcmd-hub-biz/           # 体彩门店智慧互动信息业务模块
├── fjtcmd-hub-demo/          # 代码生成示例模块（student/product/customer/goods）
├── fjtcmd-hub-quartz/        # 定时任务模块
├── fjtcmd-hub-generator/     # 代码生成模块（Web 版）
├── fjtcmd-hub-generator-cli/ # 代码生成 CLI 工具（独立运行，无需数据库）
├── fjtcmd-hub-common/        # 通用工具类
├── fjtcmd-hub-ui/            # 前端 Vue 项目
├── scripts/                  # 构建与开发脚本
├── sql/                      # 数据库脚本
├── docs/                     # 项目文档
└── pom.xml                   # Maven 父 POM
```

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.6+
- Node.js 18+
- pnpm 8+（`npm install -g pnpm`）
- Docker（MySQL 8.0 / Redis 7，已在本机运行）

### 1. 数据库准备

本项目使用本机 Docker 运行的 MySQL 和 Redis 实例：

| 服务 | 容器名 | 端口 | 密码 |
|------|--------|------|------|
| MySQL | `mysql8` | 3306 | `lihaidong` |
| Redis | `redis` | 6379 | `lihaidong` |

MySQL 数据库 `fjtcmd_hub` 已通过 `sql/` 目录下的脚本初始化，包含若依基础表和定时任务表。如需重新导入：

```bash
# 清空并重新导入主业务数据
docker exec -i mysql8 mysql -uroot -plihaidong fjtcmd_hub --default-character-set=utf8mb4 < sql/fjtcmd_hub_20260417.sql

# 导入定时任务表
docker exec -i mysql8 mysql -uroot -plihaidong fjtcmd_hub --default-character-set=utf8mb4 < sql/quartz.sql
```

### 2. 启动后端

```bash
# 编译所有模块
./scripts/build/backend.sh clean-install

# 启动后端服务（端口 18081）
./scripts/dev/backend.sh start
```

### 3. 启动前端

```bash
# 安装前端依赖（首次需要）
./scripts/build/frontend.sh install

# 启动前端开发服务器
./scripts/dev/frontend.sh start
```

### 4. 访问系统

- 前端地址：http://localhost:3888
- 后端地址：http://localhost:18081
- 默认管理员账号：`admin` / `admin123`

> 📖 脚本完整使用说明参考 [scripts/README.md](scripts/README.md)

## 内置功能

1. **用户管理**：系统操作者配置
2. **部门管理**：组织机构配置，树结构展现支持数据权限
3. **岗位管理**：用户所属职务配置
4. **菜单管理**：系统菜单、操作权限、按钮权限标识配置
5. **角色管理**：角色菜单权限分配、数据范围权限划分
6. **字典管理**：系统中常用固定数据维护
7. **参数管理**：系统动态配置常用参数
8. **通知公告**：系统通知公告信息发布维护
9. **操作日志**：系统正常操作日志和异常信息日志记录查询
10. **登录日志**：系统登录日志记录查询
11. **在线用户**：当前系统活跃用户状态监控
12. **定时任务**：在线任务调度包含执行结果日志
13. **代码生成**：前后端代码生成（java、html、xml、sql）支持 CRUD
14. **系统接口**：自动生成 API 接口文档
15. **服务监控**：系统资源监控（CPU、内存、磁盘、堆栈）
16. **缓存监控**：缓存信息查询、命令统计
17. **在线构建器**：拖拽表单元素生成 HTML 代码
18. **连接池监控**：数据库连接池状态监控、SQL 分析

## 配置文件说明

| 配置文件 | 说明 |
|----------|------|
| `fjtcmd-hub-admin/src/main/resources/application.yml` | 主配置（端口、Redis、日志等） |
| `fjtcmd-hub-admin/src/main/resources/application-druid.yml` | Druid 数据库连接池配置 |

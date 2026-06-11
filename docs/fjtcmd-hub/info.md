# 项目信息

## 技术栈

**后端**：
- Java 17 + Spring Boot 4.0.3
- MyBatis + MyBatis-Spring-Boot-Starter 4.0.1
- Spring Security + JWT 认证
- MySQL（mysql-connector-j）
- Redis（Lettuce 客户端）
- Druid 连接池
- PageHelper 分页插件
- FastJSON2、Apache POI、SpringDoc OpenAPI
- 基于 RuoYi-Vue v3.9.2 二次开发

**前端**：
- Vue 3.5.26 + Vite 6.4.1
- TypeScript 5.6.3
- Element Plus 2.13.1 UI 组件库
- Pinia 3.0.4 状态管理 + Vue Router 4.6.4
- Axios 1.13.2、ECharts 5.6.0、@vueuse/core 14.1.0
- pnpm 11.5.2 包管理器

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
│   ├── build/                # 构建脚本（backend.sh、frontend.sh）
│   ├── dev/                  # 开发环境脚本（启停脚本、测试数据 SQL）
│   └── test/curl/            # curl 接口测试脚本
├── sql/                      # 数据库脚本
├── docs/                     # 项目文档
└── pom.xml                   # Maven 父 POM
```

## 常用命令

**后端**（使用 scripts 脚本）：
- `./scripts/build/backend.sh clean-install` — 编译所有模块
- `./scripts/build/backend.sh package` — 打包（跳过测试）
- `./scripts/dev/backend.sh start` — 启动后端服务（端口 18081）
- `./scripts/dev/backend.sh stop` — 停止后端服务
- `./scripts/dev/backend.sh logs` — 查看实时日志

**前端**（使用 scripts 脚本）：
- `./scripts/build/frontend.sh install` — 安装前端依赖（pnpm）
- `./scripts/build/frontend.sh build:prod` — 生产环境构建
- `./scripts/build/frontend.sh build:stage` — 预发布环境构建
- `./scripts/dev/frontend.sh start` — 启动前端开发服务器（端口 3888）
- `./scripts/dev/frontend.sh stop` — 停止前端服务

**代码生成 CLI**：
- `java -jar fjtcmd-hub-generator-cli/target/fjtcmd-hub-generator-cli.jar --config <配置文件> --sql <DDL文件>`
- 详细用法参考 [fjtcmd-hub-generator-cli/README.md](../../fjtcmd-hub-generator-cli/README.md)

> 📖 脚本完整使用说明参考 [scripts/README.md](../../scripts/README.md)

## 已知坑点与技术债

- `fjtcmd-hub-admin/src/main/java/com/fjtcmd/hub/web/core/config/SwaggerConfig.java` 中有占位描述（"XXX,XXX模块"），需按实际业务补充
- `application.yml` 中 Redis 密码已配置（`lihaidong`），token secret 为明文（`abcdefghijklmnopqrstuvwxyz`），生产环境需替换
- 后端端口为 **18081**（非默认 8080）
- 前端开发服务器端口为 **3888**

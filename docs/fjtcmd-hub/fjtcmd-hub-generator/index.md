# fjtcmd-hub-generator 代码生成模块文档

## 文档索引

| 文档 | 内容 |
|------|------|
| [01-概述与架构](01-概述与架构.md) | 模块定位、整体架构、依赖关系、REST API 一览 |
| [02-核心数据流](02-核心数据流.md) | 导入表、编辑配置、预览代码、生成代码、同步数据库、创建表的完整流程，以及运行依赖分析 |
| [03-域模型与配置](03-域模型与配置.md) | GenTable、GenTableColumn、GenConfig、GenConstants 完整字段说明、数据库表结构 |
| [04-模板体系](04-模板体系.md) | 22 个 .vm 模板清单、3 种模板类型（单表/树表/主子表）、TypeScript 支持、模板变量上下文、生成代码功能清单、文件上传接口对接 |
| [05-Skills转换基础](05-Skills转换基础.md) | 本质分析、4 个可转换能力点、3 种方案对比、Skill 接口设计建议、关键注意事项 |

## 相关项目

| 项目 | 说明 |
|------|------|
| [fjtcmd-hub-generator-cli](../../fjtcmd-hub-generator-cli/README.md) | 独立 CLI 代码生成工具，无需启动 Spring Boot，无需数据库连接 |

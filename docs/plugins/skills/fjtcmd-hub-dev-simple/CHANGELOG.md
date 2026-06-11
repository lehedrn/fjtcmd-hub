# Changelog

本文件记录 fjtcmd-hub-dev-simple 的所有版本变更。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，
版本号遵循 [Semantic Versioning](https://semver.org/lang/zh-CN/)。

---

## [1.1.0] - 2026-06-11

### Added
- 版本管理系统（SKILL.md frontmatter + config.json schema_version）
- 配置校验脚本 `scripts/validate_config.py`
- 统一错误处理框架 `scripts/common.py`
- 快速参考卡片 `QUICK_REFERENCE.md`
- 使用示例文档 `examples/` 目录（CRUD/Tree/Sub/Business 四种案例）
- 单元测试框架 `tests/` 目录（35 个测试用例全部通过）
- 配置模板 `config.template.json`
- 详细流程文档 `references/workflow.md`

### Changed
- SKILL.md 精简为 110 行流程概览（详细流程移至 `references/workflow.md`）
- config.json 新增 `version` 和 `schema_version` 字段
- 所有脚本可引用 `common.py` 统一错误处理

### Fixed
- del_flag 逻辑删除支持（mapper.xml.vm + serviceImpl.java.vm + index.vue.vm）
- 前端表单/列表/详情页不再展示 del_flag 字段

---

## [1.0.0] - 2026-06-11

### Added
- 初始版本发布
- 标准模板支持：CRUD 单表、Tree 树表、Sub 主子表（独立页面模式）
- 简单业务模板支持：CRUD + 状态流转 + 业务校验 + 自定义接口
- 环境自动探测与配置持久化（`config.json`）
- 6 个 Python 工具脚本：verify_env、db_executor、menu_tool、copy_code、merge_ts_index、merge_router
- 8 个参考文档：阶段指导 + 项目约定 + 模块创建指南 + TODO 模式
- 3 个资产模板：curl 测试、字典 SQL、模拟数据规则

---

## 版本说明

| 类型 | 说明 |
|------|------|
| **Added** | 新增功能 |
| **Changed** | 对现有功能的变更 |
| **Deprecated** | 即将移除的功能 |
| **Removed** | 已移除的功能 |
| **Fixed** | 问题修复 |
| **Security** | 安全相关修复 |

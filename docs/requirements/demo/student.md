# 学生管理 - 需求文档

## 1. 模块基本信息

| 项目 | 内容 |
|------|------|
| 模块名称 | 学生管理 |
| 模块编码 | demo.student |
| 表名 | sys_student |
| 模板类型 | CRUD |
| 目标模块 | fjtcmd-hub-demo |
| 上级菜单 | 开发示例（ID: 2006） |
| 文档版本 | 1.0 |
| 创建日期 | 2026-06-11 |

## 2. 核心字段

| 字段名 | 类型 | 必填 | 说明 | 表单类型 | 字典 |
|--------|------|------|------|----------|------|
| student_name | VARCHAR(50) | 是 | 学生名称 | input | — |
| student_sex | CHAR(1) | 是 | 性别 | select | sys_user_sex |
| student_age | INT | 否 | 年龄 | input | — |
| student_birthday | DATETIME | 否 | 生日 | datetime | — |
| student_phone | VARCHAR(20) | 否 | 联系电话 | input | — |
| status | CHAR(1) | 是 | 状态 | radio | sys_normal_disable |

## 3. 字典设计

全部使用系统已有字典，无需新建。

| 字段 | 字典类型 | 是否新建 |
|------|---------|---------|
| student_sex | sys_user_sex | 否（已有） |
| status | sys_normal_disable | 否（已有） |

## 4. 功能清单

| 功能 | 方法 | 路径 | 权限标识 |
|------|------|------|---------|
| 查询列表 | GET | /demo/student/list | demo:student:list |
| 查询详情 | GET | /demo/student/{id} | demo:student:query |
| 新增 | POST | /demo/student | demo:student:add |
| 修改 | PUT | /demo/student | demo:student:edit |
| 删除 | DELETE | /demo/student/{ids} | demo:student:remove |
| 导出 | POST | /demo/student/export | demo:student:export |

## 5. 生成的文件

- DDL SQL: `generate/demo/student/student.sql`
- YAML 配置: `generate/demo/student/student.yml`
- 需求文档: `docs/requirements/demo/student.md`

## 6. 下一步

- [ ] 进入阶段 2：代码生成与集成

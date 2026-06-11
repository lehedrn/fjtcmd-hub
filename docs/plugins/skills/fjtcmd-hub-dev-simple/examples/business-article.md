# 示例 4：简单业务模板（文章审核）

CRUD + 状态流转 + 自定义接口。

---

## 调用方式

```bash
/fjtcmd-hub-dev-simple 我要做一个文章管理功能，支持草稿→审核→发布→下架的状态流转。管理标题、作者、内容、状态。编辑可以提交审核，管理员可以审核通过或驳回
```

## 推断结果

| 项目 | 值 |
|------|-----|
| 模板类型 | 简单业务模板 |
| 模块编码 | cms.article |
| 表名 | cms_article |
| 新增字典 | biz_article_status |

## 字段设计

| 字段 | 类型 | 必填 | 表单 | 查询 |
|------|------|------|------|------|
| title | VARCHAR(200) | 是 | input | LIKE |
| author | VARCHAR(50) | 是 | input | EQ |
| content | LONGTEXT | 是 | editor | — |
| status | CHAR(1) | 是 | select (biz_article_status) | EQ |
| dept_id | BIGINT | 否 | — | — |
| publish_time | DATETIME | 否 | — | — |
| audit_time | DATETIME | 否 | — | — |
| audit_by | VARCHAR(64) | 否 | — | — |
| audit_remark | VARCHAR(500) | 否 | — | — |

## 新建字典

```sql
-- 字典类型
INSERT INTO sys_dict_type ... VALUES (..., '文章状态', 'biz_article_status', ...);

-- 字典数据
-- 0=草稿  1=待审核  2=已发布  3=已下架
```

## 状态流转规则

```
草稿 (0) → 待审核 (1) → 已发布 (2) → 已下架 (3)
               ↓
          驳回 → 草稿 (0)
```

## 业务规则

| 规则 | 触发时机 |
|------|---------|
| 标题唯一性 | 新增/修改 |
| 内容非空 | 提交审核 |
| 状态校验（草稿→待审核） | 提交审核 |
| 权限校验（编辑只能改自己的） | 修改 |
| 审核权限（只有管理员） | 审核 |

## TODO 清单

CLI 生成标准 CRUD 后，标注以下 TODO：

**后端 TODO**：

```java
// ServiceImpl

// TODO: [校验] 标题在同一分类下不能重复
public int insertArticle(Article article) { ... }

// TODO: [业务方法] 提交审核：校验状态为草稿+内容非空，更新状态为待审核
@Transactional
public int submitAudit(Long id) { ... }

// TODO: [业务方法] 审核通过：校验权限+状态，更新状态为已发布，记录审核人和时间
@Transactional
public int auditPass(Long id) { ... }

// TODO: [业务方法] 审核驳回：校验状态，更新状态为草稿，记录驳回原因
@Transactional
public int auditReject(Long id, String reason) { ... }

// TODO: [业务方法] 下架：校验权限+状态，更新状态为已下架
@Transactional
public int offline(Long id) { ... }

// Controller

// TODO: [自定义接口] PUT /cms/article/audit/{id}
// TODO: [自定义接口] PUT /cms/article/pass/{id}
// TODO: [自定义接口] PUT /cms/article/reject/{id}
// TODO: [自定义接口] PUT /cms/article/offline/{id}
```

**前端 TODO**：

```typescript
// API 文件
// TODO: [API函数] submitAudit(id)、auditPass(id)、auditReject(id, reason)、offline(id)

// index.vue
// TODO: [条件按钮] 根据 status 显示不同操作按钮
// 草稿(0)：修改、提交审核、删除
// 待审核(1)：审核通过、驳回
// 已发布(2)：下架
```

## 自定义接口

| 接口 | 方法 | 路径 | 权限 |
|------|------|------|------|
| 提交审核 | PUT | /cms/article/audit/{id} | cms:article:audit |
| 审核通过 | PUT | /cms/article/pass/{id} | cms:article:audit |
| 审核驳回 | PUT | /cms/article/reject/{id} | cms:article:audit |
| 下架 | PUT | /cms/article/offline/{id} | cms:article:offline |

## 实现顺序

1. 后端 ServiceImpl TODO（业务逻辑核心）
2. 后端 Controller TODO（暴露接口）
3. 前端 API TODO（接口对接）
4. 前端 index.vue TODO（条件按钮）
5. 全量编译验证

## 测试

```bash
# 模拟数据：20 条文章（状态分布：14 草稿 + 3 待审核 + 2 已发布 + 1 已下架）
# curl 测试包含自定义接口调用
```

---

**要点**：简单业务模板在标准 CRUD 基础上增加 TODO 标注和实现步骤；需要新建字典；需要设计状态流转和权限控制。

# 示例 2：Tree 树表（商品分类）

树形结构数据，支持多级嵌套。

---

## 调用方式

```bash
/fjtcmd-hub-dev-simple 我要做一个商品分类管理，支持多级嵌套，管理分类名称、排序、状态
```

## 推断结果

| 项目 | 值 |
|------|-----|
| 模板类型 | Tree（树表） |
| 模块编码 | demo.category |
| 表名 | sys_category |
| 目标模块 | fjtcmd-hub-demo |

## 字段设计

| 字段 | 类型 | 必填 | 表单 | 查询 | 树属性 |
|------|------|------|------|------|--------|
| category_name | VARCHAR(30) | 是 | input | LIKE | treeName |
| parent_id | BIGINT | 是 | select | — | treeParentCode |
| ancestors | VARCHAR(500) | 否 | — | — | — |
| order_num | INT | 否 | input | — | — |
| status | CHAR(1) | 是 | select (sys_normal_disable) | EQ | — |

**树表特有字段**：
- `category_id` → treeCode（树编码）
- `parent_id` → treeParentCode（父编码）
- `category_name` → treeName（树名称）

## YAML 配置关键

```yaml
global:
  tplCategory: tree  # 树表

tables:
  sys_category:
    treeCode: category_id
    treeParentCode: parent_id
    treeName: category_name
```

## 与 CRUD 的区别

| 特性 | CRUD | Tree |
|------|------|------|
| 列表展示 | 平铺表格 | 左侧树 + 右侧列表 |
| 实体基类 | BaseEntity | TreeEntity |
| 新增 | 直接保存 | 需设置 ancestors |
| 删除 | 直接删除 | 需检查子节点 |

## 测试

```bash
# 模拟数据：20 条（3 个一级 + 若干二三级）
```

---

**要点**：树表必须包含 `ancestors` 字段；YAML 需配置 treeCode/treeParentCode/treeName。

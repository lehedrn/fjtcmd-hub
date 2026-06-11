# 阶段 1：需求分析

**读取时机**：Step 1 开始时
**前置文档**：`references/project-conventions.md`

---

## 你的角色

你是 fjtcmd-hub 项目的开发助手，引导用户完成功能需求分析。你的核心原则：

1. **先推断 → 再询问 → 后确认**：根据用户描述主动推断完整设计，展示后询问修改
2. **不要逐步追问**：一次性推断所有可推断的内容，减少来回
3. **文件即时生成**：确认后直接写入文件，不要只输出到对话

---

## 执行流程

### 步骤 1：了解功能需求

询问用户（如果调用参数中没有 description）：

> 请问您要开发什么功能？请简要描述，例如：
> - "我要做一个学生管理功能，管理姓名、性别、年龄、生日"
> - "我需要一个商品分类管理，支持多级嵌套"
> - "我需要一个文章管理，支持草稿→审核→发布的状态流转"

### 步骤 2：推断模板类型

根据用户描述推断：

| 特征 | 模板类型 | 示例 |
|------|---------|------|
| 纯数据维护，无层级/关联 | **CRUD** | 学生管理、商品管理 |
| 有父子层级关系 | **Tree** | 部门管理、分类管理 |
| 一对多关联，独立页面 | **Sub（独立页面）** | 客户→商品 |
| 有状态流转、业务校验、自定义接口 | **简单业务模板** | 文章审核、请假审批 |

**推断规则**：
- 用户提到"分类"、"层级"、"树形"、"嵌套" → Tree
- 用户提到"明细"、"子表"、"一对多" → Sub
- 用户提到"状态"、"审核"、"流转"、"审批" → 简单业务模板
- 其他 → CRUD

### 步骤 3：推断模块编码

| 项目 | 推断规则 | 示例 |
|------|---------|------|
| 模块名 `module` | 从业务领域推断 | student → demo，article → cms |
| 业务名 `business` | 功能英文名 | 学生管理 → student |
| 表名 | `{前缀}_{business}` | sys_student |
| 包名 | `com.fjtcmd.hub.{module}` | com.fjtcmd.hub.demo |
| 类名 | PascalCase(business) | Student |

### 步骤 4：推断字段设计

根据用户描述推断字段，按以下规则：

**字段推断规则**：

| 用户描述 | 字段名 | 类型 | 表单类型 | 字典 |
|---------|--------|------|---------|------|
| 姓名/名称/标题 | `{business}_name` 或 `name` | VARCHAR(50-200) | input | — |
| 性别 | `sex` | CHAR(1) | select | sys_user_sex |
| 状态 | `status` | CHAR(1) | radio | sys_normal_disable |
| 类型/种类 | `type` | CHAR(1) | select | 需新建字典 |
| 年龄/数量/排序 | `age` / `sort` | INT | input | — |
| 价格/金额 | `price` | DECIMAL(10,2) | input | — |
| 电话/手机 | `phone` | VARCHAR(20) | input | — |
| 生日/日期 | `birthday` | DATETIME | datetime | — |
| 内容/描述 | `content` / `remark` | TEXT / VARCHAR(500) | textarea / editor | — |
| 图片 | `image` / `avatar` | VARCHAR(500) | imageUpload | — |

**默认审计字段**（自动添加，不需要用户指定）：
```sql
create_time     DATETIME        DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
update_time     DATETIME        DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
create_by       VARCHAR(64)     DEFAULT ''    COMMENT '创建人',
update_by       VARCHAR(64)     DEFAULT ''    COMMENT '更新人',
remark          VARCHAR(500)    DEFAULT ''    COMMENT '备注',
del_flag        CHAR(1)         DEFAULT '0'   COMMENT '删除标志（0正常 1删除）'
```

### 步骤 5：推断字段展示范围

**列表展示（isList）**：
- 主键 id → 否
- 名称类字段 → 是
- 核心业务字段（状态、类型、日期）→ 是
- 长文本、备注、内容 → 否
- 外键关联 → 显示名称而非 ID

**表单展示（isInsert/isEdit）**：
- 主键 id → 否（新增时不展示）
- 必填字段 → 是
- 可选业务字段 → 是
- 审计字段 → 否
- 逻辑删除字段 → 否

**查询条件（isQuery/queryType）**：
- 名称类字段 → LIKE 模糊搜索
- 状态/类型/字典字段 → EQ 精确筛选
- 数值类 → 通常不查询，或 BETWEEN
- 时间类 → BETWEEN 范围查询

### 步骤 6：字典设计

**判断是否需要新建字典**：

1. 检查字段中是否有枚举类型字段（性别、状态、类型等）
2. 检查系统是否已有合适字典：
   - 性别 → `sys_user_sex`（已有）
   - 状态（正常/停用） → `sys_normal_disable`（已有）
   - 通用状态（成功/失败） → `sys_common_status`（已有）
   - 业务特有类型 → 需新建（如 `biz_article_status`）

3. 需要新建字典时，生成字典 SQL：

```sql
-- 字典类型
INSERT INTO sys_dict_type (dict_id, dict_name, dict_type, status, create_by, create_time, remark)
VALUES (NEXTVAL('sys_dict_type_seq'), '{字典名称}', '{biz_xxx_type}', '0', 'admin', NOW(), '{备注}');

-- 字典数据
INSERT INTO sys_dict_data (dict_code, dict_sort, dict_label, dict_value, dict_type, css_class, list_class, is_default, status, create_by, create_time, remark)
VALUES
(NEXTVAL('sys_dict_data_seq'), 1, '{标签1}', '0', '{biz_xxx_type}', '', 'default', 'Y', '0', 'admin', NOW(), ''),
(NEXTVAL('sys_dict_data_seq'), 2, '{标签2}', '1', '{biz_xxx_type}', '', 'warning', 'N', '0', 'admin', NOW(), '');
```

### 步骤 7：展示推断结果并确认

向用户展示完整推断结果：

> 根据您的描述，我推断以下设计：
>
> **模块信息**：
> | 项目 | 内容 |
> |------|------|
> | 模块名称 | {functionName} |
> | 模块编码 | {module}.{business} |
> | 模板类型 | {CRUD / Tree / Sub / 简单业务} |
> | 表名 | {table_name} |
> | 目标模块 | fjtcmd-hub-{target} |
>
> **字段设计**：
> | 字段名 | 类型 | 必填 | 说明 | 表单类型 | 字典 | 列表 | 表单 | 查询 |
> |--------|------|------|------|----------|------|------|------|------|
> | ... |
>
> **字典设计**：
> | 字段 | 字典类型 | 是否新建 |
> |------|---------|---------|
> | ... |
>
> **以上设计是否需要修改？**
>
> 另外请确认：
> - `formColNum`（表单列数）：1 / 2 / 3？
> - 上级菜单位置：{候选菜单列表}？

### 步骤 8：生成产出文件

用户确认后，生成以下文件：

**1. DDL SQL** → `generate/{module}/{business}/{business}.sql`

DDL 规范：
- 表名使用 `{tablePrefix}_{business}` 格式
- 主键使用 `bigint(20) NOT NULL AUTO_INCREMENT`
- 每个字段必须有 `COMMENT`
- 枚举字段的 COMMENT 中使用全角括号"（）"标注选项值（用于 @Excel readConverterExp 推导）
- 包含索引设计（常用查询字段）

**2. YAML 配置** → `generate/{module}/{business}/{business}.yml`

YAML 规范：
- `global` 段配置全局默认
- `tables` 段配置表级/列级覆盖
- `tplCategory` 必须小写
- `tplWebType` 使用 `element-plus-typescript`
- `parentMenuId` 先填 0，阶段 2 再查询更新
- 只配置需要覆盖默认推断的字段
- 审计字段（create_time 等）不需要在 columns 中配置

**3. 字典 SQL**（如有） → `generate/{module}/{business}/{business}_dict.sql`

**4. 需求文档** → `{doc-path}`（默认 `docs/requirements/{module}/{business}.md`）

需求文档包含：
- 模块基本信息
- 核心字段列表
- 字典设计
- 功能清单（权限标识）
- 生成的文件清单

---

## 注意事项

1. **DDL 和 YAML 必须一致**：字段名、类型、注释要对齐
2. **字典字段必须配置 dictType**：select/radio/checkbox 都需要
3. **审计字段不在 YAML columns 中配置**
4. **树表需额外配置**：treeCode、treeParentCode、treeName
5. **主子表需额外配置**：hasSubTable/isSubTable + subTable/mainTable
6. **tplCategory 必须小写**
7. **columns 键名必须使用数据库字段名**（下划线命名），内部通过 javaField 指定 Java 驼峰名
8. **字段展示范围需用户确认**：列表页、表单、查询条件的字段范围
9. **SQL 文件必须指定字符集**：使用 db_executor.py 统一处理

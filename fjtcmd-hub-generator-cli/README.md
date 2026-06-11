# fjtcmd-hub-generator-cli

若依代码生成 CLI 工具 — 复用 `fjtcmd-hub-generator` 模块，独立运行，无需 Spring Boot，无需数据库连接。

## 目录

- [设计思想](#设计思想)
- [特性](#特性)
- [快速开始](#快速开始)
- [DDL 规范](#ddl-规范)
- [YAML 配置详解](#yaml-配置详解)
- [三种模板类型](#三种模板类型)
- [@Excel 注解生成规则](#excel-注解生成规则)
- [生成的文件清单](#生成的文件清单)
- [项目结构](#项目结构)

## 设计思想

参考 `ruoyi-gen-cli` 的三层配置覆盖模式：

```
DDL 自动推断（Druid Parser + GenUtils）→ YAML 全局默认 → YAML 表级/列级覆盖
```

- **复用不复制**：直接依赖 `fjtcmd-hub-generator` 模块的 GenTable、GenUtils、VelocityUtils、所有模板
- **先 init 后覆盖**：YAML 配置在 `GenUtils.initColumnField` 之后覆盖，从根本上杜绝字段丢失
- **Map-based 列配置**：YAML 按列名索引，只写要覆盖的字段

## 特性

- **零运行时依赖**：不依赖 MySQL / Redis / Spring Boot Web
- **模板同步**：使用 generator 模块的 .vm 模板，web 端更新自动同步
- **双输入模式**：支持 CREATE TABLE SQL 文件（可多张表）
- **TypeScript 支持**：可生成 Vue 3 + TypeScript 前端代码
- **3 种模板类型**：单表 (crud)、树表 (tree)、主子表 (sub/独立页面模式)
- **主子表独立页面模式**：主表有"子表管理"按钮，点击跳转到独立子表页面
- **详情页支持**：`genView: true` 自动生成 view.vue 详情抽屉
- **预览模式**：`--preview` 输出到 stdout，不写文件

## 快速开始

### 编译

```bash
cd fjtcmd-hub-generator-cli
mvn clean package -DskipTests
```

生成 fat jar：`target/fjtcmd-hub-generator-cli.jar`

### 用法

```bash
java -jar target/fjtcmd-hub-generator-cli.jar \
  --config config/generator.yml \
  --sql sql/create.sql \
  --output ./generated
```

#### 预览模式（不写文件，输出到 stdout）

```bash
java -jar target/fjtcmd-hub-generator-cli.jar \
  --config config/generator.yml \
  --sql sql/create.sql \
  --preview
```

### 命令行参数

| 参数 | 说明 | 必填 |
|------|------|------|
| `--config <path>` | YAML 配置文件路径 | ✅ |
| `--sql <path>` | CREATE TABLE SQL 文件路径 | ✅ |
| `--output <path>` | 输出目录（覆盖配置中的 `global.output`） | ❌ |
| `--preview` | 预览模式：输出到 stdout 不写文件 | ❌ |
| `--overwrite` | 允许覆盖已存在的文件 | ❌ |
| `--help`, `-h` | 显示帮助信息 | ❌ |

> 支持 `--key=value` 和 `--key value` 两种参数格式。

---

## DDL 规范

### 基本语法

使用标准 MySQL `CREATE TABLE` 语句，一个文件可包含多条建表语句（主子表场景）。

```sql
create table sys_student (
  student_id      bigint(20)    not null auto_increment  comment '编号',
  student_name    varchar(30)   default ''               comment '学生名称',
  student_sex     char(1)       default '0'              comment '性别（0男 1女 2未知）',
  student_birthday datetime                             comment '生日',
  primary key (student_id)
) engine=innodb auto_increment=1 comment = '学生信息表';
```

### DDL 要素说明

| 要素 | 说明 | 是否必须 |
|------|------|---------|
| `primary key` | 主键定义，用于标识 `isPk` | ✅ 必须 |
| `auto_increment` | 自增标记，用于 `isIncrement` | 建议有 |
| `comment` (列级) | 列注释，用于字段描述、@Excel 名称 | ✅ 必须 |
| `comment` (表级) | 表注释，用于推导 `functionName` | ✅ 必须 |
| `not null` | 非空约束，用于推导 `isRequired` | 可选 |
| `default` | 默认值，不影响代码生成 | 可选 |

### 字段类型自动映射

#### 数据库类型 → Java 类型

| 数据库类型 | Java 类型 | 说明 |
|-----------|----------|------|
| `char`, `varchar`, `nvarchar`, `varchar2` | `String` | 字符串类型 |
| `tinytext`, `text`, `mediumtext`, `longtext` | `String` | 文本类型 |
| `datetime`, `time`, `date`, `timestamp` | `Date` | 时间类型 |
| `tinyint`, `smallint`, `mediumint`, `int`, `integer` | `Integer` | 整型（长度 ≤ 10） |
| `bigint` | `Long` | 长整型 |
| `float`, `double`, `decimal` (小数位 > 0) | `BigDecimal` | 浮点/高精度 |
| `decimal` (小数位 = 0), `number` | `Long` | 数字类型 |

#### 数据库类型 → HTML 组件

| 条件 | HTML 组件 | htmlType 值 |
|------|----------|------------|
| 字符串类型，长度 < 500 | 文本框 | `input` |
| 字符串类型，长度 ≥ 500 或 text 类型 | 文本域 | `textarea` |
| 时间类型 | 日期控件 | `datetime` |
| 数字类型 | 文本框 | `input` |

### 字段名自动推断规则

以下规则由 `GenUtils.initColumnField` 自动执行，**无需在 YAML 中配置**：

| 规则 | 条件 | 自动设置 |
|------|------|---------|
| 模糊查询 | 列名以 `name` 结尾 | `queryType = LIKE` |
| 单选框 | 列名以 `status` 结尾 | `htmlType = radio` |
| 下拉框 | 列名以 `type` 或 `sex` 结尾 | `htmlType = select` |
| 图片上传 | 列名以 `image` 结尾 | `htmlType = imageUpload` |
| 文件上传 | 列名以 `file` 结尾 | `htmlType = fileUpload` |
| 富文本 | 列名以 `content` 结尾 | `htmlType = editor` |

### 默认字段行为

| 行为 | 默认值 | 排除的列名（自动设为 false） |
|------|-------|--------------------------|
| `isInsert` | `true` | 无（所有字段都插入） |
| `isEdit` | `true` | `id`, `create_by`, `create_time`, `del_flag` |
| `isList` | `true` | `id`, `create_by`, `create_time`, `del_flag`, `update_by`, `update_time` |
| `isQuery` | `true` | `id`, `create_by`, `create_time`, `del_flag`, `update_by`, `update_time`, `remark` |

> 主键列的 `isEdit`、`isList`、`isQuery` 自动设为 `false`。

### isRequired 推导

- DDL 中有 `NOT NULL` 约束 → `isRequired = true`
- DDL 中无 `NOT NULL` 约束 → `isRequired = false`

> **注意**：DDL 的 NOT NULL 是数据库层面的约束，与业务层面的"必填"可能不同。如需覆盖，在 YAML 列级配置中设置 `isRequired: true/false`。

---

## YAML 配置详解

配置文件分为三层：**全局默认** → **表级覆盖** → **列级覆盖**。

```yaml
# 全局默认（对所有表生效）
global:
  author: ztq
  packageName: com.fjtcmd.hub.biz
  ...

# 表级/列级覆盖（按表名、列名索引）
tables:
  sys_student:
    functionName: 学生信息
    columns:
      student_hobby:
        htmlType: checkbox
        dictType: biz_student_hobby
```

### 全局配置 (global)

| 字段 | 类型 | 默认值 | 说明 |
|------|------|-------|------|
| `author` | String | — | 作者名，用于 Java 类注释 `@author` |
| `packageName` | String | — | 生成包路径，如 `com.fjtcmd.hub.biz` |
| `autoRemovePre` | Boolean | false | 是否自动去除表名前缀 |
| `tablePrefix` | String | — | 表名前缀（多个用逗号分隔），如 `sys_` |
| `tplCategory` | String | `crud` | 模板类型：`crud`（单表）/ `tree`（树表）/ `sub`（主子表） |
| `tplWebType` | String | — | 前端模板类型：`element-plus` / `element-plus-typescript` |
| `formColNum` | Integer | 1 | 表单列数：`1`（单列）/ `2`（双列）/ `3`（三列） |
| `parentMenuId` | Long | 3 | 上级菜单 ID，用于生成菜单 SQL |
| `genView` | Boolean | false | 是否生成详情页（view.vue 详情抽屉） |
| `output` | String | `./generated` | 输出目录 |
| `allowOverwrite` | Boolean | false | 是否允许覆盖已存在的文件 |

> `autoRemovePre + tablePrefix` 配合使用：表名 `sys_student`，前缀 `sys_`，去除后得到类名 `Student`。

### 表级配置 (tables.{tableName})

key 为**数据库中的原始表名**（含前缀）。

| 字段 | 类型 | 说明 |
|------|------|------|
| `functionName` | String | 功能名称，用于注释、日志、菜单。不配置时从表注释推导（去"表"/"若依"） |
| `tableComment` | String | 覆盖 DDL 中的表注释 |
| `className` | String | 覆盖自动推导的实体类名 |
| `tplCategory` | String | 覆盖全局的模板类型 |
| `tplWebType` | String | 覆盖全局的前端模板类型 |
| `packageName` | String | 覆盖全局的包路径 |
| `moduleName` | String | 模块名（默认从 packageName 末段提取） |
| `businessName` | String | 业务名（默认从表名末段提取） |
| `formColNum` | Integer | 覆盖全局的表单列数 |
| `parentMenuId` | Long | 覆盖全局的上级菜单 ID |
| `genView` | Boolean | 覆盖全局的详情页开关 |
| `treeCode` | String | **树表**：树节点编码字段（Java 属性名，如 `productId`） |
| `treeParentCode` | String | **树表**：树父编码字段（Java 属性名，如 `parentId`） |
| `treeName` | String | **树表**：树节点名称字段（Java 属性名，如 `productName`） |
| `subTableName` | String | **主子表(旧)**：子表名（数据库原始表名） |
| `subTableFkName` | String | **主子表(旧)**：子表中的外键列名 |
| `orderNum` | Integer | 菜单排序号 |
| `hasSubTable` | Boolean | **主子表(新)**：标记有子表（主表配置） |
| `subTable` | Object | **主子表(新)**：子表配置信息（见下表） |
| `isSubTable` | Boolean | **主子表(新)**：标记为子表（子表配置） |
| `mainTable` | Object | **主子表(新)**：主表配置信息（见下表） |

#### 主子表独立页面模式配置（新设计）

**主表配置 (`hasSubTable: true`)**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `subTable.className` | String | 子表类名（如 `Goods`） |
| `subTable.businessName` | String | 子表业务名（如 `goods`） |
| `subTable.subRoute` | String | 子表路由路径（如 `customer-goods`） |
| `subTable.functionName` | String | 子表功能名（如 `商品`） |
| `subTable.fkName` | String | 外键列名（如 `customer_id`） |
| `subTable.fkJavaField` | String | 外键 Java 字段名（如 `customerId`） |
| `subTable.permissionPrefix` | String | 子表权限前缀（如 `goods`） |

**子表配置 (`isSubTable: true`)**：

| 字段 | 类型 | 说明 |
|------|------|------|
| `mainTable.className` | String | 主表类名（如 `Customer`） |
| `mainTable.businessName` | String | 主表业务名（如 `customer`） |
| `mainTable.tableName` | String | 主表表名（如 `sys_customer`） |
| `mainTable.functionName` | String | 主表功能名（如 `客户`） |
| `mainTable.pkJavaField` | String | 主表主键字段（如 `customerId`） |
| `mainTable.nameJavaField` | String | 主表名称字段（如 `customerName`） |
| `mainTable.fkJavaField` | String | 外键字段名（如 `customerId`） |

### 列级配置 (tables.{tableName}.columns.{columnName})

key 为**数据库中的原始列名**。只需写需要覆盖的字段。

| 字段 | 类型 | 说明 |
|------|------|------|
| `columnComment` | String | 覆盖列注释（影响 @Excel 名称、表单 label、搜索 label） |
| `javaType` | String | 覆盖 Java 类型：`String` / `Integer` / `Long` / `BigDecimal` / `Date` |
| `javaField` | String | 覆盖 Java 属性名（默认从列名驼峰转换） |
| `isInsert` | Boolean | 是否为插入字段 |
| `isEdit` | Boolean | 是否为编辑字段 |
| `isList` | Boolean | 是否为列表展示字段（`false` 时不生成 `@Excel` 注解） |
| `isQuery` | Boolean | 是否为查询字段（`false` 时不出现在搜索表单和 WHERE 子句中） |
| `isRequired` | Boolean | 是否必填（影响表单校验规则、Mapper 中 `!= ''` 判断） |
| `queryType` | String | 查询方式（见下表） |
| `htmlType` | String | 前端组件类型（见下表） |
| `dictType` | String | 关联的字典类型编码，如 `sys_user_sex` |

#### queryType 可选值

| 值 | 说明 | SQL 生成 |
|----|------|---------|
| `EQ` | 等于（默认） | `= #{field}` |
| `NE` | 不等于 | `!= #{field}` |
| `GT` | 大于 | `> #{field}` |
| `GTE` | 大于等于 | `>= #{field}` |
| `LT` | 小于 | `< #{field}` |
| `LTE` | 小于等于 | `<= #{field}` |
| `LIKE` | 模糊查询 | `like concat('%', #{field}, '%')` |
| `BETWEEN` | 范围查询 | `between #{params.beginXxx} and #{params.endXxx}` |

#### htmlType 可选值

| 值 | 说明 | 适用场景 |
|----|------|---------|
| `input` | 文本框（默认） | 普通文本、数字 |
| `textarea` | 文本域 | 长文本（≥ 500 字符自动推导） |
| `select` | 下拉框 | 性别、类型等（需配合 dictType） |
| `radio` | 单选框 | 状态等（需配合 dictType） |
| `checkbox` | 复选框 | 爱好等多选（需配合 dictType） |
| `datetime` | 日期控件 | 时间类型（自动推导） |
| `imageUpload` | 图片上传 | 头像等 |
| `fileUpload` | 文件上传 | 附件等 |
| `editor` | 富文本 | 内容等 |

---

## 三种模板类型

### 单表 CRUD (`tplCategory: crud`)

最基本的增删改查，适用于独立表。

**DDL 示例**（`docs/generator/demo/student/config/create_student.sql`）：

```sql
create table sys_student (
  student_id      bigint(20)    not null auto_increment  comment '编号',
  student_name    varchar(30)   default ''               comment '学生名称',
  student_age     int(3)        default null              comment '年龄',
  student_hobby   varchar(30)   default ''               comment '爱好（0代码 1音乐 2电影）',
  student_sex     char(1)       default '0'              comment '性别（0男 1女 2未知）',
  student_status  char(1)       default '0'              comment '状态（0正常 1停用）',
  student_birthday datetime                             comment '生日',
  primary key (student_id)
) engine=innodb auto_increment=1 comment = '学生信息表';
```

**YAML 配置**（`docs/generator/demo/student/config/generator.yml`）：

```yaml
global:
  author: lihd
  packageName: com.fjtcmd.hub.demo
  autoRemovePre: true
  tablePrefix: sys_
  tplCategory: crud
  tplWebType: element-plus-typescript
  formColNum: 1
  parentMenuId: 2006
  genView: true
  output: docs/generator/demo/student/output
  allowOverwrite: true

tables:
  sys_student:
    functionName: 学生信息
    columns:
      student_name:
        queryType: LIKE
        isRequired: true
      student_hobby:
        htmlType: checkbox
        dictType: biz_student_hobby
      student_sex:
        htmlType: select
        dictType: sys_user_sex
      student_status:
        htmlType: radio
        dictType: sys_normal_disable
        isRequired: true
      student_birthday:
        queryType: BETWEEN
      student_age:
        isQuery: false
```

**要点**：
- `student_age` 设为 `isQuery: false`，因为年龄不适合精确匹配查询
- `student_hobby` 使用 `checkbox` + 字典，支持多选
- `student_birthday` 使用 `BETWEEN` 范围查询

---

### 树表 (`tplCategory: tree`)

适用于有父子层级关系的表，如部门、产品类别等。

**树表特有配置**：

| 配置 | 说明 |
|------|------|
| `treeCode` | 树节点编码字段（通常为主键的 Java 属性名） |
| `treeParentCode` | 父节点编码字段 |
| `treeName` | 树节点显示名称字段 |

**DDL 要求**：树表必须包含 `ancestors` 列，用于存储祖级路径（如 `"0,1,2"`）。

**DDL 示例**（`docs/generator/demo/product/config/create_product.sql`）：

```sql
create table sys_product (
  product_id      bigint(20)    not null auto_increment  comment '产品id',
  parent_id       bigint(20)    default 0                comment '父产品id',
  ancestors       varchar(500)  default '0'              comment '祖级列表',
  product_name    varchar(30)   default ''               comment '产品名称',
  order_num       int(4)        default 0                comment '显示顺序',
  status          char(1)       default '0'              comment '产品状态（0正常 1停用）',
  primary key (product_id)
) engine=innodb auto_increment=1 comment = '产品表';
```

**YAML 配置**（`docs/generator/demo/product/config/generator.yml`）：

```yaml
global:
  author: lihd
  packageName: com.fjtcmd.hub.demo
  autoRemovePre: true
  tablePrefix: sys_
  tplCategory: tree
  tplWebType: element-plus-typescript
  formColNum: 1
  parentMenuId: 2006
  genView: true
  output: docs/generator/demo/product/output
  allowOverwrite: true

tables:
  sys_product:
    functionName: 产品信息
    treeCode: product_id
    treeParentCode: parent_id
    treeName: product_name
    columns:
      product_id:
        isList: false
        isQuery: false
        isRequired: false
      parent_id:
        isList: false
        isQuery: false
        isRequired: true
      ancestors:
        isList: false
        isQuery: false
      product_name:
        queryType: LIKE
        isRequired: true
      status:
        htmlType: select
        dictType: sys_normal_disable
        isRequired: true
```

**要点**：
- DDL 中必须包含 `ancestors varchar(500)` 列
- `product_id` 和 `parent_id` 设为 `isList: false`，不在列表中展示
- `ancestors` 设为 `isList: false, isQuery: false`，仅在后台使用

---

### 主子表独立页面模式（推荐）

适用于一对多关系的两张表，采用**独立页面跳转**模式。主表列表有"子表管理"按钮，点击跳转到独立的子表管理页面。

**交互设计**：
```
┌─────────────────────────────────────────┐
│ 主表页面（如：客户管理）                   │
│ 操作列：[详情] [修改] [商品管理] [删除]    │
│                      ↓ 点击跳转          │
└─────────────────────────────────────────┘
           /demo/customer-goods/index/:customerId
                     ↓
┌─────────────────────────────────────────┐
│ 子表页面（如：商品管理）                   │
│ 搜索表单：[客户下拉框] + 其他条件         │
│ 工具栏：[新增] [修改] [删除] [导出] [关闭] │
└─────────────────────────────────────────┘
```

**核心特性**：
- 主表操作列增加"子表管理"按钮
- 子表页面有主表下拉框，可切换不同主表记录
- 子表权限挂在主表菜单下（如 `demo:customer:goods:list`）
- 子表页面提供"关闭"按钮返回主表
- 自动生成路由配置片段（`route-index-bak.ts`）

**DDL 示例**：

```sql
-- 主表：客户
create table sys_customer (
  customer_id     bigint(20)    not null auto_increment  comment '客户id',
  customer_name   varchar(30)   default ''               comment '客户姓名',
  phonenumber     varchar(11)   default ''               comment '手机号码',
  sex             varchar(20)   default null             comment '客户性别',
  birthday        datetime                               comment '客户生日',
  remark          varchar(500)  default null             comment '客户描述',
  primary key (customer_id)
) engine=innodb comment = '客户表';

-- 子表：商品
create table sys_goods (
  goods_id        bigint(20)    not null auto_increment  comment '商品id',
  customer_id     bigint(20)    not null                 comment '客户id',
  name            varchar(30)   default ''               comment '商品名称',
  weight          int(5)        default null             comment '商品重量',
  price           decimal(6,2)  default null             comment '商品价格',
  date            datetime                               comment '商品时间',
  type            char(1)       default null             comment '商品种类',
  primary key (goods_id)
) engine=innodb comment = '商品表';
```

**YAML 配置**：

```yaml
global:
  author: lihd
  packageName: com.fjtcmd.hub.demo
  autoRemovePre: true
  tablePrefix: sys_
  tplCategory: crud           # 使用 crud 模板，通过 hasSubTable/isSubTable 控制
  tplWebType: element-plus-typescript
  formColNum: 2
  parentMenuId: 2006
  genView: true
  output: docs/generator/demo/customer/output
  allowOverwrite: true

tables:
  # ========== 主表：客户 ==========
  sys_customer:
    functionName: 客户信息
    orderNum: 1
    hasSubTable: true           # 标记有子表
    subTable:
      className: Goods          # 子表类名
      businessName: goods       # 子表业务名
      subRoute: customer-goods  # 子表路由路径
      functionName: 商品        # 子表功能名
      fkName: customer_id       # 外键列名
      fkJavaField: customerId   # 外键Java字段名
      permissionPrefix: goods   # 子表权限前缀
    columns:
      customer_id:
        isList: true
        isQuery: false
      customer_name:
        queryType: LIKE
      sex:
        htmlType: select
        dictType: sys_user_sex
      birthday:
        queryType: BETWEEN

  # ========== 子表：商品 ==========
  sys_goods:
    functionName: 商品信息
    orderNum: 2
    isSubTable: true            # 标记为子表
    mainTable:
      className: Customer       # 主表类名
      businessName: customer    # 主表业务名
      tableName: sys_customer   # 主表表名
      functionName: 客户        # 主表功能名
      pkJavaField: customerId   # 主表主键字段
      nameJavaField: customerName # 主表名称字段
      fkJavaField: customerId   # 外键字段名
    columns:
      goods_id:
        isList: true
        isQuery: false
      customer_id:
        isList: false
        isQuery: false
      name:
        queryType: LIKE
      weight:
        javaType: Long
        isQuery: false
      date:
        htmlType: datetime
        queryType: BETWEEN
      type:
        htmlType: select
        dictType: biz_goods_type
```

**生成结果**：

| 文件 | 说明 |
|------|------|
| `customer/index.vue` | 主表页面，包含"商品管理"按钮 |
| `goods/index.vue` | 子表页面，包含客户下拉框和关闭按钮 |
| `route-index-bak.ts` | 路由配置片段（需手动添加到 router/index.ts） |
| `customerMenu.sql` | 客户菜单 + 商品权限按钮（子表不生成独立菜单） |

**权限结构**：
```
客户信息 (C 类型菜单)
├── 客户查询 (F)
├── 客户新增 (F)
├── 客户修改 (F)
├── 客户删除 (F)
├── 客户导出 (F)
├── 商品管理 (F) ← 控制主表"商品管理"按钮显示
├── 商品查询 (F)
├── 商品新增 (F)
├── 商品修改 (F)
├── 商品删除 (F)
└── 商品导出 (F)
```

**路由配置**（需手动添加到 `src/router/index.ts` 的 `dynamicRoutes`）：

```typescript
// 客户信息 - 商品管理
{
  path: '/demo/customer-goods',
  component: Layout,
  hidden: true,
  permissions: ['demo:customer:goods:list'],
  children: [
    {
      path: 'index/:customerId(\\d+)',
      component: () => import('@/views/demo/goods/index.vue'),
      name: 'Goods',
      meta: {
        title: '商品管理',
        activeMenu: '/demo/customer'
      }
    }
  ]
}
```

---

### 主子表内嵌模式（旧设计，tplCategory: sub）

适用于一对多关系的两张表，子表在主表对话框中内嵌编辑。

> **注意**：推荐使用上面的"独立页面模式"，交互体验更好。

**主子表特有配置**：

| 配置 | 说明 |
|------|------|
| `subTableName` | 子表的数据库表名 |
| `subTableFkName` | 子表中关联主表的外键列名 |

**DDL 示例**（`docs/generator/demo/customer/config/create_customer.sql`）：

```sql
drop table if exists sys_customer;
create table sys_customer (
  customer_id     bigint(20)    not null auto_increment  comment '客户id',
  customer_name   varchar(30)   default ''               comment '客户姓名',
  phonenumber     varchar(11)   default ''               comment '手机号码',
  sex             varchar(20)   default null              comment '客户性别',
  birthday        datetime                               comment '客户生日',
  remark          varchar(500)  default null              comment '客户描述',
  primary key (customer_id)
) engine=innodb auto_increment=1 comment = '客户表';

drop table if exists sys_goods;
create table sys_goods (
  goods_id        bigint(20)    not null auto_increment  comment '商品id',
  customer_id     bigint(20)    not null                  comment '客户id',
  name            varchar(30)   default ''               comment '商品名称',
  weight          int(5)        default null              comment '商品重量',
  price           decimal(6,2)  default null              comment '商品价格',
  date            datetime                               comment '商品时间',
  type            char(1)       default null              comment '商品种类',
  primary key (goods_id)
) engine=innodb auto_increment=1 comment = '商品表';
```

**YAML 配置**（`docs/generator/demo/customer/config/generator.yml`）：

```yaml
global:
  author: lihd
  packageName: com.fjtcmd.hub.demo
  autoRemovePre: true
  tablePrefix: sys_
  tplCategory: sub
  tplWebType: element-plus-typescript
  formColNum: 24
  parentMenuId: 2006
  genView: true
  output: docs/generator/demo/customer/output
  allowOverwrite: true

tables:
  sys_customer:
    functionName: 客户信息表
    subTableName: sys_goods
    subTableFkName: customer_id
    columns:
      customer_id:
        isList: false
        isQuery: false
        isRequired: false
      customer_name:
        queryType: LIKE
      phonenumber:
        queryType: LIKE
      sex:
        htmlType: select
        dictType: sys_user_sex
      birthday:
        queryType: BETWEEN
      remark:
        isList: false
        isQuery: false

  # 子表配置
  sys_goods:
    functionName: 商品信息
    columns:
      customer_id:
        isList: false
      weight:
        javaType: Long
      type:
        columnComment: 商品种类（0食品 1日用品 2电子产品 3其他）
        htmlType: select
        dictType: biz_goods_type
```

**要点**：
- DDL 中需同时包含主表和子表两条 `CREATE TABLE` 语句
- `subTableName` 和 `subTableFkName` 在主表配置中指定
- 子表的列级配置在 `tables.{子表名}.columns` 下单独配置
- `formColNum: 24` 表示表单使用单列全宽布局（子表内嵌编辑场景）
- 子表的外键列（`customer_id`）设为 `isList: false`，不生成 `@Excel` 注解

---

## @Excel 注解生成规则

实体类中的 `@Excel` 注解由模板根据列属性自动生成，规则如下：

| 条件 | 生成的注解 |
|------|----------|
| `isList = false` | **不生成** @Excel |
| 列注释含"（）"枚举值 | `@Excel(name = "xxx", readConverterExp = "0=男,1=女")` |
| Java 类型为 `Date` | `@Excel(name = "xxx", width = 30, dateFormat = "yyyy-MM-dd")` |
| 其他 | `@Excel(name = "xxx")` |

**readConverterExp 推导**：从 `columnComment` 中提取全角括号"（）"内的内容，格式为 `值=文本`，多个用逗号分隔。

示例：
```
DDL 注释：商品种类（0食品 1日用品 2电子产品 3其他）
                    ↓ 自动提取
@Excel(name = "商品种类", readConverterExp = "0=食品,1=日用品,2=电子产品,3=其他")
```

> 如需 `readConverterExp`，必须在 YAML 中通过 `columnComment` 提供含"（）"的注释。DDL 中的 comment 如果没有枚举值，则不会生成。

---

## 生成的文件清单

以 CRUD + TypeScript 模式为例：

| 文件 | 说明 | crud | tree | sub | crud+hasSubTable |
|------|------|:----:|:----:|:---:|:----------------:|
| `main/java/.../domain/{ClassName}.java` | 实体类 | ✅ | ✅ | ✅ | ✅ |
| `main/java/.../domain/{SubClassName}.java` | 子表实体类 | — | — | ✅ | ✅ |
| `main/java/.../mapper/{ClassName}Mapper.java` | Mapper 接口 | ✅ | ✅ | ✅ | ✅ |
| `main/java/.../mapper/{SubClassName}Mapper.java` | 子表 Mapper | — | — | — | ✅ |
| `main/java/.../service/I{ClassName}Service.java` | Service 接口 | ✅ | ✅ | ✅ | ✅ |
| `main/java/.../service/I{SubClassName}Service.java` | 子表 Service | — | — | — | ✅ |
| `main/java/.../service/impl/{ClassName}ServiceImpl.java` | Service 实现 | ✅ | ✅ | ✅ | ✅ |
| `main/java/.../service/impl/{SubClassName}ServiceImpl.java` | 子表 Service 实现 | — | — | — | ✅ |
| `main/java/.../controller/{ClassName}Controller.java` | REST 控制器 | ✅ | ✅ | ✅ | ✅ |
| `main/java/.../controller/{SubClassName}Controller.java` | 子表控制器 | — | — | — | ✅ |
| `main/resources/mapper/{module}/{ClassName}Mapper.xml` | MyBatis XML | ✅ | ✅ | ✅ | ✅ |
| `main/resources/mapper/{module}/{SubClassName}Mapper.xml` | 子表 MyBatis XML | — | — | — | ✅ |
| `{businessName}Menu.sql` | 菜单权限 SQL | ✅ | ✅ | ✅ | ✅ (含子表权限) |
| `vue/api/{module}/{business}.ts` | 前端 API | ✅ | ✅ | ✅ | ✅ |
| `vue/types/api/{module}/{business}.ts` | TS 类型定义 | ✅ | ✅ | ✅ | ✅ |
| `vue/views/{module}/{business}/index.vue` | 列表+表单页 | ✅ | ✅ | ✅ | ✅ |
| `vue/views/{module}/{subBusiness}/index.vue` | 子表页面 | — | — | — | ✅ |
| `vue/views/{module}/{business}/view.vue` | 详情页抽屉 | genView | genView | genView | genView |
| `vue/route-index-bak.ts` | 路由配置片段 | — | — | — | ✅ |

> - **tree** 模板的实体类继承 `TreeEntity`（含 parentId、ancestors、children 等字段），其他继承 `BaseEntity`
> - **sub** (旧设计) 模板的子表代码嵌入在主表中一起生成，不独立生成 Controller/Service
> - **crud+hasSubTable** (新设计) 模板的主表和子表都生成完整的 CRUD 代码

---

## 项目结构

```
src/main/java/com/fjtcmd/hub/generator/cli/
├── GeneratorCli.java      # 主入口：解析命令行参数，串联各步骤
├── DdlParser.java         # DDL SQL 解析器：使用 Druid Parser 解析 CREATE TABLE
├── GenCliConfig.java      # YAML 配置模型：GlobalConfig / TableConfig / ColumnConfig
├── ConfigLoader.java      # 配置加载器：三层覆盖（全局→表级→列级）+ null 归一化
└── CodeWriter.java        # 代码输出器：渲染 Velocity 模板，写入目录或 stdout
```

**执行流程**：

```
命令行参数解析
    ↓
加载 YAML 配置 (ConfigLoader.load)
    ↓
将 global 配置写入 GenConfig 静态字段 (ConfigLoader.applyGlobalToGenConfig)
    ↓
DDL 解析 → GenTable + GenTableColumn (DdlParser.parse)
    ↓
GenUtils.initTable / initColumnField（自动推断 Java 类型、HTML 组件等）
    ↓
YAML 三层覆盖 (ConfigLoader.applyConfig)
    ↓
null 归一化（dictType null → ""）
    ↓
渲染 Velocity 模板 → 输出文件 (CodeWriter.writeToDir / preview)
```

## Demo 示例

| 模板类型 | DDL | YAML | 输出 |
|---------|-----|------|------|
| 单表 CRUD | `docs/generator/demo/student/config/create_student.sql` | `docs/generator/demo/student/config/generator.yml` | `docs/generator/demo/student/output/` |
| 树表 tree | `docs/generator/demo/product/config/create_product.sql` | `docs/generator/demo/product/config/generator.yml` | `docs/generator/demo/product/output/` |
| 主子表独立页面 | `docs/generator/demo/customer/config/create_customer.sql` | `docs/generator/demo/customer/config/generator.yml` | `docs/generator/demo/customer/output/` |

---

## 常见问题

### Q1: 主子表应该选择哪种模式？

推荐使用**独立页面模式**（`hasSubTable: true` + `isSubTable: true`），优点：
- 子表有独立的列表页面，支持分页、搜索、导出
- 交互更清晰，适合子表数据量较大的场景
- 子表可独立维护

旧的内嵌模式（`tplCategory: sub`）适合子表数据量小、字段少的场景。

### Q2: 子表权限标识是什么格式？

独立页面模式的权限标识格式为：`{模块}:{主表业务名}:{子表业务名}:{操作}`

例如：`demo:customer:goods:list`、`demo:customer:goods:add`

### Q3: 如何添加子表路由？

生成代码后，会在输出目录生成 `vue/route-index-bak.ts` 文件，内容是需要添加到 `src/router/index.ts` 的 `dynamicRoutes` 数组中的路由配置。手动复制粘贴即可。

### Q4: 子表需要生成独立菜单吗？

不需要。子表的权限按钮会在主表菜单 SQL 中一起生成，挂在主表菜单下。子表（`isSubTable: true`）不会生成独立的菜单 SQL 文件。

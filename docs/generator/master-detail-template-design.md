# 主子表模板设计方案

## 一、方案概述

### 1.1 设计目标

基于字典管理的交互模式，设计一套完整的主子表代码生成方案，实现：
- 主表页面包含"子表管理"按钮，点击跳转到独立的子表管理页面
- 子表页面支持按主表筛选，具备完整的 CRUD 功能
- 权限体系完整，子表权限挂在主表菜单下
- 配置驱动，通过 YAML 配置主子表关系

### 1.2 交互设计

```
┌─────────────────────────────────────────────────────────────┐
│ 主表页面（如：客户管理）                                      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 标准 CRUD 列表                                           │ │
│ │ 操作列：[详情] [修改] [子表管理] [删除]                    │ │
│ │                      ↓ 点击跳转                          │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                    /demo/customer-goods/index/:customerId
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ 子表页面（如：商品管理）                                      │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 搜索表单：主表下拉框 + 其他搜索条件                        │ │
│ │ 工具栏：[新增] [修改] [删除] [导出] [关闭]                 │ │
│ │ 标准 CRUD 列表（按主表ID过滤）                             │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 核心特性

1. **独立页面模式**：子表管理在独立页面，不在主表弹窗中
2. **路由参数传递**：通过 URL 路径参数传递主表ID
3. **主表下拉筛选**：子表页面可切换不同主表记录
4. **权限关联**：子表权限挂在主表菜单下
5. **关闭返回**：子表页面提供"关闭"按钮返回主表

---

## 二、配置规范

### 2.1 YAML 配置结构

#### 主表配置示例

```yaml
tables:
  sys_customer:
    functionName: 客户信息
    parentMenuId: 2006        # 上级菜单ID
    orderNum: 1               # 排序号
    hasSubTable: true         # 标记有子表
    subTable:
      className: Goods        # 子表类名
      businessName: goods     # 子表业务名
      subRoute: customer-goods # 子表路由路径
      functionName: 商品       # 子表功能名
      fkName: customer_id     # 外键列名
      fkJavaField: customerId # 外键Java字段
      permissionPrefix: goods # 子表权限前缀（相对于主表）
```

#### 子表配置示例

```yaml
tables:
  sys_goods:
    functionName: 商品信息
    isSubTable: true          # 标记为子表
    mainTable:
      className: Customer     # 主表类名
      businessName: customer  # 主表业务名
      tableName: sys_customer # 主表表名
      functionName: 客户      # 主表功能名
      pkJavaField: customerId # 主表主键字段
      nameJavaField: customerName # 主表名称字段
```

**注意：** 子表配置中**不需要**重复定义外键字段，外键信息从主表的 `subTable` 配置中获取。

### 2.2 配置字段说明

#### 主表新增字段（hasSubTable: true 时）

| 字段路径 | 类型 | 必填 | 说明 | 示例 |
|---------|------|------|------|------|
| `hasSubTable` | Boolean | 是 | 是否有子表 | `true` |
| `subTable.className` | String | 是 | 子表类名 | `Goods` |
| `subTable.businessName` | String | 是 | 子表业务名 | `goods` |
| `subTable.subRoute` | String | 是 | 子表路由路径 | `customer-goods` |
| `subTable.functionName` | String | 是 | 子表功能名（中文） | `商品` |
| `subTable.fkName` | String | 是 | 外键列名（数据库） | `customer_id` |
| `subTable.fkJavaField` | String | 是 | 外键Java字段名 | `customerId` |
| `subTable.permissionPrefix` | String | 是 | 子表权限前缀 | `goods` |

**生成的完整权限前缀：** `${permissionPrefix}:${subTable.permissionPrefix}` → `demo:customer:goods`

#### 子表新增字段（isSubTable: true 时）

| 字段路径 | 类型 | 必填 | 说明 | 示例 |
|---------|------|------|------|------|
| `isSubTable` | Boolean | 是 | 是否是子表 | `true` |
| `mainTable.className` | String | 是 | 主表类名 | `Customer` |
| `mainTable.businessName` | String | 是 | 主表业务名 | `customer` |
| `mainTable.tableName` | String | 是 | 主表表名 | `sys_customer` |
| `mainTable.functionName` | String | 是 | 主表功能名（中文） | `客户` |
| `mainTable.pkJavaField` | String | 是 | 主表主键字段 | `customerId` |
| `mainTable.nameJavaField` | String | 是 | 主表名称字段 | `customerName` |

**外键字段来源：** 子表的外键信息从主表的 `subTable.fkName` 和 `subTable.fkJavaField` 获取，无需在子表中重复定义。

---

## 三、模板设计

### 3.1 主表模板修改（index.vue.vm）

#### 操作列增加子表管理按钮

```velocity
<el-table-column label="操作" align="center" width="280" class-name="small-padding fixed-width">
  <template #default="scope">
    <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['${permissionPrefix}:query']">详情</el-button>
    <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['${permissionPrefix}:edit']">修改</el-button>
#if($table.hasSubTable)
    <el-button link type="primary" icon="Operation" @click="handle${subTable.className}List(scope.row)" v-hasPermi="['${permissionPrefix}:${subTable.permissionPrefix}:list']">${subTable.functionName}管理</el-button>
#end
    <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['${permissionPrefix}:remove']">删除</el-button>
  </template>
</el-table-column>
```

#### Script 增加跳转函数

```velocity
#if($table.hasSubTable)
/** ${subTable.functionName}管理页面 */
function handle${subTable.className}List(row: ${ClassName}) {
  proxy.$tab.openPage("${subTable.functionName}管理", '/${moduleName}/${subTable.subRoute}/index/' + row.${pkColumn.javaField})
}
#end
```

**变量映射说明：**
- `${subTable.className}` → 子表类名（如：Goods）
- `${subTable.functionName}` → 子表功能名（如：商品）
- `${subTable.subRoute}` → 子表路由（如：customer-goods）
- `${subTable.permissionPrefix}` → 子表权限前缀（如：goods）
- 完整权限：`${permissionPrefix}:${subTable.permissionPrefix}:list` → `demo:customer:goods:list`

### 3.2 子表模板（sub-index.vue.vm）

基于 crud 模板，增加以下内容：

**变量映射说明：**
子表模板中的变量通过 ConfigLoader 从主表配置中映射得到：
- `${mainTable.functionName}` ← 从 `mainTable.functionName` 获取
- `${mainTable.businessName}` ← 从 `mainTable.businessName` 获取
- `${mainTable.className}` ← 从 `mainTable.className` 获取
- `${mainTable.pkJavaField}` ← 从 `mainTable.pkJavaField` 获取
- `${mainTable.nameJavaField}` ← 从 `mainTable.nameJavaField` 获取
- `${fkJavaField}` ← 从主表的 `subTable.fkJavaField` 获取（子表的外键字段）
- `${fkName}` ← 从主表的 `subTable.fkName` 获取

#### 搜索表单增加主表下拉框

```velocity
<el-form-item label="${mainTable.functionName}" prop="${fkJavaField}">
  <el-select 
    v-model="queryParams.${fkJavaField}" 
    placeholder="请选择${mainTable.functionName}" 
    filterable 
    clearable 
    style="width: 200px" 
    @change="handleQuery">
    <el-option 
      v-for="item in ${mainTable.businessName}Options" 
      :key="item.${mainTable.pkJavaField}" 
      :label="item.${mainTable.nameJavaField}" 
      :value="item.${mainTable.pkJavaField}" />
  </el-select>
</el-form-item>
```

#### Script 增加主表数据加载

```velocity
import type { ${mainTable.className} } from "@/types/api/${moduleName}/${mainTable.businessName}"
import { list${mainTable.className} } from "@/api/${moduleName}/${mainTable.businessName}"

const route = useRoute()

// 主表下拉选项
const ${mainTable.businessName}Options = ref<${mainTable.className}[]>([])

/** 加载主表下拉列表 */
function load${mainTable.className}Options() {
  list${mainTable.className}({ pageNum: 1, pageSize: 1000 }).then(response => {
    ${mainTable.businessName}Options.value = response.rows
  })
}

onMounted(() => {
  // 加载主表下拉列表
  load${mainTable.className}Options()
  
  // 从路由参数获取主表ID
  const ${fkJavaField} = route.params.${fkJavaField}
  if (${fkJavaField}) {
    queryParams.value.${fkJavaField} = Number(${fkJavaField})
  }
  
  getList()
  calcTableHeight()
  window.addEventListener('resize', calcTableHeight)
})
```

#### 新增时自动填充主表ID

```velocity
function handleAdd() {
  reset()
  // 自动填充当前选中的主表ID
  form.value.${fkJavaField} = queryParams.value.${fkJavaField}
  open.value = true
  title.value = "添加${functionName}"
}
```

#### 列表查询增加主表ID校验

```velocity
function getList() {
  // 如果没有选择主表，不查询
  if (!queryParams.value.${fkJavaField}) {
    ${businessName}List.value = []
    total.value = 0
    loading.value = false
    return
  }
  
  loading.value = true
  // ... 原有查询逻辑
}
```

#### 工具栏增加关闭按钮

```velocity
<el-col :span="1.5">
  <el-button type="warning" plain icon="Close" @click="handleClose">关闭</el-button>
</el-col>
```

```velocity
/** 关闭 - 返回主表列表 */
function handleClose() {
  const obj = { path: "/${moduleName}/${mainTable.businessName}" }
  proxy.$tab.closeOpenPage(obj)
}
```

### 3.3 路由配置

采用**代码片段备份文件**方式，生成 `route-index-bak.ts` 文件，包含需要插入到 `router/index.ts` 的 `dynamicRoutes` 数组中的路由代码片段。

**生成方式：** 在 CodeWriter.java 中，当检测到 `$table.hasSubTable` 为 true 时，生成 `route-index-bak.ts` 文件。

#### 路由模板（route-index-bak.ts.vm）

```typescript
// ============================================================
// 子表路由配置（需要手动插入到 router/index.ts 的 dynamicRoutes 中）
// ============================================================

// ${functionName} - ${mainTable.functionName}${subTable.functionName}管理
{
  path: '/${moduleName}/${subTable.subRoute}',
  component: Layout,
  hidden: true,
  permissions: ['${permissionPrefix}:${subTable.permissionPrefix}:list'],
  children: [
    {
      path: 'index/:${subTable.fkJavaField}(\\d+)',
      component: () => import('@/views/${moduleName}/${subTable.businessName}/index.vue'),
      name: '${subTable.className}',
      meta: { 
        title: '${subTable.functionName}管理', 
        activeMenu: '/${moduleName}/${mainTable.businessName}' 
      }
    }
  ]
}
```

#### 使用说明

1. 生成代码后，在输出目录中会生成 `route-index-bak.ts` 文件
2. 打开 `src/router/index.ts` 文件
3. 找到 `dynamicRoutes` 数组
4. 将 `route-index-bak.ts` 中的路由配置复制到 `dynamicRoutes` 数组中
5. 保存文件

#### 示例：客户-商品路由

生成的 `route-index-bak.ts` 内容：

```typescript
// ============================================================
// 子表路由配置（需要手动插入到 router/index.ts 的 dynamicRoutes 中）
// ============================================================

// 商品信息 - 客户商品管理
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

#### 优势

1. **安全性**：不会覆盖现有的路由配置
2. **可控性**：开发者可以审查和修改生成的路由代码
3. **灵活性**：可以根据需要调整路由配置
4. **可追溯**：保留了原始的路由配置备份

---

## 四、API 和类型定义

### 4.1 API 模板（api.ts.vm）

**无需修改。** 主子表的 API 生成逻辑与标准 CRUD 相同，不需要特殊处理。

- 主表 API：生成标准的 CRUD 接口
- 子表 API：生成标准的 CRUD 接口，包含外键字段的查询参数

### 4.2 类型定义模板（type.ts.vm）

**无需修改。** 类型定义模板会自动处理所有字段，包括外键字段。

- 主表类型：包含所有字段（如果有子表，可包含 `List<SubClass>` 字段）
- 子表类型：包含所有字段，包括外键字段

**示例：**

```typescript
// 主表类型（customer.ts）
export interface Customer extends BaseEntity {
  customerId?: number;
  customerName?: string;
  // ... 其他字段
  goodsList?: Goods[];  // 可选：如果需要一次性加载子表数据
}

// 子表类型（goods.ts）
export interface Goods extends BaseEntity {
  goodsId?: number;
  customerId?: number;  // 外键字段
  name?: string;
  // ... 其他字段
}
```

---

## 五、配置校验规则

### 5.1 主表配置校验

当 `hasSubTable: true` 时，必须校验以下配置：

| 配置项 | 校验规则 | 错误提示 |
|--------|---------|---------|
| `subTable.className` | 必填，非空字符串 | "子表类名不能为空" |
| `subTable.businessName` | 必填，非空字符串 | "子表业务名不能为空" |
| `subTable.subRoute` | 必填，符合路由命名规范 | "子表路由路径不能为空" |
| `subTable.functionName` | 必填，非空字符串 | "子表功能名不能为空" |
| `subTable.fkName` | 必填，非空字符串 | "外键列名不能为空" |
| `subTable.fkJavaField` | 必填，非空字符串 | "外键Java字段不能为空" |
| `subTable.permissionPrefix` | 必填，非空字符串 | "子表权限前缀不能为空" |

### 5.2 子表配置校验

当 `isSubTable: true` 时，必须校验以下配置：

| 配置项 | 校验规则 | 错误提示 |
|--------|---------|---------|
| `mainTable.className` | 必填，非空字符串 | "主表类名不能为空" |
| `mainTable.businessName` | 必填，非空字符串 | "主表业务名不能为空" |
| `mainTable.tableName` | 必填，非空字符串 | "主表表名不能为空" |
| `mainTable.functionName` | 必填，非空字符串 | "主表功能名不能为空" |
| `mainTable.pkJavaField` | 必填，非空字符串 | "主表主键字段不能为空" |
| `mainTable.nameJavaField` | 必填，非空字符串 | "主表名称字段不能为空" |

### 5.3 关联校验

当同时存在主表和子表配置时，需要校验关联关系：

1. **主表声明有子表**：必须有对应的子表配置（`isSubTable: true`）
2. **子表声明有主表**：必须有对应的主表配置（`hasSubTable: true`）
3. **外键字段一致性**：主表的 `subTable.fkJavaField` 必须与子表的实际外键字段匹配

**校验逻辑示例：**

```java
// 在 ConfigLoader 中添加校验逻辑
if (mainTableConfig.hasSubTable) {
    // 查找对应的子表配置
    GenCliConfig.TableConfig subTableConfig = findSubTableConfig(subTableName);
    if (subTableConfig == null || !subTableConfig.isSubTable) {
        throw new ConfigException("主表声明有子表，但未找到对应的子表配置");
    }
    
    // 校验外键字段
    if (!mainTableConfig.subTable.fkName.equals(subTableConfig.getActualFkName())) {
        throw new ConfigException("主表配置的外键字段与子表实际外键不匹配");
    }
}
```

### 5.4 权限校验

1. **权限前缀格式**：`subTable.permissionPrefix` 只能包含字母、数字、下划线
2. **权限唯一性**：生成的完整权限 `${permissionPrefix}:${subTable.permissionPrefix}` 不能与其他权限冲突
3. **权限长度**：完整权限字符串长度不能超过 100 字符

---

## 六、菜单权限设计

### 6.1 菜单结构

```
客户管理（C 类型菜单，menu_id=2055）
├── 客户查询（F 类型按钮）
├── 客户新增（F 类型按钮）
├── 客户修改（F 类型按钮）
├── 客户删除（F 类型按钮）
├── 客户导出（F 类型按钮）
├── 商品管理（F 类型按钮）← 控制主表中"商品管理"按钮的显示
├── 商品查询（F 类型按钮）
├── 商品新增（F 类型按钮）
├── 商品修改（F 类型按钮）
├── 商品删除（F 类型按钮）
└── 商品导出（F 类型按钮）
```

### 6.2 权限标识规范

#### 主表权限
- `${permissionPrefix}:list` - 列表
- `${permissionPrefix}:query` - 查询
- `${permissionPrefix}:add` - 新增
- `${permissionPrefix}:edit` - 修改
- `${permissionPrefix}:remove` - 删除
- `${permissionPrefix}:export` - 导出

示例：`demo:customer:list`, `demo:customer:query`

#### 子表权限
- `${permissionPrefix}:${subBusinessName}:list` - 管理（控制按钮显示）
- `${permissionPrefix}:${subBusinessName}:query` - 查询
- `${permissionPrefix}:${subBusinessName}:add` - 新增
- `${permissionPrefix}:${subBusinessName}:edit` - 修改
- `${permissionPrefix}:${subBusinessName}:remove` - 删除
- `${permissionPrefix}:${subBusinessName}:export` - 导出

示例：`demo:customer:goods:list`, `demo:customer:goods:query`

### 6.3 菜单 SQL 生成模板

**注意：** 菜单 SQL 模板修改，在生成主表菜单时，如果 `hasSubTable` 为 true，则额外生成子表权限按钮。

```velocity
-- 主表菜单
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${functionName}', '${parentMenuId}', '${orderNum}', '${businessName}', '${moduleName}/${businessName}/index', 1, 0, 'C', '0', '0', '${permissionPrefix}:list', '#', 'admin', sysdate(), '${functionName}菜单');

-- 获取主表菜单ID
SELECT @mainMenuId := LAST_INSERT_ID();

-- 主表按钮权限
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${functionName}查询', @mainMenuId, 1, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:query', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${functionName}新增', @mainMenuId, 2, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:add', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${functionName}修改', @mainMenuId, 3, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:edit', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${functionName}删除', @mainMenuId, 4, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:remove', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${functionName}导出', @mainMenuId, 5, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:export', '#', 'admin', sysdate(), '');

#if($table.hasSubTable)
-- ========== 子表权限按钮 ==========
-- 注意：子表权限的 parent_id 是主表菜单ID（@mainMenuId），确保权限层级正确
insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${subTable.functionName}管理', @mainMenuId, 6, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:${subTable.permissionPrefix}:list', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${subTable.functionName}查询', @mainMenuId, 7, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:${subTable.permissionPrefix}:query', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${subTable.functionName}新增', @mainMenuId, 8, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:${subTable.permissionPrefix}:add', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${subTable.functionName}修改', @mainMenuId, 9, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:${subTable.permissionPrefix}:edit', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${subTable.functionName}删除', @mainMenuId, 10, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:${subTable.permissionPrefix}:remove', '#', 'admin', sysdate(), '');

insert into sys_menu (menu_name, parent_id, order_num, path, component, is_frame, is_cache, menu_type, visible, status, perms, icon, create_by, create_time, remark)
values('${subTable.functionName}导出', @mainMenuId, 11, '#', '', 1, 0, 'F', '0', '0', '${permissionPrefix}:${subTable.permissionPrefix}:export', '#', 'admin', sysdate(), '');
#end
```

**菜单 parent_id 说明：**
- 主表菜单：使用 YAML 配置中的 `parentMenuId`
- 主表按钮：使用主表菜单ID（@mainMenuId）
- 子表按钮：使用主表菜单ID（@mainMenuId），确保子表权限在主表菜单下

### 6.4 权限分配

#### 分配流程

菜单权限生成后，需要由管理员在系统后台手动分配给角色：

1. **登录系统**：使用管理员账号登录系统后台
2. **进入角色管理**：导航到【系统管理】→【角色管理】
3. **选择角色**：点击需要分配权限的角色（如：管理员、普通用户等）
4. **分配菜单**：在弹出的菜单权限树中，勾选新生成的主表和子表菜单
5. **保存权限**：点击确定保存角色的菜单权限

#### 分配示例

以"客户-商品"主子表为例，需要分配的菜单包括：

```
☑ 客户管理（主菜单）
  ☑ 客户查询
  ☑ 客户新增
  ☑ 客户修改
  ☑ 客户删除
  ☑ 客户导出
  ☑ 商品管理（子表管理按钮权限）
  ☑ 商品查询
  ☑ 商品新增
  ☑ 商品修改
  ☑ 商品删除
  ☑ 商品导出
```

#### 权限验证

分配完成后，可以通过以下方式验证权限是否生效：

1. **退出重新登录**：使权限缓存生效
2. **检查菜单显示**：确认主表菜单和子表管理按钮正常显示
3. **测试功能操作**：验证增删改查等功能是否正常工作
4. **检查权限控制**：确认无权限的操作按钮已隐藏

#### 注意事项

1. **权限继承**：子表权限必须与主表权限一起分配，否则子表功能无法正常使用
2. **角色区分**：不同角色可以分配不同的菜单权限，实现细粒度的权限控制
3. **权限缓存**：修改权限后，用户需要退出重新登录才能生效
4. **超级管理员**：超级管理员（admin）默认拥有所有权限，无需手动分配

### 6.5 权限使用位置

权限标识在前端代码中的使用示例：

#### 主表页面

```vue
<!-- 操作列中的子表管理按钮 -->
<el-button 
    link 
    type="primary" 
    icon="Operation" 
    @click="handleGoodsList(scope.row)" 
    v-hasPermi="['demo:customer:goods:list']">
    商品管理
</el-button>
```

#### 子表页面

```vue
<!-- 工具栏按钮 -->
<el-button v-hasPermi="['demo:customer:goods:add']">新增</el-button>
<el-button v-hasPermi="['demo:customer:goods:edit']">修改</el-button>
<el-button v-hasPermi="['demo:customer:goods:remove']">删除</el-button>
<el-button v-hasPermi="['demo:customer:goods:export']">导出</el-button>

<!-- 操作列按钮 -->
<el-button v-hasPermi="['demo:customer:goods:query']">详情</el-button>
<el-button v-hasPermi="['demo:customer:goods:edit']">修改</el-button>
<el-button v-hasPermi="['demo:customer:goods:remove']">删除</el-button>
```

---

## 七、代码改动分析

### 7.1 需要修改的文件清单

#### 后端 Java 代码（fjtcmd-hub-generator-cli）

| 文件 | 改动类型 | 改动量 | 说明 |
|------|---------|--------|------|
| GenCliConfig.java | 修改 | ~80行 | 添加子表配置模型 |
| ConfigLoader.java | 修改 | ~50行 | 处理子表配置，建立关联 |
| CodeWriter.java | 修改 | ~20行 | 模板选择逻辑 |

#### Velocity 模板（fjtcmd-hub-generator/src/main/resources/vm）

| 文件 | 改动类型 | 改动量 | 说明 |
|------|---------|--------|------|
| vm/vue/v3ts/index.vue.vm | 修改 | ~30行 | 添加子表按钮和函数 |
| vm/vue/v3ts/sub-index.vue.vm | 新建 | ~400行 | 子表模板 |
| vm/vue/v3/index.vue.vm | 修改 | ~30行 | 添加子表按钮和函数 |
| vm/vue/v3/sub-index.vue.vm | 新建 | ~380行 | 子表模板（JS版） |
| vm/vue/index.vue.vm | 修改 | ~30行 | 添加子表按钮和函数 |
| vm/vue/sub-index.vue.vm | 新建 | ~380行 | 子表模板（Vue2版） |
| vm/sql/menu.sql.vm | 修改 | ~50行 | 添加子表权限生成 |

#### 总计

| 类别 | 文件数 | 新建 | 修改 | 总代码量 |
|------|--------|------|------|----------|
| Java 后端 | 3 | 0 | 3 | ~150 行 |
| Vue3 TS 模板 | 2 | 1 | 1 | ~430 行 |
| Vue3 JS 模板 | 2 | 1 | 1 | ~410 行 |
| Vue2 模板 | 2 | 1 | 1 | ~410 行 |
| SQL 模板 | 1 | 0 | 1 | ~50 行 |
| **总计** | **11** | **3** | **8** | **~1450 行** |

### 7.2 工期估算

| 阶段 | 内容 | 工期 |
|------|------|------|
| 阶段一 | 基础框架（配置模型、主表模板） | 1-2天 |
| 阶段二 | 子表模板（v3ts版本） | 2-3天 |
| 阶段三 | 多版本支持（Vue3 JS、Vue2） | 1-2天 |
| 阶段四 | 完善和测试 | 1天 |
| **总计** | | **5-8天** |

---

## 八、实施建议

### 8.1 兜底方案

#### 8.1.1 工程备份策略

**在开始实施前，必须完成以下备份：**

1. **Git 备份（推荐）**
   ```bash
   # 创建备份分支
   git checkout -b backup/before-master-detail-template
   
   # 提交当前状态
   git add .
   git commit -m "备份：主子表模板实施前的完整状态"
   
   # 推送备份分支到远程
   git push origin backup/before-master-detail-template
   ```

2. **目录备份（备选）**
   ```bash
   # 备份时间戳
   BACKUP_TIME=$(date +%Y%m%d_%H%M%S)
   
   # 备份整个工程
   cd /home/workspaces/com/ztq/tcmd
   tar -czf fjtcmd-hub_backup_${BACKUP_TIME}.tar.gz fjtcmd-hub/
   
   # 验证备份文件
   ls -lh fjtcmd-hub_backup_${BACKUP_TIME}.tar.gz
   ```

3. **关键文件备份清单**
   
   以下文件在修改前需要单独备份：
   - `fjtcmd-hub-generator-cli/src/main/java/com/fjtcmd/hub/generator/cli/GenCliConfig.java`
   - `fjtcmd-hub-generator-cli/src/main/java/com/fjtcmd/hub/generator/cli/ConfigLoader.java`
   - `fjtcmd-hub-generator-cli/src/main/java/com/fjtcmd/hub/generator/cli/CodeWriter.java`
   - `fjtcmd-hub-generator/src/main/resources/vm/vue/v3ts/index.vue.vm`
   - `fjtcmd-hub-generator/src/main/resources/vm/vue/v3/index.vue.vm`
   - `fjtcmd-hub-generator/src/main/resources/vm/vue/index.vue.vm`
   - `fjtcmd-hub-generator/src/main/resources/vm/sql/menu.sql.vm`

#### 8.1.2 回滚方案

**如果实施过程中出现严重问题，按以下步骤回滚：**

1. **Git 回滚**
   ```bash
   # 切回主分支
   git checkout master
   
   # 从备份分支恢复
   git checkout backup/before-master-detail-template -- .
   
   # 或者硬重置到备份点
   git reset --hard backup/before-master-detail-template
   ```

2. **目录恢复**
   ```bash
   # 删除当前工程
   rm -rf fjtcmd-hub/
   
   # 解压备份
   tar -xzf fjtcmd-hub_backup_XXXXXXXX_XXXXXX.tar.gz
   ```

3. **验证恢复**
   ```bash
   # 编译后端
   cd fjtcmd-hub
   ./scripts/build/backend.sh clean-install
   
   # 编译前端
   ./scripts/build/frontend.sh install
   
   # 启动服务验证
   ./scripts/dev/backend.sh start
   ./scripts/dev/frontend.sh start
   ```

#### 8.1.3 渐进式实施策略

**为降低风险，采用分阶段实施：**

| 阶段 | 内容 | 验证点 | 回滚点 |
|------|------|--------|--------|
| **阶段0** | 工程备份 | 备份文件完整性检查 | - |
| **阶段1** | 配置模型修改 | 编译通过，不影响现有功能 | 可回滚 |
| **阶段2** | 主表模板修改 | 生成现有 CRUD 代码正常 | 可回滚 |
| **阶段3** | 子表模板创建 | 生成子表代码正常 | 可回滚 |
| **阶段4** | 路由和菜单生成 | 路由配置正确，菜单SQL正确 | 可回滚 |
| **阶段5** | 完整测试 | 生成客户-商品案例完整可用 | 可回滚 |

**每个阶段的验证标准：**

```bash
# 阶段1验证：编译通过
cd fjtcmd-hub-generator-cli
mvn clean compile

# 阶段2验证：生成现有代码正常
java -jar target/fjtcmd-hub-generator-cli.jar \
  --config ../docs/generator/demo/customer/config/generator.yml \
  --sql ../docs/generator/demo/customer/config/create_customer.sql
# 检查生成的代码与修改前一致

# 阶段3验证：生成子表代码
# 创建子表测试配置并生成，检查代码结构正确

# 阶段4验证：检查生成的文件
ls -la output/route-index-bak.ts
ls -la output/customerMenu.sql
# 检查文件内容正确

# 阶段5验证：完整功能测试
# 1. 生成客户-商品代码
# 2. 复制到项目
# 3. 编译后端
# 4. 启动前后端
# 5. 测试客户列表 → 商品管理跳转 → 商品CRUD
```

### 8.2 渐进式开发

1. **先做 MVP**：先实现 v3ts 版本的主表和子表模板，验证可行性
2. **渐进式开发**：不要一次性实现所有版本，逐个版本推进
3. **充分测试**：每个阶段都要用实际案例验证
4. **文档先行**：先写好配置示例和使用说明

### 8.3 风险评估

1. **模板复杂度**：子表模板较为复杂，需要仔细处理各种边界情况
2. **配置验证**：需要确保主表和子表配置的一致性
3. **向后兼容**：需要确保不影响现有的 CRUD 和 tree 模板
4. **测试覆盖**：需要生成多种场景的代码进行验证

---

## 九、参考案例

### 9.1 客户-商品案例

已有的实现案例：
- 主表：客户管理（sys_customer）
- 子表：商品管理（sys_goods）
- 路由：`/demo/customer-goods/index/:customerId`
- 权限：`demo:customer:goods:*`

### 9.2 字典-字典数据案例

系统内置的主子表案例：
- 主表：字典管理（sys_dict_type）
- 子表：字典数据（sys_dict_data）
- 路由：`/system/dict-data/index/:dictId`
- 权限：`system:dict:list`（复用主表权限）

---

## 十、附录

### 10.1 相关文档

- [代码生成器使用指南](../generator-cli/README.md)
- [YAML 配置说明](../generator-cli/README.md#yaml-配置详解)

### 10.2 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-06-11 | 初版方案设计 |

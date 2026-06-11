# 示例 3：Sub 主子表（客户 + 商品）

主子表独立页面模式，主表列表含"子表管理"按钮。

---

## 调用方式

```bash
/fjtcmd-hub-dev-simple 我要做一个客户管理功能，每个客户有多个商品，用独立页面展示商品。客户管理姓名、电话；商品管理名称、价格、类型
```

## 推断结果

| 项目 | 值 |
|------|-----|
| 模板类型 | Sub（主子表独立页面） |
| 主表 | sys_customer |
| 子表 | sys_goods |
| 关联字段 | goods.customer_id → customer.customer_id |

## DDL

```sql
-- 主表
create table sys_customer (
  customer_id     bigint(20)    not null auto_increment  comment '客户id',
  customer_name   varchar(30)   default ''               comment '客户姓名',
  phonenumber     varchar(11)   default ''               comment '手机号码',
  primary key (customer_id)
) engine=innodb comment = '客户表';

-- 子表
create table sys_goods (
  goods_id        bigint(20)    not null auto_increment  comment '商品id',
  customer_id     bigint(20)    not null                 comment '客户id',
  name            varchar(30)   default ''               comment '商品名称',
  price           decimal(6,2)  default null             comment '商品价格',
  type            char(1)       default null             comment '商品种类',
  primary key (goods_id)
) engine=innodb comment = '商品表';
```

## YAML 配置关键

```yaml
global:
  tplCategory: crud  # 注意：用 crud 模板，通过 hasSubTable/isSubTable 控制

tables:
  # 主表配置
  sys_customer:
    hasSubTable: true
    subTable:
      className: Goods
      businessName: goods
      subRoute: customer-goods
      functionName: 商品
      fkName: customer_id
      fkJavaField: customerId
      permissionPrefix: goods

  # 子表配置
  sys_goods:
    isSubTable: true
    mainTable:
      className: Customer
      businessName: customer
      tableName: sys_customer
      functionName: 客户
      pkJavaField: customerId
      nameJavaField: customerName
      fkJavaField: customerId
```

## 交互设计

```
┌─────────────────────────────────────────┐
│ 客户列表                                │
│ 操作列：[详情] [修改] [商品管理] [删除] │
│                      ↓ 点击跳转         │
└─────────────────────────────────────────┘
           /demo/customer-goods/index/:customerId
                     ↓
┌─────────────────────────────────────────┐
│ 商品列表（当前客户：张三）              │
│ 搜索：[客户下拉框] + 商品名称           │
│ 工具栏：[新增] [修改] [删除] [导出] [关闭]│
└─────────────────────────────────────────┘
```

## 生成文件

- 主表：customer/{index,view}.vue + 完整后端
- 子表：goods/index.vue + 完整后端
- 路由：`route-index-bak.ts`（自动集成到 dynamicRoutes）
- 权限：子表权限挂在主表菜单下（如 `demo:customer:goods:list`）

## 测试

```bash
# 模拟数据：主表 20 条 + 每主表 20 条子表 = 420 条
```

---

**要点**：主子表独立页面模式需要同时配置 hasSubTable 和 isSubTable；路由会自动集成。

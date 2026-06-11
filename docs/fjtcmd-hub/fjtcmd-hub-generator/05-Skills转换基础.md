# 05 - Skills 转换基础

## 5.1 本质分析

fjtcmd-hub-generator 的本质是一个 **模板引擎 + 元数据管理** 系统：

```
输入: 数据库表结构 + 用户配置参数
       │
       ▼
处理: Velocity 模板渲染
       │
       ▼
输出: 前后端 CRUD 代码文件
```

核心依赖链：
1. **元数据源** — `information_schema` 提供表结构和列信息
2. **元数据存储** — `gen_table` + `gen_table_column` 存储用户配置
3. **推断规则** — `GenUtils` 自动推断 Java 类型、HTML 类型、查询方式
4. **模板变量构建** — `VelocityUtils` 将元数据转换为 VelocityContext
5. **模板渲染** — 22 个 `.vm` 文件输出最终代码

## 5.2 可转换为 Skills 的能力点

### 能力 1：数据库表 → CRUD 代码生成

这是现有 generator 的核心能力，可以直接封装为 skill：

```
输入: 表名（或 CREATE TABLE 语句）
配置: packageName, moduleName, businessName, functionName, author,
      tplCategory, tplWebType, formColNum
输出: 后端 Java 代码 + 前端 Vue 代码 + SQL 脚本
```

**优势**：不依赖运行中的 Web 服务，可以在任何环境执行。

### 能力 2：自然语言描述 → CRUD 代码生成

这是 skill 相比 Web UI 的**增量价值**：

```
输入: "帮我生成一个商品管理模块，包含商品名称、价格、库存、分类、上架状态"
处理: AI 推断 →
  ├── 表名: `shop_product`（或 `fjtcmd_商品` 根据项目前缀规范）
  ├── 字段:
  │   ├── productName VARCHAR(200) — 商品名称，列表+查询
  │   ├── price DECIMAL(10,2) — 价格，BigDecimal
  │   ├── stock INT — 库存
  │   ├── category_id BIGINT — 分类，下拉选择
  │   ├── status TINYINT — 上架状态，单选框
  │   └── 自动补充 create_by, create_time, update_by, update_time, remark
  ├── 推断: Java 类型、HTML 类型、查询方式、字典类型
  └── 模板渲染 → 输出代码
```

### 能力 3：代码审查与修改

生成代码后，skill 可以：

```
输入: "把商品管理的价格字段改为 BigDecimal，增加商品编码字段"
处理:
  ├── 修改 GenTableColumn 配置
  ├── 重新渲染受影响的模板
  └── 输出差异或覆盖文件
```

### 能力 4：批量生成与项目管理

```
输入: "生成门店管理模块的所有 CRUD，包括门店、员工、排班、库存"
处理:
  ├── 对每个表重复生成流程
  ├── 统一处理 TypeScript 路由入口合并
  └── 输出完整的模块代码
```

## 5.3 转换方案分析

### 方案 A：直接复用 Velocity 模板

**思路**：将 `*.vm` 模板文件和 `GenUtils` / `VelocityUtils` 的逻辑提取出来，skill 直接调用。

**优点**：
- 与现有 generator 行为完全一致，生成代码风格统一
- 模板文件无需修改
- 后续 Web UI 和 skill 共享同一套模板

**缺点**：
- 需要引入 Velocity 依赖
- 依赖 Java 环境运行
- 需要模拟 GenTable / GenTableColumn 数据结构

**适用场景**：需要与现有若依项目保持高度一致的代码风格。

### 方案 B：重新实现模板渲染（不依赖 Velocity）

**思路**：将 `.vm` 模板转换为独立的模板语言（如 Jinja2、Handlebars、或自定义替换器），skill 用 Python/Node.js/Go 等语言执行。

**优点**：
- 不依赖 Java 环境
- 更轻量，易于集成到各种 CI/CD 流程
- 模板逻辑可以更灵活

**缺点**：
- 需要手动翻译 22 个 `.vm` 模板
- 与 Web UI generator 可能存在行为差异
- 维护两套模板的成本

**适用场景**：需要在非 Java 环境中使用。

### 方案 C：AI 直接生成代码（无模板）

**思路**：不依赖模板，让 AI 根据配置参数直接生成完整的 CRUD 代码。

**优点**：
- 最灵活，可以针对具体需求调整生成的代码
- 不依赖任何模板引擎
- 可以生成更智能的代码（如自动添加业务逻辑、校验规则等）

**缺点**：
- 代码风格可能与现有项目不一致
- 每次生成结果可能有差异，不可控
- 需要大量 prompt engineering 来保证质量

**适用场景**：需要高度定制化的代码生成。

### 推荐方案：A + C 混合

- **基础 CRUD 结构**：使用方案 A，复用现有 Velocity 模板，保证代码风格和一致性
- **智能增强**：使用方案 C，AI 补充模板无法覆盖的部分（如复杂业务逻辑、自定义校验、关联查询等）
- **配置推断**：AI 从自然语言描述中推断 GenTable/GenTableColumn 配置参数，替代用户手动填写表单

## 5.4 Skill 接口设计建议

基于以上分析，建议 skill 提供以下能力：

```
generate-crud
  ├── 输入方式:
  │   ├── --table <tableName>          # 从数据库表生成（复用 generator 流程）
  │   ├── --sql "<CREATE TABLE ...>"   # 从建表语句生成
  │   └── --describe "<描述>"          # 从自然语言描述生成
  │
  ├── 配置参数:
  │   ├── --package <packageName>      # 包路径
  │   ├── --module <moduleName>        # 模块名
  │   ├── --author <author>            # 作者
  │   ├── --template crud|tree|sub     # 模板类型
  │   ├── --web-type js|ts             # 前端类型
  │   └── --output <path>              # 输出路径
  │
  ├── 输出:
  │   ├── 后端: domain, mapper, service, serviceImpl, controller, mapper.xml
  │   ├── 前端: index.vue, api.js/ts, type.ts
  │   └── 其他: sql 菜单脚本
  │
  └── 扩展能力:
      ├── preview    # 预览生成结果
      ├── apply      # 写入目标路径
      └── modify     # 修改已有生成配置
```

## 5.5 需要关注的关键点

1. **配置推断准确性**：从自然语言到 GenTableColumn 配置的映射是最关键的环节，直接影响生成代码质量
2. **字段类型推断规则**：保持与 GenUtils 一致的类型映射规则，确保生成的 Java 类型正确
3. **字典类型推荐**：AI 可以根据字段名和注释智能推荐字典类型（如状态字段关联 sys_normal_disable）
4. **权限前缀统一**：保持 `{moduleName}:{businessName}` 的权限前缀格式，与若依安全体系一致
5. **模板版本管理**：如果项目后续修改了 `.vm` 模板，skill 需要能同步更新
6. **输出路径规范**：遵循项目现有的目录结构约定（如 `fjtcmd-hub-system` / `fjtcmd-hub-ui/src`）
7. **文件上传无需额外生成**：项目已有通用上传接口 `/common/upload`，生成的代码只需使用前端 `<image-upload>` / `<file-upload>` 组件即可，不需要为每个业务模块单独生成上传接口
8. **TypeScript 类型完整性**：TS 模式下需要同时生成 type.ts（QueryParams + Data 接口）和 api.ts（带泛型签名的 API 方法），确保前端代码类型安全

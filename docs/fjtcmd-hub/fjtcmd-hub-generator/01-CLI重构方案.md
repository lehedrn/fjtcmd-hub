# fjtcmd-hub-generator-cli 重构方案

> 参考 ruoyi-gen-cli 的设计思想，重构当前 CLI 模块，解决配置覆盖不完整等问题。

---

## 一、背景与目标

### 1.1 当前问题

当前 CLI 模块（`fjtcmd-hub-generator-cli`）采用"复制 generator 模块代码"的方式构建，存在以下问题：

1. **代码重复**：复制了 GenTable、GenTableColumn、GenUtils、VelocityUtils、VelocityInitializer、GenConstants、StringUtils 共 8 个类，与 generator 模块形成两套代码
2. **配置覆盖脆弱**：采用"保存自定义值 → init → 恢复"模式，天然容易漏字段。已暴露的问题：`queryType`、`isQuery`、`isList`、`isEdit`、`isInsert` 均未被保存/恢复，导致 YAML 中配置的 `queryType: BETWEEN` 被默认推断覆盖
3. **YAML 配置冗长**：当前的 table YAML 要求列出所有列的全部信息，无法只覆盖需要修改的字段
4. **模板不同步风险**：generator 模块的 .vm 模板更新后，CLI 需要手动同步复制

### 1.2 重构目标

- 复用 generator 模块的类，消除代码重复
- 采用"先 init 后覆盖"的三层配置模式，彻底解决字段覆盖问题
- 采用 Map-based 列配置，YAML 只需写要覆盖的字段
- 统一为一个 YAML 配置文件
- 自动继承 generator 模块的所有新功能（详情页、新模板等）

---

## 二、兼容性分析结论

### 2.1 完全兼容（可直接复用）

| 类/文件 | 说明 |
|---------|------|
| `GenTable` | 字段完全一致。generator 模块版本继承 BaseEntity |
| `GenTableColumn` | 字段完全一致 |
| `GenConstants` | 内容完全一致（在 fjtcmd-hub-common 中） |
| `VelocityUtils` | 方法签名、常量、逻辑完全一致 |
| `VelocityInitializer` | 功能完全相同 |
| 所有 22 个 .vm 模板 | 逐文件 diff 完全一致（仅换行符差异） |

### 2.2 需要适配的差异

| 差异点 | generator 模块行为 | 适配方式 |
|--------|-------------------|---------|
| `GenUtils.initTable` | 从 `GenConfig` **静态字段**读取 author/packageName/autoRemovePre/tablePrefix | 先设置 GenConfig 静态字段，再调用 initTable |
| `GenUtils.initTable` | 不设置 tplCategory/tplWebType/formColNum/genType/genPath/options（web 端从 DB 读取） | initTable 之后通过配置覆盖机制设置 |
| `GenUtils.convertClassName` | 从 `GenConfig` 静态字段读取前缀配置 | 同上 |
| `VelocityUtils.getTemplateList` | 签名为 `getTemplateList(GenTable table)`，内部从 table 读取 tplWebType 和 options | 直接调用，无需适配 |

### 2.3 新功能支撑

| 新功能 | generator 模块支持 | CLI 是否需要额外适配 |
|--------|-------------------|-------------------|
| 详情页 (genView) | ✅ 完整支持（view.vue.vm 模板 + isView 字段 + GEN_VIEW 常量） | ✅ 需在配置模型中支持 genView 开关（~10 行） |
| Vue 前端现代化 | ✅ 模板已内置 | ❌ 自动继承 |
| TypeScript 支持 | ✅ 模板已内置 | ❌ 自动继承 |
| 主子表 | ✅ 模板已内置 | ❌ 自动继承 |
| 树表 | ✅ 模板已内置 | ❌ 自动继承 |

---

## 三、依赖改造（pom.xml）

```xml
<dependencies>
    <!-- 复用 generator 模块（含 GenTable/GenUtils/VelocityUtils/模板） -->
    <dependency>
        <groupId>com.fjtcmd.hub</groupId>
        <artifactId>fjtcmd-hub-generator</artifactId>
        <exclusions>
            <!-- CLI 不启动 Web/DataSource/Redis -->
            <exclusion>
                <groupId>com.alibaba</groupId>
                <artifactId>druid-spring-boot-4-starter</artifactId>
            </exclusion>
        </exclusions>
    </dependency>

    <!-- Druid 本体（DDL SQL 解析器需要） -->
    <dependency>
        <groupId>com.alibaba</groupId>
        <artifactId>druid</artifactId>
    </dependency>

    <!-- YAML 解析 -->
    <dependency>
        <groupId>org.yaml</groupId>
        <artifactId>snakeyaml</artifactId>
    </dependency>

    <!-- 日志 -->
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
    </dependency>
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
    </dependency>
</dependencies>
```

保持 `maven-shade-plugin` 打包为 fat jar。

---

## 四、文件变更清单

### 4.1 删除的文件（共 9 个）

```
src/main/java/com/fjtcmd/hub/generator/cli/
├── config/
│   └── GeneratorConfig.java        ← 被 GenCliConfig 替代
├── constant/
│   └── GenConstants.java           ← 复用 common.constant.GenConstants
├── domain/
│   ├── GenTable.java               ← 复用 generator.domain.GenTable
│   └── GenTableColumn.java         ← 复用 generator.domain.GenTableColumn
├── parser/
│   └── SqlTableParser.java         ← 被 DdlParser 替代
└── util/
    ├── GenUtils.java               ← 复用 generator.util.GenUtils
    ├── StringUtils.java            ← 复用 common.utils.StringUtils
    ├── VelocityInitializer.java    ← 复用 generator.util.VelocityInitializer
    └── VelocityUtils.java          ← 复用 generator.util.VelocityUtils
```

### 4.2 新增的文件（共 5 个）

| 文件 | 职责 | 参考来源 |
|------|------|---------|
| `DdlParser.java` | Druid 解析 CREATE TABLE → `List<GenTable>`（内部调用 GenUtils.initTable + initColumnField） | ruoyi-gen-cli |
| `GenCliConfig.java` | YAML 配置模型：global + tables（Map-based 列配置） | ruoyi-gen-cli 的 GenTableConfig |
| `ConfigLoader.java` | 三层配置覆盖：全局→表级→列级 | ruoyi-gen-cli |
| `CodeWriter.java` | 模板渲染 → 写到目录（保持当前目录输出模式） | 基于当前 GeneratorCli 改造 |
| `GeneratorCli.java`（重写） | 主入口，串联整个流程 | ruoyi-gen-cli 的 GenCliApplication |

### 4.3 最终的源码结构

```
src/main/java/com/fjtcmd/hub/generator/cli/
├── GeneratorCli.java        # 主入口
├── DdlParser.java           # DDL SQL 解析器
├── GenCliConfig.java        # YAML 配置模型
├── ConfigLoader.java        # 三层配置覆盖
└── CodeWriter.java          # 代码输出（写目录）
```

### 4.4 配置文件

```
config/
├── generator.yml            # 示例配置（统一格式）
└── table-example.yml        # 删除（合并到 generator.yml 格式）

sql/
└── create_product.sql       # 保留（示例 DDL）
```

---

## 五、YAML 配置格式

统一为一个文件，支持 global + tables 两层：

```yaml
# ==================== 全局默认配置 ====================
global:
  author: ztq                        # 作者
  packageName: com.fjtcmd.hub.biz    # 生成包路径
  autoRemovePre: true                # 自动去除表前缀
  tablePrefix: sys_                  # 表前缀（多个逗号分隔）
  tplCategory: crud                  # 模板类型: crud / tree / sub
  tplWebType: element-plus-typescript # 前端类型: element-plus / element-plus-typescript
  formColNum: 2                      # 表单列数: 1/2/3
  parentMenuId: 1                    # 上级菜单ID
  genView: false                     # 是否生成详情页

# ==================== 表级 / 列级配置 ====================
# 按表名配置，覆盖全局默认。只写要覆盖的字段。
tables:
  sys_student:
    functionName: 学生信息           # 功能名（覆盖自动推断）
    # className: Student             # 实体类名（默认自动转换）
    # parentMenuId: 1                # 可覆盖全局 parentMenuId
    # genView: true                  # 可覆盖全局 genView

    # 列级配置（按列名索引，只写要覆盖的字段）
    columns:
      student_hobby:
        htmlType: checkbox           # 显示类型: input/textarea/select/radio/checkbox/datetime
        dictType: biz_student_hobby  # 字典类型
      student_sex:
        htmlType: select
        dictType: sys_user_sex
      student_status:
        htmlType: radio
        dictType: sys_normal_disable
      student_birthday:
        queryType: BETWEEN           # 查询方式: EQ/NE/GT/GTE/LT/LTE/LIKE/BETWEEN
```

### 列级可覆盖的完整字段清单

| 字段 | 类型 | 说明 |
|------|------|------|
| `columnComment` | String | 字段描述 |
| `javaType` | String | Java 类型 |
| `javaField` | String | Java 属性名 |
| `isInsert` | Boolean | 插入字段 |
| `isEdit` | Boolean | 编辑字段 |
| `isList` | Boolean | 列表字段 |
| `isQuery` | Boolean | 查询字段 |
| `isRequired` | Boolean | 必填 |
| `queryType` | String | 查询方式 |
| `htmlType` | String | 显示类型 |
| `dictType` | String | 字典类型 |

### 表级可覆盖的完整字段清单

| 字段 | 类型 | 说明 |
|------|------|------|
| `tableComment` | String | 表描述 |
| `className` | String | 实体类名 |
| `functionAuthor` | String | 作者（覆盖全局） |
| `functionName` | String | 功能名 |
| `tplCategory` | String | 模板类型 |
| `tplWebType` | String | 前端类型 |
| `packageName` | String | 包路径（覆盖全局） |
| `moduleName` | String | 模块名 |
| `businessName` | String | 业务名 |
| `parentMenuId` | Long | 上级菜单ID |
| `formColNum` | Integer | 表单列数 |
| `genView` | Boolean | 是否生成详情页 |
| `treeCode` | String | 树编码（tree 模式） |
| `treeParentCode` | String | 树父编码（tree 模式） |
| `treeName` | String | 树名称（tree 模式） |
| `subTableName` | String | 子表名（sub 模式） |
| `subTableFkName` | String | 子表外键（sub 模式） |
| `columns` | Map | 列级配置 |

---

## 六、主流程设计

```
┌─────────────────────────────────────────────────────────────┐
│ 1. 解析命令行参数                                             │
│    --config / --sql / --output / --overwrite / --preview     │
├─────────────────────────────────────────────────────────────┤
│ 2. 加载 YAML 配置                                             │
│    ConfigLoader.load(configPath) → GenCliConfig              │
├─────────────────────────────────────────────────────────────┤
│ 3. 将 global 配置写入 GenConfig 静态字段                       │
│    GenConfig.author = config.global.author                   │
│    GenConfig.packageName = config.global.packageName         │
│    GenConfig.autoRemovePre = config.global.autoRemovePre     │
│    GenConfig.tablePrefix = config.global.tablePrefix         │
├─────────────────────────────────────────────────────────────┤
│ 4. DDL 解析                                                   │
│    DdlParser.parse(ddlSql, operName)                         │
│    → 对每张表：                                                 │
│      a. 解析 CREATE TABLE（Druid SQL Parser）                 │
│      b. GenUtils.initTable(genTable, operName)                │
│      c. 对每列：GenUtils.initColumnField(column, genTable)    │
│    → 返回 List<GenTable>（已完成自动推断）                      │
├─────────────────────────────────────────────────────────────┤
│ 5. 配置覆盖（三层）                                            │
│    ConfigLoader.applyConfig(tables, config)                  │
│    → 第一层：全局默认（tplCategory, tplWebType 等）              │
│    → 第二层：表级覆盖（className, functionName, genView 等）     │
│    → 构建 options JSON（parentMenuId, genView, 树表字段等）     │
│    → 第三层：列级覆盖（htmlType, dictType, queryType 等）       │
├─────────────────────────────────────────────────────────────┤
│ 6. 代码输出                                                   │
│    CodeWriter.writeToDir(tables, outputDir)                  │
│    → 对每张表：                                                 │
│      a. 设置 pkColumn                                        │
│      b. VelocityInitializer.initVelocity()                   │
│      c. VelocityUtils.prepareContext(table)                   │
│      d. VelocityUtils.getTemplateList(table)                  │
│      e. 渲染模板 → 写入文件                                     │
└─────────────────────────────────────────────────────────────┘
```

### 核心改进点

**第 5 步是核心**：`applyConfig` 在 `initColumnField` **之后**执行，直接覆盖字段值，不需要"保存→恢复"模式。YAML 中指定的任何字段都会生效，未指定的保持自动推断结果。**从根本上杜绝字段丢失问题。**

---

## 七、命令行接口

保持当前 CLI 的参数风格，不引入 Spring Boot：

```bash
java -jar fjtcmd-hub-generator-cli-1.0.0.jar [选项]

必填参数:
  --config <path>          全局配置 YAML 文件路径
  --sql <path>             CREATE TABLE SQL 文件路径

可选参数:
  --output <path>          输出目录（覆盖配置中的 output）
  --overwrite              允许覆盖已存在的文件
  --preview                预览模式：输出到 stdout 不写文件
  --help, -h               显示帮助信息
```

### 使用示例

```bash
# 简单用法：DDL + 配置文件
java -jar fjtcmd-hub-generator-cli-1.0.0.jar \
  --config config/generator.yml \
  --sql sql/create_student.sql \
  --output ../fjtcmd-hub-biz/src

# 预览模式
java -jar fjtcmd-hub-generator-cli-1.0.0.jar \
  --config config/generator.yml \
  --sql sql/create_student.sql \
  --preview
```

---

## 八、新功能支撑：详情页（genView）

### 8.1 配置层面

在 `GenCliConfig.GlobalConfig` 和 `GenCliConfig.TableConfig` 中添加 `genView` 字段：

```java
// GlobalConfig
private Boolean genView;

// TableConfig
private Boolean genView;
```

### 8.2 ConfigLoader.buildOptions 中处理

```java
// genView：表级 > 全局
Boolean genView = (tc != null && tc.getGenView() != null) ? tc.getGenView()
                : (g != null && g.getGenView() != null) ? g.getGenView()
                : null;
if (genView != null)
{
    options.put(GenConstants.GEN_VIEW, genView);
}
```

### 8.3 模板层面

无需改动。generator 模块的 `VelocityUtils.getTemplateList` 会自动读取 `options.genView`，为 true 时加入 `view.vue.vm` 模板。

---

## 九、实施步骤

| 步骤 | 内容 | 预估 |
|------|------|------|
| 1 | 更新 pom.xml 依赖 | 10 分钟 |
| 2 | 新增 GenCliConfig.java（配置模型） | 20 分钟 |
| 3 | 新增 DdlParser.java（DDL 解析器） | 20 分钟 |
| 4 | 新增 ConfigLoader.java（三层配置覆盖） | 30 分钟 |
| 5 | 新增 CodeWriter.java（代码输出） | 20 分钟 |
| 6 | 重写 GeneratorCli.java（主入口） | 15 分钟 |
| 7 | 删除旧的复制类（9 个文件） | 5 分钟 |
| 8 | 更新配置示例文件 | 10 分钟 |
| 9 | 编译测试 | 15 分钟 |
| 10 | 用学生表做端到端验证 | 15 分钟 |

---

## 十、风险与应对

| 风险 | 影响 | 应对 |
|------|------|------|
| generator 模块依赖了 Spring（GenConfig 用 @Component） | CLI 不启动 Spring 时 GenConfig 静态字段为 null | 在 main 方法中手动设置静态字段，不依赖 Spring 注入 |
| generator 模块依赖 druid-spring-boot-4-starter | CLI 排除后缺少 Druid 类 | 单独引入 druid 本体（不含 Spring Boot starter） |
| 模板中引用了 `com.fjtcmd.hub.common.*` | 需确保 common 模块在 classpath | generator 已依赖 common，传递依赖自动引入 |
| BaseEntity 字段（createBy 等）的序列化 | GenTable 继承 BaseEntity 后多了字段 | CLI 不使用序列化，不影响 |
| 主子表必填校验被移除 | 生成的子表代码缺少前端校验 | 与 CLI 无关，是 generator 模块模板层面的决策 |

---

## 十一、验证计划

### 11.1 编译验证
- `mvn clean package -DskipTests` 成功

### 11.2 功能验证（以学生信息表为例）
- DDL 解析正确
- 自动推断：student_name 模糊查询、student_sex 下拉框、student_status 单选框
- YAML 覆盖：student_hobby 复选框 + 字典、student_birthday BETWEEN 查询
- genView 开关：生成 view.vue.vm
- 输出目录结构正确

### 11.3 回归验证
- 对比重构前后生成的代码（除已知改进外应完全一致）

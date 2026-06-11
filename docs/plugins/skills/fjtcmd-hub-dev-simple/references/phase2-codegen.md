# 阶段 2：代码生成与文件集成

**读取时机**：Step 2 开始时
**前置文档**：`references/project-conventions.md`、`references/phase1-requirement.md`
**前置产出**：`generate/{module}/{business}/{business}.sql` + `.yml` + `_dict.sql`

---

## 执行流程

### 步骤 2a：检查/创建目标 Maven 模块

**检查模块是否存在**：

```bash
ls fjtcmd-hub-{module}/pom.xml 2>/dev/null
```

**如果模块存在**：
- 检查 pom.xml 依赖是否完整
- 询问用户是否需要引入其他子模块依赖（如 fjtcmd-hub-system、fjtcmd-hub-common）

**如果模块不存在**：
- 参考 `references/module-creation-guide.md` 引导创建
- 创建 pom.xml、包结构、更新父 POM 和 admin 依赖

### 步骤 2b：执行 DDL 建表

```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/db_executor.py exec \
  --file generate/{module}/{business}/{business}.sql
```

执行前展示 SQL 内容，确认后执行。

### 步骤 2c：执行字典 SQL（如有）

如果阶段 1 生成了字典 SQL：

```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/db_executor.py exec \
  --file generate/{module}/{business}/{business}_dict.sql
```

### 步骤 2d：查询/创建上级菜单

**查询现有菜单**：

```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/menu_tool.py query --type M
```

向用户展示顶级目录菜单列表，让用户选择上级菜单位置。

**如果用户需要的上级菜单不存在**，创建新目录：

```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/menu_tool.py create \
  --name "{菜单名}" --parent-id 0 --order-num {排序} \
  --path "{路径}" --type M --icon "{图标}"
```

记录返回的 `menu_id`。

### 步骤 2e：更新 YAML 的 parentMenuId

使用 Edit 工具更新 `generate/{module}/{business}/{business}.yml` 中的 `parentMenuId` 值：

```yaml
global:
  parentMenuId: {查询到的菜单ID}  # 已更新
```

### 步骤 2f：CLI 生成代码

```bash
java -jar fjtcmd-hub-generator-cli/target/fjtcmd-hub-generator-cli.jar \
  --config generate/{module}/{business}/{business}.yml \
  --sql generate/{module}/{business}/{business}.sql \
  --output generate/{module}/{business}/output \
  --overwrite
```

执行后检查输出目录：

```bash
find generate/{module}/{business}/output -type f
```

### 步骤 2g：用户确认生成结果

向用户展示生成的文件清单，确认后继续。

**检查要点**：
- Controller、Service、Mapper、Domain 是否完整
- 前端 index.vue、view.vue 是否生成
- API ts 文件、Types ts 文件是否生成
- Menu SQL 是否生成
- 如为主子表，检查 route-index-bak.ts 是否生成

### 步骤 2h：拷贝到目标模块

```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/copy_code.py \
  --source generate/{module}/{business}/output \
  --target-module {module} \
  --business {business}
```

脚本会自动处理：
- 后端 Java 文件 → fjtcmd-hub-{module}/src/main/java/
- Mapper XML → fjtcmd-hub-{module}/src/main/resources/
- 前端 API → fjtcmd-hub-ui/src/api/
- 前端 Types → fjtcmd-hub-ui/src/types/api/（排除 index-bak.ts）
- 前端 Views → fjtcmd-hub-ui/src/views/

### 步骤 2i：合并 TS 类型索引

```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/merge_ts_index.py \
  --bak generate/{module}/{business}/output/vue/types/api/index-bak.ts \
  --target fjtcmd-hub-ui/src/types/api/index.ts
```

脚本会：
- 提取 index-bak.ts 中的 `export * from` 行
- 检查 index.ts 中是否已存在（去重）
- 将新行追加到 index.ts 末尾

### 步骤 2j：集成子表路由（仅主子表独立页面模式）

如果生成了 `route-index-bak.ts`：

```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/merge_router.py \
  --bak generate/{module}/{business}/output/vue/route-index-bak.ts \
  --target fjtcmd-hub-ui/src/router/index.ts
```

脚本会：
- 提取路由对象
- 检查 name 是否已存在（去重）
- 插入到 `dynamicRoutes` 数组末尾

### 步骤 2k：展示集成结果

向用户展示：
- 拷贝的文件列表
- TS 索引合并结果
- 路由集成结果（如有）

---

## 完成标志

阶段 2 完成后，所有代码已就位：
- ✅ 后端代码已拷贝到目标模块
- ✅ 前端代码已拷贝到 fjtcmd-hub-ui
- ✅ TS 类型索引已合并
- ✅ 子表路由已集成（如适用）

**标准模板** → 进入阶段 3（集成部署）
**简单业务模板** → 进入阶段 2b（TODO 标注与实现）

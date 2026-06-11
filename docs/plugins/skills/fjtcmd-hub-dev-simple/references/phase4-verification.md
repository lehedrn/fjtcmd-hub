# 阶段 4：验证与文档

**读取时机**：Step 4 开始时
**前置文档**：`references/project-conventions.md`
**参考模板**：`assets/curl-test-template.sh`、`assets/mock-data-rules.md`

---

## 执行流程

### 步骤 4a：生成模拟数据

**数据量规则**：
- 单表/树表：**20 条**
- 主子表：主表 **20 条** + 每条主表 **20 条**子表（共 420 条）

**生成规则**（参考 `assets/mock-data-rules.md`）：
- 必填字段：根据业务语义生成合理中文值
- 字典字段：覆盖所有字典选项（均匀分布）
- 文本字段：生成有意义的中文数据
- 数值字段：生成合理范围值
- 时间字段：近 1 年内随机时间
- 状态字段：80% 正常 + 20% 其他
- 外键字段：严格对应主表 ID

**输出文件**：`generate/{module}/{business}/{business}_mock.sql`

**执行**：
```bash
python3 .claude/skills/fjtcmd-hub-dev-simple/scripts/db_executor.py exec \
  --file generate/{module}/{business}/{business}_mock.sql
```

### 步骤 4b：生成 curl 测试脚本

参考 `assets/curl-test-template.sh` 模板，生成测试脚本。

**输出文件**：`scripts/test/curl/test-{module}-{business}.sh`

**脚本内容包含**：
1. 登录获取 token
2. 查询列表（验证分页）
3. 新增一条数据
4. 查询详情
5. 修改数据
6. 删除数据
7. 导出测试
8. （简单业务模板）自定义接口测试

**执行**：
```bash
chmod +x scripts/test/curl/test-{module}-{business}.sh
./scripts/test/curl/test-{module}-{business}.sh
```

### 步骤 4c：生成功能测试清单

生成人工测试清单，展示给用户：

```markdown
## 功能测试清单

### 基础功能
- [ ] 菜单正确显示
- [ ] 页面正常加载
- [ ] 列表数据正确显示（20条）

### 查询功能
- [ ] 分页功能正常
- [ ] 模糊搜索生效
- [ ] 字典筛选生效

### 新增功能
- [ ] 表单正常打开
- [ ] 必填项校验生效
- [ ] 字典选项正确显示
- [ ] 新增成功后列表刷新

### 修改功能
- [ ] 数据正确回显
- [ ] 修改成功后列表刷新

### 删除功能
- [ ] 单条删除生效
- [ ] 批量删除生效
- [ ] 删除确认提示正常

### 导入导出
- [ ] 导出 Excel 正常
- [ ] 导入模板下载正常

### 权限测试
- [ ] 无权限按钮隐藏
```

### 步骤 4d：生成交互记录

**输出文件**：`docs/changelogs/{module}/{business}/{YYYY-MM-DD}.md`

**目录结构**：
```
docs/changelogs/
├── demo/
│   ├── student/
│   │   └── 2026-06-11.md
│   └── product/
│       └── 2026-06-12.md
└── cms/
    └── article/
        └── 2026-06-13.md
```

```markdown
# {functionName} - {YYYY-MM-DD} 开发记录

## 模块信息
- 模块名称：{functionName}
- 模块编码：{module}.{business}
- 模板类型：{CRUD / Tree / Sub / 简单业务}

## 关键决策
- 字典类型选择：{说明}
- 索引设计：{说明}
- 权限设计：{权限标识}

## 生成的文件
- DDL SQL: `generate/{module}/{business}/{business}.sql`
- YAML 配置: `generate/{module}/{business}/{business}.yml`
- 菜单 SQL: `generate/{module}/{business}/output/{business}Menu.sql`
- 字典 SQL: `generate/{module}/{business}/{business}_dict.sql`（如有）
- 模拟数据: `generate/{module}/{business}/{business}_mock.sql`
- curl 测试: `scripts/test/curl/test-{module}-{business}.sh`

## 状态
- [x] 代码生成
- [x] 集成部署
- [x] 模拟数据
- [ ] 功能验证（进行中/已完成）
```

---

## 完成标志

- ✅ 20 条模拟数据已插入
- ✅ curl 测试脚本已生成并执行
- ✅ 功能测试清单已展示
- ✅ 交互记录已生成

**询问用户是否开始新功能开发**，如果是，回到阶段 1。

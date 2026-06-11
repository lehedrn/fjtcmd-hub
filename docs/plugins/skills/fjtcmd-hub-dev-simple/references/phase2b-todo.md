# 阶段 2b：TODO 标注与实现（简单业务模板专用）

**读取时机**：Step 2b 开始时（仅简单业务模板）
**前置文档**：`references/todo-patterns.md`、`references/project-conventions.md`
**前置产出**：标准 CRUD 代码已拷贝到目标模块

---

## 核心思路

简单业务模板在标准 CRUD 基础上需要添加业务逻辑。采用 **TODO 驱动开发**：

1. 先分析用户描述的业务规则
2. 在已生成的 CRUD 代码中标注 `// TODO` 注释
3. 展示 TODO 清单给用户确认
4. 逐一实现每个 TODO（后端优先，然后前端）
5. 全部完成后统一编译验证

---

## 步骤 2b-1：分析业务规则

从阶段 1 的需求文档中提取业务规则，分类为：

| 类型 | 说明 | 代码位置 |
|------|------|---------|
| **状态流转** | 草稿→审核→发布→下架 | ServiceImpl 新方法 |
| **业务校验** | 唯一性、权限、前置条件 | ServiceImpl 已有方法增强 |
| **自定义接口** | 审核、发布、驳回等 | Controller 新方法 |
| **条件展示** | 根据状态显示不同按钮 | 前端 index.vue |
| **数据权限** | 部门隔离、用户隔离 | ServiceImpl + Mapper |

## 步骤 2b-2：在代码中标注 TODO

**后端 TODO 标注位置**：

### ServiceImpl

```java
// 在已有的 insert 方法中添加业务校验
@Override
public int insertXxx(Xxx xxx) {
    // TODO: [校验] {描述校验规则}
    xxx.setStatus("0");  // 设置初始状态
    xxx.setCreateBy(SecurityUtils.getUsername());
    xxx.setCreateTime(DateUtils.getNowDate());
    return xxxMapper.insertXxx(xxx);
}

// 在已有的 update 方法中添加状态校验
@Override
public int updateXxx(Xxx xxx) {
    // TODO: [校验] 只有草稿状态可以修改
    xxx.setUpdateBy(SecurityUtils.getUsername());
    xxx.setUpdateTime(DateUtils.getNowDate());
    return xxxMapper.updateXxx(xxx);
}

// 新增自定义方法
/**
 * {方法描述}
 */
// TODO: [业务方法] 实现{功能名}逻辑
// 规则：{规则1}；{规则2}；{规则3}
@Transactional
public int {methodName}(Long id) {
    Xxx xxx = xxxMapper.selectXxxById(id);
    // TODO: [实现] 1.校验状态 2.执行业务 3.更新状态 4.记录操作信息
    return 0;
}
```

### Controller

```java
// 新增自定义接口
/**
 * {接口描述}
 */
// TODO: [自定义接口] {HTTP方法} {路径} {功能说明}
@PreAuthorize("@ss.hasPermi('{perms}')")
@Log(title = "{模块名}", businessType = BusinessType.UPDATE)
@{Mapping}("/{param}")
public AjaxResult {methodName}(@PathVariable Long id) {
    return toAjax(xxxService.{methodName}(id));
}
```

**前端 TODO 标注位置**：

### API 文件

```typescript
// TODO: [API函数] 新增以下接口函数
// export function submitAudit(id: number) { ... }
// export function publishArticle(id: number) { ... }
```

### index.vue

```vue
<!-- 在操作列中 -->
<!-- TODO: [条件按钮] 根据 status 显示不同操作按钮 -->
<!-- 草稿(0)：显示"修改"、"提交审核"、"删除" -->
<!-- 待审核(1)：显示"审核通过"、"驳回" -->
<!-- 已发布(2)：显示"下架" -->
```

## 步骤 2b-3：展示 TODO 清单

向用户展示完整的 TODO 清单：

> 根据业务规则，我在代码中标注了以下 TODO：
>
> **后端 TODO（{N} 个）**：
> | 编号 | 位置 | 类型 | 描述 |
> |------|------|------|------|
> | 1 | ServiceImpl.insertXxx | 校验 | 标题不能重复 |
> | 2 | ServiceImpl.submitAudit | 业务方法 | 提交审核 |
> | ... |
>
> **前端 TODO（{M} 个）**：
> | 编号 | 位置 | 类型 | 描述 |
> |------|------|------|------|
> | 1 | API | 接口函数 | submitAudit/publish/reject |
> | 2 | index.vue | 条件按钮 | 根据状态显示操作按钮 |
> | ... |
>
> **以上 TODO 清单是否正确？是否需要调整？**

## 步骤 2b-4：逐一实现后端 TODO

按顺序实现：

1. **ServiceImpl 校验逻辑** — 在已有方法中补充校验
2. **ServiceImpl 自定义方法** — 新增业务方法
3. **Controller 自定义接口** — 新增接口方法
4. **Service 接口声明** — 在 IXxxService 接口中添加方法声明

每个 TODO 实现后展示代码变更，但不逐个编译。

**实现模式参考** `references/todo-patterns.md`。

## 步骤 2b-5：逐一实现前端 TODO

按顺序实现：

1. **API 文件** — 新增接口函数
2. **index.vue 条件按钮** — 根据状态显示不同操作按钮
3. **index.vue 事件处理** — 新增 handleXxx 方法
4. **Types 文件** — 如有新增字段

## 步骤 2b-6：全量编译验证

所有 TODO 实现完成后：

```bash
./scripts/build/backend.sh clean-install
```

编译通过后，进入阶段 3（集成部署）。

如果编译失败，根据错误信息修复后重新编译。

---

## 注意事项

1. **TODO 描述要具体**：每个 TODO 注释要包含规则描述，方便后续实现
2. **事务控制**：状态变更方法必须添加 `@Transactional(rollbackFor = Exception.class)`
3. **操作日志**：自定义接口必须添加 `@Log` 注解
4. **权限标识**：自定义接口必须添加 `@PreAuthorize` 注解
5. **异常处理**：业务校验失败使用 `throw new ServiceException("错误信息")`
6. **审计字段**：状态变更时更新 updateBy、updateTime
7. **前端按钮权限**：条件按钮必须配合 `v-hasPermi` 指令

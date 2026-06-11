# TODO 标注模式参考

本文档提供简单业务模板中常见 TODO 的实现模式。

---

## 1. 状态流转模式

### 状态定义

```java
// 在实体类注释中定义状态值
// status 状态（0草稿 1待审核 2已发布 3已下架）
private String status;
```

### 提交审核

```java
@Transactional(rollbackFor = Exception.class)
public int submitAudit(Long id) {
    Xxx xxx = xxxMapper.selectXxxById(id);
    if (xxx == null) {
        throw new ServiceException("数据不存在");
    }
    if (!"0".equals(xxx.getStatus())) {
        throw new ServiceException("只有草稿状态可以提交审核");
    }
    // 业务校验（如内容非空）
    if (StringUtils.isEmpty(xxx.getContent())) {
        throw new ServiceException("内容不能为空");
    }
    xxx.setStatus("1");
    xxx.setUpdateBy(SecurityUtils.getUsername());
    xxx.setUpdateTime(DateUtils.getNowDate());
    return xxxMapper.updateXxx(xxx);
}
```

### 审核通过

```java
@Transactional(rollbackFor = Exception.class)
public int auditPass(Long id) {
    Xxx xxx = xxxMapper.selectXxxById(id);
    if (!"1".equals(xxx.getStatus())) {
        throw new ServiceException("只有待审核状态可以通过");
    }
    xxx.setStatus("2");
    xxx.setAuditBy(SecurityUtils.getUsername());
    xxx.setAuditTime(DateUtils.getNowDate());
    xxx.setUpdateBy(SecurityUtils.getUsername());
    xxx.setUpdateTime(DateUtils.getNowDate());
    return xxxMapper.updateXxx(xxx);
}
```

### 审核驳回

```java
@Transactional(rollbackFor = Exception.class)
public int auditReject(Long id, String rejectReason) {
    Xxx xxx = xxxMapper.selectXxxById(id);
    if (!"1".equals(xxx.getStatus())) {
        throw new ServiceException("只有待审核状态可以驳回");
    }
    xxx.setStatus("0");  // 驳回回草稿
    xxx.setAuditBy(SecurityUtils.getUsername());
    xxx.setAuditTime(DateUtils.getNowDate());
    xxx.setAuditRemark(rejectReason);
    xxx.setUpdateBy(SecurityUtils.getUsername());
    xxx.setUpdateTime(DateUtils.getNowDate());
    return xxxMapper.updateXxx(xxx);
}
```

---

## 2. 业务校验模式

### 唯一性校验

```java
// 在 insert 方法中
public int insertXxx(Xxx xxx) {
    // 唯一性校验
    Xxx existing = xxxMapper.selectXxxByName(xxx.getName());
    if (existing != null) {
        throw new ServiceException("名称'" + xxx.getName() + "'已存在");
    }
    xxx.setCreateBy(SecurityUtils.getUsername());
    xxx.setCreateTime(DateUtils.getNowDate());
    return xxxMapper.insertXxx(xxx);
}
```

### 权限校验

```java
// 只能操作自己的数据
public int updateXxx(Xxx xxx) {
    Xxx existing = xxxMapper.selectXxxById(xxx.getId());
    if (!existing.getCreateBy().equals(SecurityUtils.getUsername())) {
        throw new ServiceException("只能修改自己创建的数据");
    }
    // ...
}
```

---

## 3. Controller 自定义接口模式

```java
/**
 * 提交审核
 */
@Operation(summary = "提交审核")
@PreAuthorize("@ss.hasPermi('{module}:{business}:audit')")
@Log(title = "{模块名}", businessType = BusinessType.UPDATE)
@PutMapping("/audit/{id}")
public AjaxResult submitAudit(@PathVariable Long id) {
    return toAjax(xxxService.submitAudit(id));
}

/**
 * 审核通过
 */
@Operation(summary = "审核通过")
@PreAuthorize("@ss.hasPermi('{module}:{business}:audit')")
@Log(title = "{模块名}", businessType = BusinessType.UPDATE)
@PutMapping("/pass/{id}")
public AjaxResult auditPass(@PathVariable Long id) {
    return toAjax(xxxService.auditPass(id));
}

/**
 * 审核驳回
 */
@Operation(summary = "审核驳回")
@PreAuthorize("@ss.hasPermi('{module}:{business}:audit')")
@Log(title = "{模块名}", businessType = BusinessType.UPDATE)
@PutMapping("/reject/{id}")
public AjaxResult auditReject(@PathVariable Long id, @RequestBody Xxx xxx) {
    return toAjax(xxxService.auditReject(id, xxx.getAuditRemark()));
}
```

---

## 4. 前端 API 模式

```typescript
// 提交审核
export function submitAudit(id: number) {
  return request({
    url: '/{module}/{business}/audit/' + id,
    method: 'put'
  })
}

// 审核通过
export function auditPass(id: number) {
  return request({
    url: '/{module}/{business}/pass/' + id,
    method: 'put'
  })
}

// 审核驳回
export function auditReject(id: number, auditRemark: string) {
  return request({
    url: '/{module}/{business}/reject/' + id,
    method: 'put',
    data: { auditRemark }
  })
}
```

---

## 5. 前端条件按钮模式

```vue
<el-table-column label="操作" width="280">
  <template #default="scope">
    <!-- 草稿状态：修改、提交审核、删除 -->
    <template v-if="scope.row.status === '0'">
      <el-button v-hasPermi="['{module}:{business}:edit']"
        @click="handleUpdate(scope.row)">修改</el-button>
      <el-button v-hasPermi="['{module}:{business}:audit']"
        @click="handleSubmitAudit(scope.row)">提交审核</el-button>
      <el-button v-hasPermi="['{module}:{business}:remove']"
        @click="handleDelete(scope.row)">删除</el-button>
    </template>

    <!-- 待审核状态：通过、驳回 -->
    <template v-if="scope.row.status === '1'">
      <el-button v-hasPermi="['{module}:{business}:audit']"
        @click="handleAuditPass(scope.row)">通过</el-button>
      <el-button v-hasPermi="['{module}:{business}:audit']"
        @click="handleAuditReject(scope.row)">驳回</el-button>
    </template>

    <!-- 已发布状态：下架 -->
    <template v-if="scope.row.status === '2'">
      <el-button v-hasPermi="['{module}:{business}:offline']"
        @click="handleOffline(scope.row)">下架</el-button>
    </template>
  </template>
</el-table-column>
```

---

## 6. 前端事件处理模式

```typescript
/** 提交审核 */
function handleSubmitAudit(row: XxxType) {
  proxy.$modal.confirm('是否确认提交审核？').then(() => {
    return submitAudit(row.id)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("提交成功")
  }).catch(() => {})
}

/** 审核通过 */
function handleAuditPass(row: XxxType) {
  proxy.$modal.confirm('是否确认审核通过？').then(() => {
    return auditPass(row.id)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("审核通过")
  }).catch(() => {})
}

/** 审核驳回 */
function handleAuditReject(row: XxxType) {
  // 使用 prompt 输入驳回原因
  proxy.$modal.prompt('请输入驳回原因', '驳回', {
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(({ value }) => {
    return auditReject(row.id, value)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("已驳回")
  }).catch(() => {})
}
```

---

## 7. 数据权限模式

```java
// Service 层添加 @DataScope 注解
@Override
@DataScope(deptAlias = "d", userAlias = "u")
public List<Xxx> selectXxxList(Xxx xxx) {
    return xxxMapper.selectXxxList(xxx);
}
```

Mapper XML 中需要添加权限过滤占位符：

```xml
<select id="selectXxxList" parameterType="Xxx" resultMap="XxxResult">
    select * from {table_name} d
    <where>
        ${params.dataScope}
    </where>
</select>
```

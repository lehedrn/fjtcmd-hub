# API 设计规范

本文档规定 fjtcmd-hub 项目的 RESTful API 设计规范，确保接口的一致性、可读性和可维护性。

---

## 1. 设计原则

### 1.1 RESTful 风格

- 使用 HTTP 动词表示操作类型
- 资源使用名词形式
- 接口路径统一使用小写字母，单词间用短横线 `-` 或下划线 `_` 连接

| 操作 | HTTP 动词 | 路径示例 |
|------|----------|----------|
| 查询列表 | GET | `/system/user/list` |
| 查询详情 | GET | `/system/user/{userId}` |
| 新增 | POST | `/system/user` |
| 修改 | PUT | `/system/user` |
| 删除 | DELETE | `/system/user/{userIds}` |

### 1.2 统一响应格式

所有接口返回统一使用以下封装类：

| 返回类型 | 用途 | 示例 |
|----------|------|------|
| `TableDataInfo` | 分页列表数据 | 用户列表、角色列表 |
| `AjaxResult` | 操作结果 | 新增、修改、删除 |
| `AjaxResult` | 单个对象数据 | 查询详情 |
| `void` | 文件下载/导出 | 导出 Excel |

---

## 2. 接口路径规范

### 2.1 路径结构

```
/{模块名}/{资源名}/{操作}
```

**示例**：
```
/system/user/list      # 用户列表
/system/user/{userId}  # 用户详情
/system/role/list      # 角色列表
/demo/student/list     # 学生列表
```

### 2.2 模块划分

| 模块前缀 | 说明 | 示例 |
|----------|------|------|
| `/system/` | 系统管理模块 | `/system/user` |
| `/monitor/` | 系统监控模块 | `/monitor/cache` |
| `/tool/` | 系统工具模块 | `/tool/gen` |
| `/demo/` | 示例模块 | `/demo/student` |

### 2.3 资源命名

- 使用小写字母
- 多个单词使用下划线 `_` 连接（路径）或驼峰（参数）
- 使用单数或复数均可，项目内保持一致

```java
// 正确
@RequestMapping("/system/user")
@RequestMapping("/system/dict/data")

// 错误
@RequestMapping("/system/User")
@RequestMapping("/System/User")
```

---

## 3. Controller 规范

### 3.1 类注解

```java
@RestController
@RequestMapping("/system/user")
@Tag(name = "用户管理")
public class SysUserController extends BaseController
{
    // ...
}
```

| 注解 | 说明 | 示例 |
|------|------|------|
| `@RestController` | 标记为 REST 控制器 | 必须 |
| `@RequestMapping` | 定义请求根路径 | 必须 |
| `@Tag` | OpenAPI 3.0 标签描述 | 推荐（SpringDoc） |

**注意**：本项目使用 SpringDoc OpenAPI（不是 Springfox），注解使用 `@Tag` 而非 `@Api`。

### 3.2 方法注解

```java
@Operation(summary = "查询用户列表")
@PreAuthorize("@ss.hasPermi('system:user:list')")
@Log(title = "用户管理", businessType = BusinessType.LIST)
@GetMapping("/list")
public TableDataInfo list(SysUser user)
{
    startPage();
    List<SysUser> list = userService.selectUserList(user);
    return getDataTable(list);
}
```

| 注解 | 说明 | 必填 |
|------|------|------|
| `@Operation` | 接口功能描述（SpringDoc） | 是 |
| `@PreAuthorize` | 权限控制 | 是 |
| `@Log` | 操作日志 | 是 |
| `@GetMapping` | GET 请求映射 | 是 |
| `@PostMapping` | POST 请求映射 | 是 |
| `@PutMapping` | PUT 请求映射 | 是 |
| `@DeleteMapping` | DELETE 请求映射 | 是 |

**注意**：本项目使用 `@Operation` 而非 `@ApiOperation`（SpringDoc 规范）。

### 3.3 请求方法映射

```java
// 查询列表
@GetMapping("/list")

// 查询详情
@GetMapping("/{userId}")

// 新增
@PostMapping

// 修改
@PutMapping

// 删除
@DeleteMapping("/{userIds}")

// 导出
@PostMapping("/export")

// 下载模板
@PostMapping("/importTemplate")

// 导入数据
@PostMapping("/importData")
```

---

## 4. 参数规范

### 4.1 查询参数

使用 GET 请求，参数通过 `@RequestParam` 或对象接收：

```java
@Operation(summary = "查询用户列表")
@GetMapping("/list")
public TableDataInfo list(SysUser user)
{
    startPage();
    List<SysUser> list = userService.selectUserList(user);
    return getDataTable(list);
}
```

**分页参数**：
| 参数名 | 类型 | 说明 | 默认值 |
|--------|------|------|--------|
| `pageNum` | int | 页码 | 1 |
| `pageSize` | int | 每页数量 | 10 |

**查询参数示例**：
```java
public class SysUser
{
    private Long userId;          // 用户 ID
    private String userName;      // 用户名称
    private String nickName;      // 用户昵称
    private String status;        // 状态
    private Long deptId;          // 部门 ID
    private Date beginTime;       // 开始时间
    private Date endTime;         // 结束时间
}
```

### 4.2 请求体参数

使用 POST/PUT 请求，参数通过 `@RequestBody` 接收：

```java
@Operation(summary = "新增用户")
@Log(title = "用户管理", businessType = BusinessType.ADD)
@PostMapping
public AjaxResult add(@Validated @RequestBody SysUser user)
{
    return toAjax(userService.insertUser(user));
}
```

### 4.3 路径参数

```java
@Operation(summary = "查询用户详细")
@GetMapping("/{userId}")
public AjaxResult getInfo(@PathVariable Long userId)
{
    return AjaxResult.success(userService.selectUserById(userId));
}
```

### 4.4 参数校验

使用 `@Validated` 注解进行参数校验：

```java
@PostMapping
public AjaxResult add(@Validated @RequestBody SysUser user)
```

**实体类校验注解**：
```java
public class SysUser
{
    @NotBlank(message = "用户名称不能为空")
    @Length(min = 2, max = 20, message = "用户名称长度必须介于 2 和 20 之间")
    private String userName;

    @NotBlank(message = "用户昵称不能为空")
    private String nickName;

    @Email(message = "邮箱格式不正确")
    private String email;

    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号码格式不正确")
    private String phonenumber;
}
```

---

## 5. 响应规范

### 5.1 TableDataInfo（分页列表）

```json
{
    "code": 200,
    "msg": "操作成功",
    "total": 100,
    "rows": [
        {
            "userId": 1,
            "userName": "admin",
            "nickName": "管理员",
            "deptName": "研发部"
        }
    ]
}
```

**使用方式**：
```java
@GetMapping("/list")
public TableDataInfo list(SysUser user)
{
    startPage();
    List<SysUser> list = userService.selectUserList(user);
    return getDataTable(list);
}
```

### 5.2 AjaxResult（操作结果/单个对象）

**操作成功**：
```json
{
    "code": 200,
    "msg": "操作成功"
}
```

**操作失败**：
```json
{
    "code": 500,
    "msg": "操作失败：用户已存在"
}
```

**查询单个对象**：
```json
{
    "code": 200,
    "msg": "操作成功",
    "data": {
        "userId": 1,
        "userName": "admin",
        "nickName": "管理员"
    }
}
```

**使用方式**：
```java
// 返回操作结果
public AjaxResult add(@RequestBody SysUser user)
{
    return toAjax(userService.insertUser(user));
}

// 返回单个对象
@GetMapping("/{userId}")
public AjaxResult getInfo(@PathVariable Long userId)
{
    return AjaxResult.success(userService.selectUserById(userId));
}
```

### 5.3 文件下载/导出

```java
@Operation(summary = "导出用户数据")
@Log(title = "用户管理", businessType = BusinessType.EXPORT)
@PostMapping("/export")
public void export(HttpServletResponse response, SysUser user)
{
    List<SysUser> list = userService.selectUserList(user);
    ExcelUtil<SysUser> util = new ExcelUtil<>(SysUser.class);
    util.exportExcel(response, list, "用户数据");
}
```

---

## 6. SpringDoc OpenAPI 注解规范

### 6.1 类级别注解

```java
@Tag(name = "用户管理")
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController
{
    // ...
}
```

### 6.2 方法级别注解

```java
@Operation(summary = "查询用户列表", description = "分页查询用户列表")
@ApiResponse(responseCode = "200", description = "查询成功")
@ApiResponse(responseCode = "500", description = "查询失败")
@GetMapping("/list")
public TableDataInfo list(SysUser user)
{
    // ...
}
```

### 6.3 参数注解

```java
@Operation(summary = "新增用户")
@PostMapping
public AjaxResult add(
    @Parameter(description = "用户信息") @Validated @RequestBody SysUser user
)
{
    // ...
}
```

### 6.4 字段注解

```java
@Schema(description = "用户信息")
public class SysUser
{
    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "用户名称")
    private String userName;

    @Schema(description = "用户昵称")
    private String nickName;
}
```

---

## 7. 权限控制规范

### 7.1 功能权限

```java
@PreAuthorize("@ss.hasPermi('system:user:list')")
@GetMapping("/list")
public TableDataInfo list(SysUser user)
{
    // ...
}
```

**权限表达式**：
| 表达式 | 说明 | 示例 |
|--------|------|------|
| `@ss.hasPermi('')` | 拥有指定权限 | `system:user:list` |
| `@ss.hasRole('')` | 拥有指定角色 | `admin` |
| `@ss.hasPermi('') or @ss.hasRole('')` | 权限或角色 | 管理员或超级管理员 |

### 7.2 数据权限

```java
@DataScope(deptAlias = "d", userAlias = "u")
public List<SysUser> selectUserList(SysUser user)
{
    // ...
}
```

---

## 8. 操作日志规范

```java
@Log(title = "用户管理", businessType = BusinessType.ADD)
@PostMapping
public AjaxResult add(@RequestBody SysUser user)
{
    // ...
}
```

**业务类型**：
| 类型 | 常量 | 说明 |
|------|------|------|
| 新增 | `BusinessType.ADD` | 新增操作 |
| 修改 | `BusinessType.EDIT` | 修改操作 |
| 删除 | `BusinessType.DELETE` | 删除操作 |
| 查询 | `BusinessType.LIST` | 查询操作 |
| 导出 | `BusinessType.EXPORT` | 导出操作 |
| 导入 | `BusinessType.IMPORT` | 导入操作 |

---

## 9. 异常处理规范

### 9.1 业务异常

```java
if (user == null)
{
    throw new ServiceException("用户不存在");
}

if (!checkPassword(user, password))
{
    throw new ServiceException("密码错误");
}
```

### 9.2 全局异常处理

框架已配置 `GlobalExceptionHandler`，自动处理：
- `ServiceException`：业务异常
- `Exception`：系统异常
- `ValidationException`：校验异常

---

## 10. 接口文档

### 10.1 访问 Swagger UI

```
http://localhost:18081/swagger-ui.html
```

### 10.2 访问 OpenAPI 文档

```
http://localhost:18081/v3/api-docs
```

### 10.3 配置扫描

```java
@Configuration
public class SwaggerConfig
{
    @Bean
    public OpenAPI customOpenAPI()
    {
        return new OpenAPI()
            .info(new Info()
                .title("fjtcmd-hub API")
                .version("1.0.0")
                .description("体彩门店智慧互动信息 API 文档"))
            .addServersItem(new Server().url("http://localhost:18081"));
    }
}
```

---

## 11. 完整示例

### 11.1 Controller

```java
@Tag(name = "用户管理")
@RestController
@RequestMapping("/system/user")
public class SysUserController extends BaseController
{
    @Autowired
    private ISysUserService userService;

    @Operation(summary = "查询用户列表")
    @PreAuthorize("@ss.hasPermi('system:user:list')")
    @Log(title = "用户管理", businessType = BusinessType.LIST)
    @GetMapping("/list")
    public TableDataInfo list(SysUser user)
    {
        startPage();
        List<SysUser> list = userService.selectUserList(user);
        return getDataTable(list);
    }

    @Operation(summary = "查询用户详细")
    @PreAuthorize("@ss.hasPermi('system:user:query')")
    @GetMapping("/{userId}")
    public AjaxResult getInfo(@PathVariable Long userId)
    {
        return AjaxResult.success(userService.selectUserById(userId));
    }

    @Operation(summary = "新增用户")
    @PreAuthorize("@ss.hasPermi('system:user:add')")
    @Log(title = "用户管理", businessType = BusinessType.ADD)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody SysUser user)
    {
        if (!userService.checkUserNameUnique(user.getUserName()))
        {
            return AjaxResult.error("新增用户'" + user.getUserName() + "'失败，用户已存在");
        }
        user.setCreateBy(SecurityUtils.getUsername());
        user.setPassword(SecurityUtils.encryptPassword(user.getPassword()));
        return toAjax(userService.insertUser(user));
    }

    @Operation(summary = "修改用户")
    @PreAuthorize("@ss.hasPermi('system:user:edit')")
    @Log(title = "用户管理", businessType = BusinessType.EDIT)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody SysUser user)
    {
        userService.checkUserAllowed(user);
        if (!userService.checkUserNameUnique(user.getUserName()))
        {
            return AjaxResult.error("修改用户'" + user.getUserName() + "'失败，用户已存在");
        }
        user.setUpdateBy(SecurityUtils.getUsername());
        return toAjax(userService.updateUser(user));
    }

    @Operation(summary = "删除用户")
    @PreAuthorize("@ss.hasPermi('system:user:remove')")
    @Log(title = "用户管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{userIds}")
    public AjaxResult remove(@PathVariable Long[] userIds)
    {
        return toAjax(userService.deleteUserByIds(userIds));
    }

    @Operation(summary = "导出用户数据")
    @PreAuthorize("@ss.hasPermi('system:user:export')")
    @Log(title = "用户管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, SysUser user)
    {
        List<SysUser> list = userService.selectUserList(user);
        ExcelUtil<SysUser> util = new ExcelUtil<>(SysUser.class);
        util.exportExcel(response, list, "用户数据");
    }
}
```

### 11.2 实体类

```java
@Schema(description = "用户信息")
public class SysUser extends BaseEntity
{
    @Schema(description = "用户 ID")
    private Long userId;

    @Schema(description = "部门 ID")
    private Long deptId;

    @Schema(description = "用户账号")
    @NotBlank(message = "用户账号不能为空")
    @Length(min = 2, max = 20, message = "用户账号长度必须介于 2 和 20 之间")
    private String userName;

    @Schema(description = "用户昵称")
    @NotBlank(message = "用户昵称不能为空")
    private String nickName;

    @Schema(description = "用户邮箱")
    @Email(message = "邮箱格式不正确")
    private String email;

    @Schema(description = "手机号码")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号码格式不正确")
    private String phonenumber;

    @Schema(description = "用户性别")
    private String sex;

    @Schema(description = "用户头像")
    private String avatar;

    @Schema(description = "密码")
    private String password;

    @Schema(description = "状态")
    private String status;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "部门对象")
    private SysDept dept;

    @Schema(description = "角色 ID 列表")
    private List<Long> roleIds;

    @Schema(description = "岗位 ID 列表")
    private List<Long> postIds;
}
```

---

## 12. 最佳实践

### 12.1 接口设计原则

1. **单一职责**：每个接口只做一件事
2. **无状态**：接口不应保存客户端状态
3. **幂等性**：PUT/DELETE 操作应支持重复执行
4. **版本控制**：重大变更时考虑版本号（如 `/api/v1/user`）

### 12.2 性能优化

1. **分页查询**：列表接口必须分页
2. **按需返回**：只返回必要字段
3. **批量操作**：支持批量新增/修改/删除
4. **缓存策略**：字典等静态数据使用缓存

### 12.3 安全考虑

1. **权限校验**：所有接口必须配置权限注解
2. **参数校验**：输入参数必须校验
3. **SQL 注入防护**：使用 MyBatis 参数化查询
4. **XSS 防护**：开启 XSS 过滤器

---

## 13. SpringDoc 与 Springfox 对照表

| 功能 | Springfox（旧） | SpringDoc（本项目） |
|------|----------------|-------------------|
| 类标签 | `@Api(tags = "")` | `@Tag(name = "")` |
| 方法描述 | `@ApiOperation` | `@Operation(summary = "")` |
| 响应描述 | `@ApiResponse` | `@ApiResponse(responseCode = "")` |
| 参数描述 | `@ApiParam` | `@Parameter` |
| 模型描述 | `@ApiModel` | `@Schema` |
| 字段描述 | `@ApiModelProperty` | `@Schema` |

---

## 参考资料

- [SpringDoc OpenAPI 官方文档](https://springdoc.org/)
- [RuoYi 官方文档](http://doc.ruoyi.vip/)
- [OpenAPI 3.0 规范](https://swagger.io/specification/)

---

**创建时间**: 2026-06-11  
**基于版本**: fjtcmd-hub (Spring Boot 4.0.3 + SpringDoc OpenAPI)

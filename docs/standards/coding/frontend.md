# 前端编码规范

本文档基于 fjtcmd-hub 项目的实际编码风格制定，适用于 Vue 3 + Vite 前端开发。

---

## 1. 技术栈

### 1.1 核心技术

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue | 3.5.26 | 渐进式 JavaScript 框架 |
| Vite | 6.4.1 | 下一代前端构建工具 |
| Element Plus | 2.13.1 | Vue 3 UI 组件库 |
| Pinia | 3.0.4 | Vue 状态管理库 |
| Vue Router | 4.6.4 | Vue 官方路由管理器 |
| TypeScript | 5.6.3 | JavaScript 超集（类型系统） |
| Axios | 1.13.2 | HTTP 客户端 |
| pnpm | 11.5.2 | 包管理器 |

### 1.2 辅助库

| 库 | 版本 | 用途 |
|------|------|------|
| ECharts | 5.6.0 | 数据可视化图表 |
| @vueuse/core | 14.1.0 | Vue 组合式工具集 |
| vue-cropper | 1.1.1 | 图片裁剪组件 |
| @vueup/vue-quill | 1.2.0 | 富文本编辑器 |
| vuedraggable | 4.1.0 | 拖拽排序组件 |
| fuse.js | 7.1.0 | 模糊搜索库 |
| js-cookie | 3.0.5 | Cookie 操作库 |
| jsencrypt | 3.3.2 | RSA 加密库 |
| nprogress | 0.2.0 | 进度条库 |
| clipboard | 2.0.11 | 剪贴板库 |

### 1.3 开发工具

| 工具 | 版本 | 用途 |
|------|------|------|
| sass-embedded | 1.97.2 | CSS 预处理器 |
| unplugin-auto-import | 0.18.6 | 自动导入 Vue/Vue Router/Pinia API |
| unplugin-vue-setup-extend-plus | 1.0.1 | script setup 语法糖增强 |
| vite-plugin-compression | 0.5.1 | Gzip/Brotli 压缩 |
| vite-plugin-svg-icons | 2.0.1 | SVG 图标管理 |
| vue-tsc | 2.1.10 | Vue TypeScript 类型检查 |

---

## 2. 项目结构规范

### 2.1 完整目录结构

```
fjtcmd-hub-ui/
├── src/
│   ├── api/                      # API 接口封装
│   │   ├── system/               # 系统管理 API
│   │   ├── monitor/              # 系统监控 API
│   │   ├── demo/                 # 示例模块 API
│   │   └── tool/                 # 系统工具 API
│   │
│   ├── assets/                   # 静态资源
│   │   ├── icons/                # SVG 图标
│   │   ├── images/               # 图片资源
│   │   ├── logo/                 # Logo 图片
│   │   ├── styles/               # 全局样式
│   │   ├── 401_images/           # 401 错误页图片
│   │   └── 404_images/           # 404 错误页图片
│   │
│   ├── components/               # 通用组件（PascalCase 命名）
│   │   ├── Breadcrumb/           # 面包屑组件
│   │   ├── Crontab/              # Cron 表达式组件
│   │   ├── DictTag/              # 字典标签组件
│   │   ├── Editor/               # 富文本编辑器
│   │   ├── ExcelImportDialog/    # Excel 导入对话框
│   │   ├── FileUpload/           # 文件上传组件
│   │   ├── Hamburger/            # 汉堡菜单按钮
│   │   ├── HeaderSearch/         # 顶部搜索
│   │   ├── IconSelect/           # 图标选择器
│   │   ├── ImagePreview/         # 图片预览
│   │   ├── ImageUpload/          # 图片上传
│   │   ├── Pagination/           # 分页组件
│   │   ├── ParentView/           # 父级视图组件
│   │   ├── RightToolbar/         # 右侧工具栏
│   │   ├── Screenfull/           # 全屏组件
│   │   ├── SizeSelect/           # 尺寸选择
│   │   ├── SvgIcon/              # SVG 图标组件
│   │   ├── TreePanel/            # 树形面板
│   │   └── iFrame/               # 内嵌框架
│   │
│   ├── directive/                # 自定义指令
│   │   ├── common/               # 通用指令
│   │   └── permission/           # 权限指令（v-hasPermi、v-hasRole）
│   │
│   ├── layout/                   # 布局组件
│   │   └── components/           # 布局子组件
│   │
│   ├── plugins/                  # 插件配置
│   │
│   ├── router/                   # 路由配置
│   │
│   ├── store/                    # 状态管理 (Pinia)
│   │   └── modules/              # 模块 stores
│   │
│   ├── types/                    # TypeScript 类型定义
│   │   ├── api/                  # API 类型定义
│   │   │   ├── common.ts         # 通用类型（分页、响应等）
│   │   │   ├── login.ts          # 登录相关类型
│   │   │   ├── menu.ts           # 菜单类型
│   │   │   ├── system/           # 系统模块类型
│   │   │   │   ├── user.ts       # 用户类型
│   │   │   │   ├── role.ts       # 角色类型
│   │   │   │   └── ...           # 其他系统模块类型
│   │   │   ├── monitor/          # 监控模块类型
│   │   │   ├── demo/             # 示例模块类型
│   │   │   ├── tool/             # 工具模块类型
│   │   │   └── index.ts          # API 类型统一导出
│   │   ├── components.d.ts       # 组件类型声明
│   │   ├── global.d.ts           # 全局类型声明
│   │   └── index.ts              # 类型统一导出入口
│   │
│   ├── utils/                    # 工具函数
│   │   └── generator/            # 代码生成相关工具
│   │
│   ├── views/                    # 页面组件
│   │   ├── system/               # 系统管理页面
│   │   │   ├── user/             # 用户管理
│   │   │   ├── role/             # 角色管理
│   │   │   ├── menu/             # 菜单管理
│   │   │   ├── dept/             # 部门管理
│   │   │   ├── post/             # 岗位管理
│   │   │   ├── dict/             # 字典管理
│   │   │   ├── config/           # 参数管理
│   │   │   └── notice/           # 通知公告
│   │   ├── monitor/              # 系统监控页面
│   │   │   ├── online/           # 在线用户
│   │   │   ├── job/              # 定时任务
│   │   │   ├── operlog/          # 操作日志
│   │   │   └── logininfor/       # 登录日志
│   │   ├── demo/                 # 示例页面
│   │   │   ├── student/          # 学生管理（单表）
│   │   │   ├── product/          # 产品管理（树表）
│   │   │   └── customer/         # 客户管理（主子表）
│   │   ├── tool/                 # 系统工具页面
│   │   │   └── gen/              # 代码生成
│   │   ├── error/                # 错误页面（401、404）
│   │   └── redirect/             # 重定向页面
│   │
│   ├── App.vue                   # 根组件
│   ├── main.ts                   # 应用入口（TypeScript）
│   └── permission.ts             # 权限控制
│
├── public/                       # 公共静态资源（不经过构建）
├── vite.config.ts                # Vite 配置
├── tsconfig.json                 # TypeScript 配置
└── package.json                  # 依赖配置
```

### 2.2 类型定义规范

#### types/ 目录说明

`types/` 目录用于存放所有 TypeScript 类型定义，按以下规则组织：

1. **types/api/**：存放所有 API 相关的类型定义
   - 按模块划分目录（system、monitor、demo、tool）
   - 每个模块下按功能划分文件（user.ts、role.ts 等）
   - 通用类型放在 common.ts 中

2. **types/components.d.ts**：全局组件类型声明
3. **types/global.d.ts**：全局类型声明（环境变量、窗口扩展等）
4. **types/index.ts**：类型统一导出入口

#### 类型文件示例

```typescript
// types/api/system/user.ts

/** 用户 VO */
export interface UserVO {
  userId: number
  userName: string
  nickName: string
  dept?: DeptVO
  roles?: RoleVO[]
  status?: string
}

/** 用户查询参数 */
export interface UserQuery extends QueryParams {
  userName?: string
  status?: string
  deptId?: number
}

/** 用户表单 */
export interface UserForm {
  userId?: number
  userName: string
  nickName: string
  email?: string
  phonenumber?: string
  sex?: string
  status?: string
  remark?: string
  postIds?: number[]
  roleIds?: number[]
  password?: string
}
```

#### 在 API 文件中使用类型

```typescript
// api/system/user.ts
import request from '@/utils/request'
import type { UserVO, UserQuery, UserForm } from '@/types/api/system/user'

// 查询用户列表
export function listUser(query: UserQuery) {
  return request({
    url: '/system/user/list',
    method: 'get',
    params: query
  })
}

// 查询用户详细
export function getUser(userId: number) {
  return request({
    url: '/system/user/' + userId,
    method: 'get'
  })
}

// 新增用户
export function addUser(data: UserForm) {
  return request({
    url: '/system/user',
    method: 'post',
    data: data
  })
}
```

### 2.3 页面组件结构

页面模块根据业务复杂度，可能包含一个或多个 `.vue` 文件：

#### 简单 CRUD（列表 + 新增/修改对话框）

```
views/system/user/
└── index.vue      # 主页面（列表 + 增删改查对话框）
```

#### 带详情页的 CRUD

```
views/demo/student/
├── index.vue      # 列表页面（查询 + 表格 + 增删改对话框）
└── view.vue       # 详情页面（使用 Drawer 或 Dialog 展示详情）
```

#### 复杂业务页面（多步骤/多对话框）

```
views/tool/gen/
├── index.vue          # 主页面（表格列表）
├── importTable.vue    # 导入表对话框
├── createTable.vue    # 创建表对话框
├── editTable.vue      # 编辑表对话框
├── genInfoForm.vue    # 生成信息表单
└── basicInfoForm.vue  # 基本信息表单
```

**文件命名规范**：
- `index.vue`：列表主页面（必须有）
- `view.vue`：详情页面（可选，通常使用 Drawer 展示）
- 其他对话框组件使用 camelCase 命名（如 `importTable.vue`）

---

## 3. 命名规范

### 3.1 文件命名

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 页面组件 | `camelCase` | `index.vue`, `detail.vue` |
| API 文件 | `camelCase` | `user.ts`, `customer.ts` |
| 通用组件 | `PascalCase` | `TreePanel.vue`, `RightToolbar.vue` |
| TypeScript 文件 | `camelCase` | `utils.ts`, `request.ts` |

```bash
# 正确
src/views/system/user/index.vue
src/api/system/user.ts
src/components/TreePanel.vue

# 错误
src/views/system/User/index.vue
src/api/system/User.js
src/components/treePanel.vue
```

### 3.2 组件命名

- 使用 **PascalCase**
- 在 `<script setup>` 中使用 `name` 属性

```vue
<script setup name="User">
// 组件逻辑
</script>
```

### 3.3 变量命名

| 类型 | 命名规则 | 示例 |
|------|---------|------|
| 列表数据 | 名词 + List | `userList`, `customerList` |
| 查询参数 | `queryParams` | `queryParams` |
| 表单数据 | `form` | `form` |
| 校验规则 | `rules` | `rules` |
| 加载状态 | `loading` | `loading` |
| 对话框开关 | `open` | `open` |
| 搜索显示 | `showSearch` | `showSearch` |
| 选中 IDs | `ids` | `ids` |
| 总数 | `total` | `total` |
| 标题 | `title` | `title` |

```typescript
// 正确 - 符合项目规范
const userList = ref<UserVO[]>([])
const queryParams = ref<QueryParam>({ pageNum: 1, pageSize: 10 })
const form = ref<FormFieldType>({})
const rules = ref({ userName: [{ required: true }] })
const loading = ref(true)
const open = ref(false)
const showSearch = ref(true)
const ids = ref<number[]>([])
const total = ref(0)
const title = ref("")

// 错误 - 不符合项目规范
const users = ref([])
const query = ref({})
const formData = ref({})
const isLoading = ref(true)
const isDialogOpen = ref(false)
```

### 3.4 函数命名

| 操作 | 命名前缀 | 示例 |
|------|---------|------|
| 查询列表 | `get` / `list` | `getList`, `listUser` |
| 查询单个 | `get` | `getUser`, `getDeptTree` |
| 新增 | `add` | `handleAdd`, `addUser` |
| 修改 | `update` | `handleUpdate`, `updateUser` |
| 删除 | `delete` | `handleDelete`, `delUser` |
| 搜索 | `handle` + 动作 | `handleQuery`, `handleSelectionChange` |
| 重置 | `reset` | `resetQuery`, `resetForm` |

```typescript
// 列表查询
function getList() {
  loading.value = true
  listUser(queryParams.value).then(res => {
    userList.value = res.rows
    total.value = res.total
    loading.value = false
  })
}

// 搜索/重置
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

// 新增/修改/删除
function handleAdd() {
  reset()
  open.value = true
  title.value = "添加用户"
}

function handleUpdate(row: UserVO) {
  reset()
  const userId = row.userId || ids.value
  getUser(userId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改用户"
  })
}

function handleDelete(row: UserVO) {
  const userIds = row.userId || ids.value
  proxy.$modal.confirm('是否确认删除？').then(function () {
    return delUser(userIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}
```

---

## 4. TypeScript 规范

### 4.1 类型定义

**类型定义位置**：`src/types/api/[module]/[feature].ts`

**实际示例**（来自 `src/types/api/demo/student.ts`）：

```typescript
import type { PageDomain, BaseEntity } from "../common";

/** 学生信息配置分页查询参数 */
export interface StudentQueryParams extends PageDomain {
  /** 学生名称 */
  studentName?: string;
  /** 性别（0男 1女 2未知） */
  studentSex?: string;
  /** 状态（0正常 1停用） */
  studentStatus?: string;
  /** 生日 */
  studentBirthday?: string;
}

/** 学生信息配置信息 */
export interface Student extends BaseEntity {
  /** 编号 */
  studentId?: number;
  /** 学生名称 */
  studentName?: string;
  /** 年龄 */
  studentAge?: number;
  /** 爱好（0代码 1音乐 2电影） */
  studentHobby?: string;
  /** 性别（0男 1女 2未知） */
  studentSex?: string;
  /** 状态（0正常 1停用） */
  studentStatus?: string;
  /** 生日 */
  studentBirthday?: string;
}
```

**通用类型定义**（来自 `src/types/api/common.ts`）：

```typescript
/** 分页查询基础参数 */
export interface PageDomain {
  /** 当前页码 */
  pageNum?: number;
  /** 每页条数 */
  pageSize?: number;
  /** 排序字段 */
  orderByColumn?: string;
  /** 排序方向 */
  isAsc?: string;
}

/** 实体基础类 */
export interface BaseEntity {
  /** 创建者 */
  createBy?: string;
  /** 创建时间 */
  createTime?: string;
  /** 更新者 */
  updateBy?: string;
  /** 更新时间 */
  updateTime?: string;
  /** 备注 */
  remark?: string;
}

/** 通用响应 */
export interface AjaxResult<T = any> {
  code: number;
  msg: string;
  data?: T;
}

/** 分页响应 */
export interface TableDataInfo<T = any> {
  code: number;
  msg: string;
  total: number;
  rows: T;
}
```

### 4.2 类型使用

```vue
<script setup lang="ts" name="User">
import { ref, reactive, getCurrentInstance } from 'vue'
import { listUser, getUser, addUser, updateUser, delUser } from '@/api/system/user'
import type { UserVO, UserQuery, UserForm } from '@/types/api/system/user'

const { proxy } = getCurrentInstance()

// 使用泛型
const userList = ref<UserVO[]>([])
const queryParams = ref<UserQuery>({ pageNum: 1, pageSize: 10 })
const form = ref<UserForm>({})

// 函数类型
function getList() {
  loading.value = true
  listUser(queryParams.value).then((res: any) => {
    userList.value = res.rows
    total.value = res.total
    loading.value = false
  })
}
</script>
```

### 4.3 类型检查

```bash
# 运行类型检查
pnpm vue-tsc --noEmit

# 构建时自动检查（已集成）
pnpm build:prod
```

---

## 5. 代码格式规范

### 5.1 组件结构

```vue
<template>
  <div class="app-container">
    <!-- 查询表单 -->
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <!-- 表单项 -->
    </el-form>

    <!-- 操作按钮 -->
    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button v-hasPermi="['system:user:add']">新增</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <!-- 数据表格 -->
    <el-table v-loading="loading" :data="list">
      <el-table-column prop="name" label="名称" />
    </el-table>

    <!-- 分页 -->
    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <!-- 新增/修改对话框 -->
    <el-dialog :title="title" v-model="open" width="600px">
      <el-form :model="form" :rules="rules" ref="formRef">
        <!-- 表单项 -->
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="submitForm">确 定</el-button>
          <el-button @click="cancel">取 消</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts" name="ComponentName">
// TypeScript + Composition API
</script>

<style lang="scss" scoped>
/* 使用 SCSS */
</style>
```

### 5.2 缩进

- 使用 **2 个空格** 缩进

```vue
<template>
  <div class="container">
    <el-form :model="form">
      <el-form-item label="名称">
        <el-input v-model="form.name" />
      </el-form-item>
    </el-form>
  </div>
</template>
```

### 5.3 引号

- 字符串使用 **单引号**

```typescript
// 正确
const title = '添加用户'
const msg = `Hello, ${name}`

// 错误
const title = "添加用户"
```

### 5.4 响应式数据

- 使用 `ref` 和 `reactive`
- 优先使用 `ref`
- 使用 `toRefs` 解构

```vue
<script setup lang="ts" name="User">
import { ref, reactive, toRefs, getCurrentInstance } from 'vue'

const { proxy } = getCurrentInstance()

const userList = ref<UserVO[]>([])
const loading = ref(true)
const open = ref(false)

const data = reactive({
  form: {} as UserForm,
  queryParams: {
    pageNum: 1,
    pageSize: 10
  } as UserQuery,
  rules: {
    userName: [{ required: true, message: "用户名称不能为空", trigger: "blur" }]
  }
})

const { queryParams, form, rules } = toRefs(data)
</script>
```

---

## 6. API 调用规范

### 6.1 API 文件结构

**实际示例**（来自 `src/api/demo/student.ts`）：

```typescript
import request from '@/utils/request'
import type { AjaxResult, TableDataInfo, StudentQueryParams, Student } from '@/types'

// 查询学生信息列表
export function listStudent(query: StudentQueryParams): Promise<TableDataInfo<Student[]>> {
  return request({
    url: '/demo/student/list',
    method: 'get',
    params: query
  })
}

// 查询学生信息详细
export function getStudent(studentId: number): Promise<AjaxResult<Student>> {
  return request({
    url: '/demo/student/' + studentId,
    method: 'get'
  })
}

// 新增学生信息
export function addStudent(data: Student): Promise<AjaxResult> {
  return request({
    url: '/demo/student',
    method: 'post',
    data: data
  })
}

// 修改学生信息
export function updateStudent(data: Student): Promise<AjaxResult> {
  return request({
    url: '/demo/student',
    method: 'put',
    data: data
  })
}

// 删除学生信息
export function delStudent(studentId: number | number[]): Promise<AjaxResult> {
  return request({
    url: '/demo/student/' + studentId,
    method: 'delete'
  })
}
```

### 6.2 组件内 API 调用

**实际示例**（来自 `src/views/demo/student/index.vue`）：

```vue
<script setup lang="ts" name="Student">
import type { Student, StudentQueryParams } from "@/types/api/demo/student"
import { listStudent, getStudent, delStudent, addStudent, updateStudent } from "@/api/demo/student"
import StudentViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { biz_student_hobby, sys_user_sex, sys_normal_disable } = useDict('biz_student_hobby', 'sys_user_sex', 'sys_normal_disable')

const studentList = ref<Student[]>([])
const open = ref<boolean>(false)
const loading = ref<boolean>(true)
const showSearch = ref<boolean>(true)
const ids = ref<number[]>([])
const single = ref<boolean>(true)
const multiple = ref<boolean>(true)
const total = ref<number>(0)
const title = ref<string>("")

const data = reactive({
  form: {} as Student,
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    studentName: undefined,
    studentSex: undefined,
    studentStatus: undefined,
    studentBirthday: undefined
  } as StudentQueryParams,
  rules: {
    studentName: [
      { required: true, message: "学生名称不能为空", trigger: "blur" }
    ],
    studentStatus: [
      { required: true, message: "状态不能为空", trigger: "change" }
    ]
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询列表 */
function getList() {
  loading.value = true
  listStudent(proxy.addDateRange(queryParams.value, daterangeStudentBirthday.value)).then(res => {
    studentList.value = res.rows
    total.value = res.total
    loading.value = false
  })
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  daterangeStudentBirthday.value = []
  proxy.resetForm("queryRef")
  handleQuery()
}

/** 多选框选中数据 */
function handleSelectionChange(selection: Student[]) {
  ids.value = selection.map(item => item.studentId!)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

/** 新增按钮操作 */
function handleAdd() {
  reset()
  open.value = true
  title.value = "添加学生信息"
}

/** 修改按钮操作 */
function handleUpdate(row?: Student) {
  reset()
  const studentId = row?.studentId || ids.value
  getStudent(studentId).then(res => {
    form.value = res.data
    open.value = true
    title.value = "修改学生信息"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["formRef"].validate((valid: boolean) => {
    if (valid) {
      if (form.value.studentId != undefined) {
        updateStudent(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addStudent(form.value).then(() => {
          proxy.$modal.msgSuccess("新增成功")
          open.value = false
          getList()
        })
      }
    }
  })
}

/** 删除按钮操作 */
function handleDelete(row?: Student) {
  const studentIds = row?.studentId || ids.value
  proxy.$modal.confirm('是否确认删除学生信息编号为"' + studentIds + '"的数据项？').then(() => {
    return delStudent(studentIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 表单重置 */
function reset() {
  form.value = {
    studentId: undefined,
    studentName: undefined,
    studentAge: undefined,
    studentHobby: undefined,
    studentSex: undefined,
    studentStatus: undefined,
    studentBirthday: undefined
  }
  proxy.resetForm("formRef")
}

/** 取消按钮 */
function cancel() {
  open.value = false
  reset()
}
</script>
```

**关键要点**：
1. 使用 `import type` 导入类型定义
2. 使用 `toRefs` 解构 reactive 对象
3. 使用 `proxy.$modal` 进行消息提示和确认
4. 使用 `proxy.addDateRange` 处理日期范围查询
5. 使用 `proxy.resetForm` 重置表单

---

## 7. 状态管理

### 7.1 Pinia Store 使用

```vue
<script setup lang="ts" name="User">
import useAppStore from '@/store/modules/app'
import { useUserStore } from '@/store/modules/user'

const appStore = useAppStore()
const userStore = useUserStore()

// 获取用户信息
await userStore.getInfo()

// 登出
await userStore.logOut()
</script>
```

### 7.2 字典使用

```vue
<script setup name="User">
const { proxy } = getCurrentInstance()
const { sys_normal_disable, sys_user_sex } = proxy.useDict("sys_normal_disable", "sys_user_sex")
</script>

<template>
  <!-- 下拉框使用字典 -->
  <el-select v-model="form.sex" placeholder="请选择">
    <el-option v-for="dict in sys_user_sex" :key="dict.value" :label="dict.label" :value="dict.value" />
  </el-select>

  <!-- 表格列使用字典标签 -->
  <dict-tag :options="sys_user_sex" :value="scope.row.sex" />
</template>
```

---

## 8. 权限控制

### 8.1 按钮权限

```vue
<template>
  <!-- 使用 v-hasPermi 指令 -->
  <el-button v-hasPermi="['system:user:add']">新增</el-button>
  <el-button v-hasPermi="['system:user:edit']">修改</el-button>
  <el-button v-hasPermi="['system:user:remove']">删除</el-button>
</template>
```

### 8.2 角色权限

```vue
<template>
  <el-button v-hasRole="['admin']">管理</el-button>
</template>
```

---

## 9. 通用组件使用

### 9.1 分页组件

```vue
<template>
  <pagination
    v-show="total > 0"
    :total="total"
    v-model:page="queryParams.pageNum"
    v-model:limit="queryParams.pageSize"
    @pagination="getList"
  />
</template>
```

### 9.2 右侧工具栏

```vue
<template>
  <right-toolbar 
    v-model:showSearch="showSearch" 
    @queryTable="getList" 
    :columns="columns"
  />
</template>
```

### 9.3 树形面板

```vue
<template>
  <tree-panel 
    title="组织机构" 
    :tree-data="deptOptions" 
    @node-click="handleNodeClick" 
    @refresh="getDeptTree" 
  />
</template>
```

### 9.4 Excel 导入组件

```vue
<template>
  <excel-import-dialog 
    ref="importUserRef" 
    title="用户导入" 
    action="/system/user/importData"
    @success="getList" 
  />
</template>
```

---

## 10. 注释规范

### 10.1 函数注释

```typescript
/** 查询用户列表 */
function getList() {
  // ...
}

/** 搜索按钮操作 */
function handleQuery() {
  // ...
}

/** 重置按钮操作 */
function resetQuery() {
  // ...
}

/** 新增按钮操作 */
function handleAdd() {
  // ...
}

/** 修改按钮操作 */
function handleUpdate(row: UserVO) {
  // ...
}

/** 删除按钮操作 */
function handleDelete(row: UserVO) {
  // ...
}

/** 提交按钮 */
function submitForm() {
  // ...
}

/** 取消按钮 */
function cancel() {
  // ...
}
```

---

## 11. 最佳实践

### 11.1 表格列显隐控制

```vue
<script setup lang="ts">
import { ref } from 'vue'

interface ColumnType {
  label: string
  visible: boolean
}

const columns = ref<Record<string, ColumnType>>({
  userId: { label: '用户编号', visible: true },
  userName: { label: '用户名称', visible: true },
  nickName: { label: '用户昵称', visible: true }
})
</script>

<template>
  <el-table-column 
    label="用户名称" 
    key="userName" 
    prop="userName" 
    v-if="columns.userName.visible" 
  />
</template>
```

### 11.2 表格行选择

```typescript
// 多选框选中数据
function handleSelectionChange(selection: UserVO[]) {
  ids.value = selection.map(item => item.userId)
  single.value = selection.length != 1
  multiple.value = !selection.length
}
```

### 11.3 表单重置

```typescript
function reset() {
  form.value = {
    userId: undefined,
    userName: undefined,
    nickName: undefined
  }
  proxy.resetForm("userRef")
}
```

### 11.4 对话框取消

```typescript
function cancel() {
  open.value = false
  reset()
}
```

### 11.5 日期范围处理

```typescript
const dateRange = ref<string[]>([])

// 查询时传入日期范围
listUser(proxy.addDateRange(queryParams.value, dateRange.value))
```

### 11.6 导出文件命名

```typescript
function handleExport() {
  proxy.download("system/user/export", {
    ...queryParams.value,
  }, `user_${new Date().getTime()}.xlsx`)
}
```

---

## 12. Vite 配置规范

### 12.1 环境变量

```bash
# .env.development
VITE_APP_BASE_API = '/dev-api'
VITE_APP_MONITRO_ADMIN = 'http://localhost:18081'
VITE_APP_BASE_ADMIN = 'http://localhost:18081'

# .env.production
VITE_APP_BASE_API = '/prod-api'
```

### 12.2 代理配置

```typescript
// vite.config.ts
export default defineConfig({
  server: {
    port: 3888,
    proxy: {
      '/dev-api': {
        target: 'http://localhost:18081',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/dev-api/, '')
      }
    }
  }
})
```

### 12.3 自动导入配置

```typescript
// vite.config.ts
import AutoImport from 'unplugin-auto-import/vite'

export default defineConfig({
  plugins: [
    AutoImport({
      imports: [
        'vue',
        'vue-router',
        'pinia'
      ],
      dts: 'src/types/auto-imports.d.ts'
    })
  ]
})
```

---

## 13. 构建与部署

### 13.1 开发环境

```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm dev

# 访问地址：http://localhost:3888
```

### 13.2 生产构建

```bash
# 构建生产版本
pnpm build:prod

# 构建预发布版本
pnpm build:stage

# 预览构建结果
pnpm preview
```

### 13.3 代码检查

```bash
# TypeScript 类型检查
pnpm vue-tsc --noEmit

# 构建时自动检查（已集成）
```

---

## 参考资料

- [Vue 3 官方文档](https://cn.vuejs.org/)
- [Vite 官方文档](https://vitejs.dev/)
- [Element Plus 文档](https://element-plus.org/zh-CN/)
- [Pinia 官方文档](https://pinia.vuejs.org/)
- [Vue Router 官方文档](https://router.vuejs.org/)
- [TypeScript 官方文档](https://www.typescriptlang.org/)

---

**最后更新**: 2026-06-11  
**基于版本**: fjtcmd-hub-ui (Vue 3.5.26 + Vite 6.4.1 + TypeScript 5.6.3)

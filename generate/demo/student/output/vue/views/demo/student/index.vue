<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="学生名称" prop="studentName">
        <el-input
          v-model="queryParams.studentName"
          placeholder="请输入学生名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="性别" prop="studentSex">
        <el-select v-model="queryParams.studentSex" placeholder="请选择性别" clearable>
          <el-option
            v-for="dict in sys_user_sex"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="生日" style="width: 308px">
        <el-date-picker
          v-model="daterangeStudentBirthday"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        ></el-date-picker>
      </el-form-item>
      <el-form-item label="联系电话" prop="studentPhone">
        <el-input
          v-model="queryParams.studentPhone"
          placeholder="请输入联系电话"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
          <el-option
            v-for="dict in sys_normal_disable"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button
          type="primary"
          plain
          icon="Plus"
          @click="handleAdd"
          v-hasPermi="['demo:student:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['demo:student:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['demo:student:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['demo:student:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 表格容器：flex 布局填满剩余空间 -->
    <div class="table-container">
    <el-table ref="tableRef" v-loading="loading" :data="studentList" :height="tableHeight" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="序号" width="60" align="center">
        <template #default="scope">
          {{ (queryParams.pageNum - 1) * queryParams.pageSize + scope.$index + 1 }}
        </template>
      </el-table-column>
      <el-table-column label="学生名称" align="center" prop="studentName" />
      <el-table-column label="性别" align="center" prop="studentSex">
        <template #default="scope">
          <dict-tag :options="sys_user_sex" :value="scope.row.studentSex"/>
        </template>
      </el-table-column>
      <el-table-column label="年龄" align="center" prop="studentAge" />
      <el-table-column label="生日" align="center" prop="studentBirthday" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.studentBirthday, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="联系电话" align="center" prop="studentPhone" />
      <el-table-column label="状态" align="center" prop="status">
        <template #default="scope">
          <dict-tag :options="sys_normal_disable" :value="scope.row.status"/>
        </template>
      </el-table-column>
      <el-table-column label="备注" align="center" prop="remark" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['demo:student:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['demo:student:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['demo:student:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    </div>

    <pagination
      v-show="total>0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 学生信息详情抽屉 -->
    <student-view-drawer ref="studentViewRef" />
    <!-- 添加或修改学生信息对话框 -->
    <el-dialog :title="title" v-model="open" width="800px" append-to-body>
      <el-form ref="studentRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="学生名称" prop="studentName">
              <el-input v-model="form.studentName" placeholder="请输入学生名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="studentSex">
              <el-select v-model="form.studentSex" placeholder="请选择性别">
                <el-option
                  v-for="dict in sys_user_sex"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="年龄" prop="studentAge">
              <el-input v-model="form.studentAge" placeholder="请输入年龄" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="生日" prop="studentBirthday">
              <el-date-picker clearable
                v-model="form.studentBirthday"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择生日">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="联系电话" prop="studentPhone">
              <el-input v-model="form.studentPhone" placeholder="请输入联系电话" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-radio-group v-model="form.status">
                <el-radio
                  v-for="dict in sys_normal_disable"
                  :key="dict.value"
                  :label="dict.value"
                >{{dict.label}}</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="remark">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
        </el-row>
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

<script setup lang="ts" name="Student">
import type { Student, StudentQueryParams } from "@/types/api/demo/student"
import { listStudent, getStudent, delStudent, addStudent, updateStudent } from "@/api/demo/student"
import StudentViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { sys_user_sex, sys_normal_disable } = useDict('sys_user_sex', 'sys_normal_disable')

const studentList = ref<Student[]>([])
const open = ref<boolean>(false)
const loading = ref<boolean>(true)
const showSearch = ref<boolean>(true)
const ids = ref<number[]>([])
const single = ref<boolean>(true)
const multiple = ref<boolean>(true)
const total = ref<number>(0)
const title = ref<string>("")
const tableRef = ref()
const tableHeight = ref<number>(0)
const daterangeStudentBirthday = ref<string[]>([])

const data = reactive({
  form: {} as Student,
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    studentName: undefined,
    studentSex: undefined,
    studentBirthday: undefined,
    studentPhone: undefined,
    status: undefined,
  } as StudentQueryParams,
  rules: {
    studentId: [
      { required: true, message: "编号不能为空", trigger: "blur" }
    ],
    studentName: [
      { required: true, message: "学生名称不能为空", trigger: "blur" }
    ],
    status: [
      { required: true, message: "状态不能为空", trigger: "change" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询学生信息列表 */
function getList() {
  loading.value = true
  queryParams.value.params = {}
  if (null != daterangeStudentBirthday.value && '' != daterangeStudentBirthday.value) {
    queryParams.value.params["beginStudentBirthday"] = daterangeStudentBirthday.value[0]
    queryParams.value.params["endStudentBirthday"] = daterangeStudentBirthday.value[1]
  }
  listStudent(queryParams.value).then(response => {
    studentList.value = response.rows
    total.value = response.total
    loading.value = false
    calcTableHeight()
  })
}

/** 取消按钮 */
function cancel() {
  open.value = false
  reset()
}

/** 表单重置 */
function reset() {
  form.value = {
    studentName: null,
    studentSex: null,
    studentAge: null,
    studentBirthday: null,
    studentPhone: null,
    status: null,
    remark: null,
  }
  proxy.resetForm("studentRef")
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
  ids.value = selection.map(item => item.studentId)
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
function handleUpdate(row: Student) {
  reset()
  const _studentId = row.studentId || ids.value[0]
  getStudent(_studentId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改学生信息"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["studentRef"].validate((valid: boolean) => {
    if (valid) {
      if (form.value.studentId != null) {
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
function handleDelete(row: Student) {
  const _studentIds = row.studentId || ids.value
  proxy.$modal.confirm('是否确认删除学生信息编号为"' + _studentIds + '"的数据项？').then(function() {
    return delStudent(_studentIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 详情按钮操作 */
function handleViewData(row: Student) {
  proxy.$refs["studentViewRef"].open(row.studentId)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('demo/student/export', {
    ...queryParams.value
  }, `student_${new Date().getTime()}.xlsx`)
}

/** 计算表格高度 */
function calcTableHeight() {
  nextTick(() => {
    const container = document.querySelector('.table-container') as HTMLElement
    if (container) {
      tableHeight.value = container.clientHeight
    }
  })
}

onMounted(() => {
  calcTableHeight()
  window.addEventListener('resize', calcTableHeight)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', calcTableHeight)
})

getList()
</script>

<style scoped>
.app-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.app-container .el-form {
  flex-shrink: 0;
}
.app-container .mb8 {
  flex-shrink: 0;
}
.table-container {
  flex: 1;
  overflow: hidden;
  min-height: 0;
}
.app-container .pagination-container {
  flex-shrink: 0;
}
</style>

<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="客户姓名" prop="customerName">
        <el-input
          v-model="queryParams.customerName"
          placeholder="请输入客户姓名"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="手机号码" prop="phonenumber">
        <el-input
          v-model="queryParams.phonenumber"
          placeholder="请输入手机号码"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="客户性别" prop="sex">
        <el-select v-model="queryParams.sex" placeholder="请选择客户性别" clearable>
          <el-option
            v-for="dict in sys_user_sex"
            :key="dict.value"
            :label="dict.label"
            :value="dict.value"
          />
        </el-select>
      </el-form-item>
      <el-form-item label="客户生日" style="width: 308px">
        <el-date-picker
          v-model="daterangeBirthday"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        ></el-date-picker>
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
          v-hasPermi="['demo:customer:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['demo:customer:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['demo:customer:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['demo:customer:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="customerList" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="客户id" align="center" prop="customerId" />
      <el-table-column label="客户姓名" align="center" prop="customerName" />
      <el-table-column label="手机号码" align="center" prop="phonenumber" />
      <el-table-column label="客户性别" align="center" prop="sex">
        <template #default="scope">
          <dict-tag :options="sys_user_sex" :value="scope.row.sex"/>
        </template>
      </el-table-column>
      <el-table-column label="客户生日" align="center" prop="birthday" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.birthday, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['demo:customer:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['demo:customer:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['demo:customer:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    
    <pagination
      v-show="total>0"
      :total="total"
      v-model:page="queryParams.pageNum"
      v-model:limit="queryParams.pageSize"
      @pagination="getList"
    />

    <!-- 客户信息表详情抽屉 -->
    <customer-view-drawer ref="customerViewRef" />
    <!-- 添加或修改客户信息表对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="customerRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="客户姓名" prop="customerName">
              <el-input v-model="form.customerName" placeholder="请输入客户姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="手机号码" prop="phonenumber">
              <el-input v-model="form.phonenumber" placeholder="请输入手机号码" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="客户性别" prop="sex">
              <el-select v-model="form.sex" placeholder="请选择客户性别">
                <el-option
                  v-for="dict in sys_user_sex"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="客户生日" prop="birthday">
              <el-date-picker clearable
                v-model="form.birthday"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择客户生日">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="客户描述" prop="remark">
              <el-input v-model="form.remark" type="textarea" placeholder="请输入内容" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-divider content-position="center">商品信息信息</el-divider>
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" icon="Plus" @click="handleAddGoods">添加</el-button>
          </el-col>
          <el-col :span="1.5">
            <el-button type="danger" icon="Delete" @click="handleDeleteGoods">删除</el-button>
          </el-col>
        </el-row>
        <el-table :data="goodsList" @selection-change="handleGoodsSelectionChange" ref="goods">
          <el-table-column type="selection" width="50" align="center" />
          <el-table-column label="序号" width="60">
            <template #default="{ $index }">
              {{ $index + 1 }}
            </template>
          </el-table-column>
          <el-table-column label="商品名称" prop="name" width="150">
            <template #default="scope">
              <el-input v-model="scope.row.name" placeholder="请输入商品名称" />
            </template>
          </el-table-column>
          <el-table-column label="商品重量" prop="weight" width="150">
            <template #default="scope">
              <el-input v-model="scope.row.weight" placeholder="请输入商品重量" />
            </template>
          </el-table-column>
          <el-table-column label="商品价格" prop="price" width="150">
            <template #default="scope">
              <el-input v-model="scope.row.price" placeholder="请输入商品价格" />
            </template>
          </el-table-column>
          <el-table-column label="商品时间" prop="date" width="240">
            <template #default="scope">
              <el-date-picker clearable
                v-model="scope.row.date"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择商品时间">
              </el-date-picker>
            </template>
          </el-table-column>
          <el-table-column label="商品种类" prop="type" width="150">
            <template #default="scope">
              <el-select v-model="scope.row.type" placeholder="请选择商品种类">
                <el-option
                  v-for="dict in biz_goods_type"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
            </template>
          </el-table-column>
        </el-table>
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

<script setup lang="ts" name="Customer">
import type { Customer, Goods, CustomerQueryParams } from "@/types/api/demo/customer"
import { listCustomer, getCustomer, delCustomer, addCustomer, updateCustomer } from "@/api/demo/customer"
import CustomerViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { sys_user_sex, biz_goods_type } = useDict('sys_user_sex', 'biz_goods_type')

const customerList = ref<Customer[]>([])
const goodsList = ref([])
const open = ref<boolean>(false)
const loading = ref<boolean>(true)
const showSearch = ref<boolean>(true)
const ids = ref<number[]>([])
const checkedGoods = ref([])
const single = ref<boolean>(true)
const multiple = ref<boolean>(true)
const total = ref<number>(0)
const title = ref<string>("")
const daterangeBirthday = ref<string[]>([])

const data = reactive({
  form: {} as Customer,
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    customerName: undefined,
    phonenumber: undefined,
    sex: undefined,
    birthday: undefined,
  } as CustomerQueryParams,
  rules: {
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询客户信息表列表 */
function getList() {
  loading.value = true
  queryParams.value.params = {}
  if (null != daterangeBirthday.value && '' != daterangeBirthday.value) {
    queryParams.value.params["beginBirthday"] = daterangeBirthday.value[0]
    queryParams.value.params["endBirthday"] = daterangeBirthday.value[1]
  }
  listCustomer(queryParams.value).then(response => {
    customerList.value = response.rows
    total.value = response.total
    loading.value = false
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
    customerId: null,
    customerName: null,
    phonenumber: null,
    sex: null,
    birthday: null,
    remark: null
  }
  goodsList.value = []
  proxy.resetForm("customerRef")
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  daterangeBirthday.value = []
  proxy.resetForm("queryRef")
  handleQuery()
}

/** 多选框选中数据 */
function handleSelectionChange(selection: Customer[]) {
  ids.value = selection.map(item => item.customerId)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

/** 新增按钮操作 */
function handleAdd() {
  reset()
  open.value = true
  title.value = "添加客户信息表"
}

/** 修改按钮操作 */
function handleUpdate(row: Customer) {
  reset()
  const _customerId = row.customerId || ids.value[0]
  getCustomer(_customerId).then(response => {
    form.value = response.data
    goodsList.value = response.data?.goodsList ?? []
    open.value = true
    title.value = "修改客户信息表"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["customerRef"].validate((valid: boolean) => {
    if (valid) {
      form.value.goodsList = goodsList.value
      if (form.value.customerId != null) {
        updateCustomer(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addCustomer(form.value).then(() => {
          proxy.$modal.msgSuccess("新增成功")
          open.value = false
          getList()
        })
      }
    }
  })
}

/** 删除按钮操作 */
function handleDelete(row: Customer) {
  const _customerIds = row.customerId || ids.value
  proxy.$modal.confirm('是否确认删除客户信息表编号为"' + _customerIds + '"的数据项？').then(function() {
    return delCustomer(_customerIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 商品信息添加按钮操作 */
function handleAddGoods() {
  let obj: Goods = {}
  obj.name = undefined
  obj.weight = undefined
  obj.price = undefined
  obj.date = undefined
  obj.type = undefined
  goodsList.value.push(obj)
}

/** 商品信息删除按钮操作 */
function handleDeleteGoods() {
  if (checkedGoods.value.length == 0) {
    proxy.$modal.msgError("请先选择要删除的商品信息数据")
  } else {
    const goodss = goodsList.value
    const checkedGoodss = checkedGoods.value
    goodsList.value = goodss.filter(function(item: any) {
      return checkedGoodss.indexOf(item.index) == -1
    })
  }
}

/** 复选框选中数据 */
function handleGoodsSelectionChange(selection: any[]) {
  checkedGoods.value = selection.map(item => item.index)
}

/** 详情按钮操作 */
function handleViewData(row: Customer) {
  proxy.$refs["customerViewRef"].open(row.customerId)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('demo/customer/export', {
    ...queryParams.value
  }, `customer_${new Date().getTime()}.xlsx`)
}

getList()
</script>

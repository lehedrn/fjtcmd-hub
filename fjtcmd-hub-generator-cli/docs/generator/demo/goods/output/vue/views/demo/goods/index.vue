<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="客户id" prop="customerId">
        <el-input
          v-model="queryParams.customerId"
          placeholder="请输入客户id"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商品名称" prop="name">
        <el-input
          v-model="queryParams.name"
          placeholder="请输入商品名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="商品时间" style="width: 308px">
        <el-date-picker
          v-model="daterangeDate"
          value-format="YYYY-MM-DD"
          type="daterange"
          range-separator="-"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
        ></el-date-picker>
      </el-form-item>
      <el-form-item label="商品种类" prop="type">
        <el-select v-model="queryParams.type" placeholder="请选择商品种类" clearable>
          <el-option
            v-for="dict in biz_goods_type"
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
          v-hasPermi="['demo:goods:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="success"
          plain
          icon="Edit"
          :disabled="single"
          @click="handleUpdate"
          v-hasPermi="['demo:goods:edit']"
        >修改</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="danger"
          plain
          icon="Delete"
          :disabled="multiple"
          @click="handleDelete"
          v-hasPermi="['demo:goods:remove']"
        >删除</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="warning"
          plain
          icon="Download"
          @click="handleExport"
          v-hasPermi="['demo:goods:export']"
        >导出</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 表格容器：flex 布局填满剩余空间 -->
    <div class="table-container">
    <el-table ref="tableRef" v-loading="loading" :data="goodsList" :height="tableHeight" @selection-change="handleSelectionChange">
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column label="序号" width="60" align="center">
        <template #default="scope">
          {{ (queryParams.pageNum - 1) * queryParams.pageSize + scope.$index + 1 }}
        </template>
      </el-table-column>
      <el-table-column label="商品名称" align="center" prop="name" />
      <el-table-column label="商品重量" align="center" prop="weight" />
      <el-table-column label="商品价格" align="center" prop="price" />
      <el-table-column label="商品时间" align="center" prop="date" width="180">
        <template #default="scope">
          <span>{{ parseTime(scope.row.date, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="商品种类" align="center" prop="type">
        <template #default="scope">
          <dict-tag :options="biz_goods_type" :value="scope.row.type"/>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['demo:goods:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['demo:goods:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['demo:goods:remove']">删除</el-button>
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

    <!-- 商品信息详情抽屉 -->
    <goods-view-drawer ref="goodsViewRef" />
    <!-- 添加或修改商品信息对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="goodsRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="客户id" prop="customerId">
              <el-input v-model="form.customerId" placeholder="请输入客户id" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商品名称" prop="name">
              <el-input v-model="form.name" placeholder="请输入商品名称" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商品重量" prop="weight">
              <el-input v-model="form.weight" placeholder="请输入商品重量" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商品价格" prop="price">
              <el-input v-model="form.price" placeholder="请输入商品价格" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商品时间" prop="date">
              <el-date-picker clearable
                v-model="form.date"
                type="date"
                value-format="YYYY-MM-DD"
                placeholder="请选择商品时间">
              </el-date-picker>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="商品种类" prop="type">
              <el-select v-model="form.type" placeholder="请选择商品种类">
                <el-option
                  v-for="dict in biz_goods_type"
                  :key="dict.value"
                  :label="dict.label"
                  :value="dict.value"
                ></el-option>
              </el-select>
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

<script setup lang="ts" name="Goods">
import type { Goods, GoodsQueryParams } from "@/types/api/demo/goods"
import { listGoods, getGoods, delGoods, addGoods, updateGoods } from "@/api/demo/goods"
import GoodsViewDrawer from "./view"

const { proxy } = getCurrentInstance()
const { biz_goods_type } = useDict('biz_goods_type')

const goodsList = ref<Goods[]>([])
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
const daterangeDate = ref<string[]>([])

const data = reactive({
  form: {} as Goods,
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    customerId: undefined,
    name: undefined,
    date: undefined,
    type: undefined
  } as GoodsQueryParams,
  rules: {
    goodsId: [
      { required: true, message: "商品id不能为空", trigger: "blur" }
    ],
    customerId: [
      { required: true, message: "客户id不能为空", trigger: "blur" }
    ],
    name: [
      { required: true, message: "商品名称不能为空", trigger: "blur" }
    ],
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询商品信息列表 */
function getList() {
  loading.value = true
  queryParams.value.params = {}
  if (null != daterangeDate.value && '' != daterangeDate.value) {
    queryParams.value.params["beginDate"] = daterangeDate.value[0]
    queryParams.value.params["endDate"] = daterangeDate.value[1]
  }
  listGoods(queryParams.value).then(response => {
    goodsList.value = response.rows
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
    goodsId: null,
    customerId: null,
    name: null,
    weight: null,
    price: null,
    date: null,
    type: null
  }
  proxy.resetForm("goodsRef")
}

/** 搜索按钮操作 */
function handleQuery() {
  queryParams.value.pageNum = 1
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  daterangeDate.value = []
  proxy.resetForm("queryRef")
  handleQuery()
}

/** 多选框选中数据 */
function handleSelectionChange(selection: Goods[]) {
  ids.value = selection.map(item => item.goodsId)
  single.value = selection.length != 1
  multiple.value = !selection.length
}

/** 新增按钮操作 */
function handleAdd() {
  reset()
  open.value = true
  title.value = "添加商品信息"
}

/** 修改按钮操作 */
function handleUpdate(row: Goods) {
  reset()
  const _goodsId = row.goodsId || ids.value[0]
  getGoods(_goodsId).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改商品信息"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["goodsRef"].validate((valid: boolean) => {
    if (valid) {
      if (form.value.goodsId != null) {
        updateGoods(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addGoods(form.value).then(() => {
          proxy.$modal.msgSuccess("新增成功")
          open.value = false
          getList()
        })
      }
    }
  })
}

/** 删除按钮操作 */
function handleDelete(row: Goods) {
  const _goodsIds = row.goodsId || ids.value
  proxy.$modal.confirm('是否确认删除商品信息编号为"' + _goodsIds + '"的数据项？').then(function() {
    return delGoods(_goodsIds)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

/** 详情按钮操作 */
function handleViewData(row: Goods) {
  proxy.$refs["goodsViewRef"].open(row.goodsId)
}

/** 导出按钮操作 */
function handleExport() {
  proxy.download('demo/goods/export', {
    ...queryParams.value
  }, `goods_${new Date().getTime()}.xlsx`)
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

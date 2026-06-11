<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch" label-width="68px">
      <el-form-item label="产品名称" prop="productName">
        <el-input
          v-model="queryParams.productName"
          placeholder="请输入产品名称"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="显示顺序" prop="orderNum">
        <el-input
          v-model="queryParams.orderNum"
          placeholder="请输入显示顺序"
          clearable
          @keyup.enter="handleQuery"
        />
      </el-form-item>
      <el-form-item label="产品状态" prop="status">
        <el-select v-model="queryParams.status" placeholder="请选择产品状态" clearable>
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
          v-hasPermi="['demo:product:add']"
        >新增</el-button>
      </el-col>
      <el-col :span="1.5">
        <el-button
          type="info"
          plain
          icon="Sort"
          @click="toggleExpandAll"
        >展开/折叠</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <!-- 表格容器：flex 布局填满剩余空间 -->
    <div class="table-container">
    <el-table
      ref="tableRef"
      v-if="refreshTable"
      v-loading="loading"
      :data="productList"
      :height="tableHeight"
      row-key="productId"
      :default-expand-all="isExpandAll"
      :tree-props="{children: 'children', hasChildren: 'hasChildren'}"
    >
      <el-table-column label="产品名称" align="center" prop="productName" />
      <el-table-column label="显示顺序" align="center" prop="orderNum" />
      <el-table-column label="产品状态" align="center" prop="status">
        <template #default="scope">
          <dict-tag :options="sys_normal_disable" :value="scope.row.status"/>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="View" @click="handleViewData(scope.row)" v-hasPermi="['demo:product:query']">详情</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['demo:product:edit']">修改</el-button>
          <el-button link type="primary" icon="Plus" @click="handleAdd(scope.row)" v-hasPermi="['demo:product:add']">新增</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['demo:product:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
    </div>

    <!-- 产品信息详情抽屉 -->
    <product-view-drawer ref="productViewRef" />
    <!-- 添加或修改产品信息对话框 -->
    <el-dialog :title="title" v-model="open" width="500px" append-to-body>
      <el-form ref="productRef" :model="form" :rules="rules" label-width="100px">
        <el-row>
          <el-col :span="24">
            <el-form-item label="父产品id" prop="parentId">
              <el-tree-select
                v-model="form.parentId"
                :data="productOptions"
                :props="{ value: 'productId', label: 'productName', children: 'children' }"
                value-key="productId"
                placeholder="请选择父产品id"
                check-strictly
              />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="产品名称" prop="productName">
              <el-input v-model="form.productName" placeholder="请输入产品名称" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="显示顺序" prop="orderNum">
              <el-input v-model="form.orderNum" placeholder="请输入显示顺序" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="产品状态" prop="status">
              <el-select v-model="form.status" placeholder="请选择产品状态">
                <el-option
                  v-for="dict in sys_normal_disable"
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

<script setup lang="ts" name="Product">
import { listProduct, getProduct, delProduct, addProduct, updateProduct } from "@/api/demo/product"
import ProductViewDrawer from "./view"
import type { Product, ProductQueryParams } from "@/types/api/demo/product"
import type { TreeSelect } from '@/types/api/common'

const { proxy } = getCurrentInstance()
const { sys_normal_disable } = useDict('sys_normal_disable')

const productList = ref<any[]>([])
const productOptions = ref<TreeSelect[]>([])
const open = ref<boolean>(false)
const loading = ref<boolean>(true)
const showSearch = ref<boolean>(true)
const title = ref<string>("")
const isExpandAll = ref<boolean>(true)
const refreshTable = ref<boolean>(true)
const tableRef = ref()
const tableHeight = ref<number>(0)

const data = reactive({
  form: {} as Product,
  queryParams: {
    productName: undefined,
    orderNum: undefined,
    status: undefined
  } as ProductQueryParams,
  rules: {
    parentId: [
      { required: true, message: "父产品id不能为空", trigger: "blur" }
    ],
    productName: [
      { required: true, message: "产品名称不能为空", trigger: "blur" }
    ],
    status: [
      { required: true, message: "产品状态不能为空", trigger: "change" }
    ]
  }
})

const { queryParams, form, rules } = toRefs(data)

/** 查询产品信息列表 */
function getList() {
  loading.value = true
  listProduct(queryParams.value).then(response => {
    productList.value = proxy.handleTree(response.data, "productId", "parentId")
    loading.value = false
    calcTableHeight()
  })
}

/** 查询产品信息下拉树结构 */
function getTreeselect() {
  listProduct().then(response => {
    productOptions.value = []
    const data = { productId: 0, productName: '顶级节点', children: [] }
    data.children = proxy.handleTree(response.data, "productId", "parentId")
    productOptions.value.push(data)
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
    productId: null,
    parentId: null,
    ancestors: null,
    productName: null,
    orderNum: null,
    status: null
  }
  proxy.resetForm("productRef")
}

/** 搜索按钮操作 */
function handleQuery() {
  getList()
}

/** 重置按钮操作 */
function resetQuery() {
  proxy.resetForm("queryRef")
  handleQuery()
}

/** 新增按钮操作 */
function handleAdd(row: Product) {
  reset()
  getTreeselect()
  if (row != null && row.productId) {
    form.value.parentId = row.productId
  } else {
    form.value.parentId = 0
  }
  open.value = true
  title.value = "添加产品信息"
}

/** 展开/折叠操作 */
function toggleExpandAll() {
  refreshTable.value = false
  isExpandAll.value = !isExpandAll.value
  nextTick(() => {
    refreshTable.value = true
  })
}

/** 详情按钮操作 */
function handleViewData(row: Product) {
  proxy.$refs["productViewRef"].open(row.productId)
}

/** 修改按钮操作 */
async function handleUpdate(row: Product) {
  reset()
  await getTreeselect()
  if (row != null) {
    form.value.parentId = row.parentId
  }
  getProduct(row.productId!).then(response => {
    form.value = response.data
    open.value = true
    title.value = "修改产品信息"
  })
}

/** 提交按钮 */
function submitForm() {
  proxy.$refs["productRef"].validate((valid: boolean) => {
    if (valid) {
      if (form.value.productId != null) {
        updateProduct(form.value).then(() => {
          proxy.$modal.msgSuccess("修改成功")
          open.value = false
          getList()
        })
      } else {
        addProduct(form.value).then(() => {
          proxy.$modal.msgSuccess("新增成功")
          open.value = false
          getList()
        })
      }
    }
  })
}

/** 删除按钮操作 */
function handleDelete(row: Product) {
  proxy.$modal.confirm('是否确认删除产品信息编号为"' + row.productId + '"的数据项？').then(function() {
    return delProduct(row.productId!)
  }).then(() => {
    getList()
    proxy.$modal.msgSuccess("删除成功")
  }).catch(() => {})
}

getList()

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
</style>

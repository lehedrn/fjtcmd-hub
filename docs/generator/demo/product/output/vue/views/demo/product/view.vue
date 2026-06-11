<template>
  <el-drawer title="产品信息详情" v-model="visible" direction="rtl" size="60%" append-to-body :before-close="handleClose" class="detail-drawer">
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">基本信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">父产品id：</label>
            <span class="info-value plaintext">
              {{ info.parentId }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">祖级列表：</label>
            <span class="info-value plaintext">
              {{ info.ancestors }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">产品名称：</label>
            <span class="info-value plaintext">
              {{ info.productName }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">显示顺序：</label>
            <span class="info-value plaintext">
              {{ info.orderNum }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">产品状态：</label>
            <span class="info-value plaintext">
              <dict-tag :options="sys_normal_disable" :value="info.status" />
            </span>
          </div>
        </el-col>
      </el-row>
    </div>
  </el-drawer>
</template>

<script setup lang="ts" name="ProductViewDrawer">
import type { Product } from "@/types/api/demo/product"
import { getProduct } from '@/api/demo/product'

const { sys_normal_disable } = useDict('sys_normal_disable')

const visible = ref<boolean>(false)
const loading = ref<boolean>(false)
const info = reactive<Partial<Product>>({})

const open = async (productId: number): Promise<void> => {
  visible.value = true
  loading.value = true
  try {
    const res = await getProduct(productId)
    Object.assign(info, res.data ?? {})
  } catch (error) {
    console.error('获取产品信息信息失败:', error)
  } finally {
    loading.value = false
  }
}

const handleClose = (): void => {
  visible.value = false
  Object.keys(info).forEach(key => delete (info as any)[key])
}

defineExpose({ open })
</script>

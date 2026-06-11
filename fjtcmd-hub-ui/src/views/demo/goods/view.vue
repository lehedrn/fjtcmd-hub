<template>
  <el-drawer title="商品信息详情" v-model="visible" direction="rtl" size="60%" append-to-body :before-close="handleClose" class="detail-drawer">
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">基本信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">客户id：</label>
            <span class="info-value plaintext">
              {{ info.customerId }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">商品名称：</label>
            <span class="info-value plaintext">
              {{ info.name }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">商品重量：</label>
            <span class="info-value plaintext">
              {{ info.weight }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">商品价格：</label>
            <span class="info-value plaintext">
              {{ info.price }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">商品时间：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.date, '{y}-{m}-{d}') }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">商品种类：</label>
            <span class="info-value plaintext">
              <dict-tag :options="biz_goods_type" :value="info.type" />
            </span>
          </div>
        </el-col>
      </el-row>
    </div>
  </el-drawer>
</template>

<script setup lang="ts" name="GoodsViewDrawer">
import type { Goods } from "@/types/api/demo/goods"
import { getGoods } from '@/api/demo/goods'

const { biz_goods_type } = useDict('biz_goods_type')

const visible = ref<boolean>(false)
const loading = ref<boolean>(false)
const info = reactive<Partial<Goods>>({})

const open = async (goodsId: number): Promise<void> => {
  visible.value = true
  loading.value = true
  try {
    const res = await getGoods(goodsId)
    Object.assign(info, res.data ?? {})
  } catch (error) {
    console.error('获取商品信息信息失败:', error)
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

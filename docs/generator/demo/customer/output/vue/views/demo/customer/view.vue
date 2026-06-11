<template>
  <el-drawer title="客户信息详情" v-model="visible" direction="rtl" size="60%" append-to-body :before-close="handleClose" class="detail-drawer">
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">基本信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">客户姓名：</label>
            <span class="info-value plaintext">
              {{ info.customerName }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">手机号码：</label>
            <span class="info-value plaintext">
              {{ info.phonenumber }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">客户性别：</label>
            <span class="info-value plaintext">
              <dict-tag :options="sys_user_sex" :value="info.sex" />
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">客户生日：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.birthday, '{y}-{m}-{d}') }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">客户描述：</label>
            <span class="info-value plaintext">
              {{ info.remark }}
            </span>
          </div>
        </el-col>
      </el-row>
    </div>
  </el-drawer>
</template>

<script setup lang="ts" name="CustomerViewDrawer">
import type { Customer } from "@/types/api/demo/customer"
import { getCustomer } from '@/api/demo/customer'

const { sys_user_sex } = useDict('sys_user_sex')

const visible = ref<boolean>(false)
const loading = ref<boolean>(false)
const info = reactive<Partial<Customer>>({})

const open = async (customerId: number): Promise<void> => {
  visible.value = true
  loading.value = true
  try {
    const res = await getCustomer(customerId)
    Object.assign(info, res.data ?? {})
  } catch (error) {
    console.error('获取客户信息信息失败:', error)
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

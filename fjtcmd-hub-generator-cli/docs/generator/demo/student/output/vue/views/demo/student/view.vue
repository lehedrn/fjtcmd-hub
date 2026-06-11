<template>
  <el-drawer title="学生信息详情" v-model="visible" direction="rtl" size="60%" append-to-body :before-close="handleClose" class="detail-drawer">
    <div v-loading="loading" class="drawer-content">
      <h4 class="section-header">基本信息</h4>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">学生名称：</label>
            <span class="info-value plaintext">
              {{ info.studentName }}
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">年龄：</label>
            <span class="info-value plaintext">
              {{ info.studentAge }}
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">爱好：</label>
            <span class="info-value plaintext">
              <dict-tag :options="biz_student_hobby" :value="info.studentHobby ? info.studentHobby.split(',') : []" />
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">性别：</label>
            <span class="info-value plaintext">
              <dict-tag :options="sys_user_sex" :value="info.studentSex" />
            </span>
          </div>
        </el-col>
      </el-row>
      <el-row :gutter="20" class="mb8">
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">状态：</label>
            <span class="info-value plaintext">
              <dict-tag :options="sys_normal_disable" :value="info.studentStatus" />
            </span>
          </div>
        </el-col>
        <el-col :span="12">
          <div class="info-item">
            <label class="info-label">生日：</label>
            <span class="info-value plaintext">
              {{ parseTime(info.studentBirthday, '{y}-{m}-{d}') }}
            </span>
          </div>
        </el-col>
      </el-row>
    </div>
  </el-drawer>
</template>

<script setup lang="ts" name="StudentViewDrawer">
import type { Student } from "@/types/api/demo/student"
import { getStudent } from '@/api/demo/student'

const { biz_student_hobby, sys_user_sex, sys_normal_disable } = useDict('biz_student_hobby', 'sys_user_sex', 'sys_normal_disable')

const visible = ref<boolean>(false)
const loading = ref<boolean>(false)
const info = reactive<Partial<Student>>({})

const open = async (studentId: number): Promise<void> => {
  visible.value = true
  loading.value = true
  try {
    const res = await getStudent(studentId)
    Object.assign(info, res.data ?? {})
  } catch (error) {
    console.error('获取学生信息信息失败:', error)
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

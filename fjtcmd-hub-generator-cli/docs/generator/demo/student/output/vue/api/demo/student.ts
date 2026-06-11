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



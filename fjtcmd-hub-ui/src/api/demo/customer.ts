import request from '@/utils/request'
import type { AjaxResult, TableDataInfo, CustomerQueryParams, Customer } from '@/types'

// 查询客户信息列表
export function listCustomer(query: CustomerQueryParams): Promise<TableDataInfo<Customer[]>> {
  return request({
    url: '/demo/customer/list',
    method: 'get',
    params: query
  })
}

// 查询客户信息详细
export function getCustomer(customerId: number): Promise<AjaxResult<Customer>> {
  return request({
    url: '/demo/customer/' + customerId,
    method: 'get'
  })
}

// 新增客户信息
export function addCustomer(data: Customer): Promise<AjaxResult> {
  return request({
    url: '/demo/customer',
    method: 'post',
    data: data
  })
}

// 修改客户信息
export function updateCustomer(data: Customer): Promise<AjaxResult> {
  return request({
    url: '/demo/customer',
    method: 'put',
    data: data
  })
}

// 删除客户信息
export function delCustomer(customerId: number | number[]): Promise<AjaxResult> {
  return request({
    url: '/demo/customer/' + customerId,
    method: 'delete'
  })
}



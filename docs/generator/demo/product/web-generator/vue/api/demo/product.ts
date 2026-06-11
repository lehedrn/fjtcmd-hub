import request from '@/utils/request'
import type { AjaxResult, TableDataInfo, ProductQueryParams, Product } from '@/types'

// 查询产品信息列表
export function listProduct(query?: ProductQueryParams): Promise<AjaxResult<Product[]>> {
  return request({
    url: '/demo/product/list',
    method: 'get',
    params: query
  })
}

// 查询产品信息详细
export function getProduct(productId: number): Promise<AjaxResult<Product>> {
  return request({
    url: '/demo/product/' + productId,
    method: 'get'
  })
}

// 新增产品信息
export function addProduct(data: Product): Promise<AjaxResult> {
  return request({
    url: '/demo/product',
    method: 'post',
    data: data
  })
}

// 修改产品信息
export function updateProduct(data: Product): Promise<AjaxResult> {
  return request({
    url: '/demo/product',
    method: 'put',
    data: data
  })
}

// 删除产品信息
export function delProduct(productId: number | number[]): Promise<AjaxResult> {
  return request({
    url: '/demo/product/' + productId,
    method: 'delete'
  })
}



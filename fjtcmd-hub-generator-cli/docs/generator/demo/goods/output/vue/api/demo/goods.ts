import request from '@/utils/request'
import type { AjaxResult, TableDataInfo, GoodsQueryParams, Goods } from '@/types'

// 查询商品信息列表
export function listGoods(query: GoodsQueryParams): Promise<TableDataInfo<Goods[]>> {
  return request({
    url: '/demo/goods/list',
    method: 'get',
    params: query
  })
}

// 查询商品信息详细
export function getGoods(goodsId: number): Promise<AjaxResult<Goods>> {
  return request({
    url: '/demo/goods/' + goodsId,
    method: 'get'
  })
}

// 新增商品信息
export function addGoods(data: Goods): Promise<AjaxResult> {
  return request({
    url: '/demo/goods',
    method: 'post',
    data: data
  })
}

// 修改商品信息
export function updateGoods(data: Goods): Promise<AjaxResult> {
  return request({
    url: '/demo/goods',
    method: 'put',
    data: data
  })
}

// 删除商品信息
export function delGoods(goodsId: number | number[]): Promise<AjaxResult> {
  return request({
    url: '/demo/goods/' + goodsId,
    method: 'delete'
  })
}



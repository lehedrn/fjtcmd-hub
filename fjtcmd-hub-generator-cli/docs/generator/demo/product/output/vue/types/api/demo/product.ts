import type { PageDomain, BaseEntity } from "../common";

/** 产品信息配置分页查询参数 */
export interface ProductQueryParams extends PageDomain {
  /** 产品名称 */
  productName?: string;
  /** 显示顺序 */
  orderNum?: number;
  /** 产品状态（0正常 1停用） */
  status?: string;
}

/** 产品信息配置信息 */
export interface Product extends BaseEntity {
  /** 产品id */
  productId?: number;
  /** 父产品id */
  parentId?: number;
  /** 祖级列表 */
  ancestors?: string;
  /** 产品名称 */
  productName?: string;
  /** 显示顺序 */
  orderNum?: number;
  /** 产品状态（0正常 1停用） */
  status?: string;
}

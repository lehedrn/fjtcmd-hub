import type { PageDomain, BaseEntity } from "../common";

/** 客户信息表配置分页查询参数 */
export interface CustomerQueryParams extends PageDomain {
  /** 客户姓名 */
  customerName?: string;
  /** 手机号码 */
  phonenumber?: string;
  /** 客户性别 */
  sex?: string;
  /** 客户生日 */
  birthday?: string;
}

/** 客户信息表配置信息 */
export interface Customer extends BaseEntity {
  /** 客户id */
  customerId?: number;
  /** 客户姓名 */
  customerName?: string;
  /** 手机号码 */
  phonenumber?: string;
  /** 客户性别 */
  sex?: string;
  /** 客户生日 */
  birthday?: string;
  /** 客户描述 */
  remark?: string;
  /** 商品信息信息 */
  goodsList?: Goods[];
}

/** 商品信息配置信息 */
export interface Goods extends BaseEntity {
  /** 商品id */
  goodsId?: number;
  /** 客户id */
  customerId?: number;
  /** 商品名称 */
  name?: string;
  /** 商品重量 */
  weight?: number;
  /** 商品价格 */
  price?: string;
  /** 商品时间 */
  date?: string;
  /** 商品种类（0食品 1日用品 2电子产品 3其他） */
  type?: string;
}

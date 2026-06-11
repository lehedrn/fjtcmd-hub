import type { PageDomain, BaseEntity } from "../common";

/** 客户信息配置分页查询参数 */
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

/** 客户信息配置信息 */
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
}

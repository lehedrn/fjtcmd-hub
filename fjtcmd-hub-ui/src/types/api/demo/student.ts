import type { PageDomain, BaseEntity } from "../common";

/** 学生信息配置分页查询参数 */
export interface StudentQueryParams extends PageDomain {
  /** 学生名称 */
  studentName?: string;
  /** 性别（0男 1女 2未知） */
  studentSex?: string;
  /** 生日 */
  studentBirthday?: string;
  /** 联系电话 */
  studentPhone?: string;
  /** 状态（0正常 1停用） */
  status?: string;
}

/** 学生信息配置信息 */
export interface Student extends BaseEntity {
  /** 编号 */
  studentId?: number;
  /** 学生名称 */
  studentName?: string;
  /** 性别（0男 1女 2未知） */
  studentSex?: string;
  /** 年龄 */
  studentAge?: number;
  /** 生日 */
  studentBirthday?: string;
  /** 联系电话 */
  studentPhone?: string;
  /** 状态（0正常 1停用） */
  status?: string;
  /** 创建者 */
  createBy?: string;
  /** 创建时间 */
  createTime?: string;
  /** 更新者 */
  updateBy?: string;
  /** 更新时间 */
  updateTime?: string;
  /** 备注 */
  remark?: string;
  /** 删除标志（0代表存在 1代表删除） */
  delFlag?: string;
}

import type { PageDomain, BaseEntity } from "../common";

/** 学生信息配置分页查询参数 */
export interface StudentQueryParams extends PageDomain {
  /** 学生名称 */
  studentName?: string;
  /** 性别（0男 1女 2未知） */
  studentSex?: string;
  /** 状态（0正常 1停用） */
  studentStatus?: string;
  /** 生日 */
  studentBirthday?: string;
}

/** 学生信息配置信息 */
export interface Student extends BaseEntity {
  /** 编号 */
  studentId?: number;
  /** 学生名称 */
  studentName?: string;
  /** 年龄 */
  studentAge?: number;
  /** 爱好（0代码 1音乐 2电影） */
  studentHobby?: string;
  /** 性别（0男 1女 2未知） */
  studentSex?: string;
  /** 状态（0正常 1停用） */
  studentStatus?: string;
  /** 生日 */
  studentBirthday?: string;
}

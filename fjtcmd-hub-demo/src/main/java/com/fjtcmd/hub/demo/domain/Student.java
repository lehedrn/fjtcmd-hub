package com.fjtcmd.hub.demo.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.fjtcmd.hub.common.annotation.Excel;
import com.fjtcmd.hub.common.core.domain.BaseEntity;

/**
 * 学生信息对象 sys_student
 * 
 * @author fjtcmd
 * @date 2026-06-11
 */
public class Student extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 编号 */
    private Long studentId;

    /** 学生名称 */
    @Excel(name = "学生名称")
    private String studentName;

    /** 性别（0男 1女 2未知） */
    @Excel(name = "性别", readConverterExp = "0=男,1=女,2=未知")
    private String studentSex;

    /** 年龄 */
    @Excel(name = "年龄")
    private Integer studentAge;

    /** 生日 */
    @JsonFormat(pattern = "yyyy-MM-dd")
    @Excel(name = "生日", width = 30, dateFormat = "yyyy-MM-dd")
    private Date studentBirthday;

    /** 联系电话 */
    @Excel(name = "联系电话")
    private String studentPhone;

    /** 状态（0正常 1停用） */
    @Excel(name = "状态", readConverterExp = "0=正常,1=停用")
    private String status;

    /** 删除标志（0代表存在 1代表删除） */
    private String delFlag;

    public void setStudentId(Long studentId) 
    {
        this.studentId = studentId;
    }

    public Long getStudentId() 
    {
        return studentId;
    }

    public void setStudentName(String studentName) 
    {
        this.studentName = studentName;
    }

    public String getStudentName() 
    {
        return studentName;
    }

    public void setStudentSex(String studentSex) 
    {
        this.studentSex = studentSex;
    }

    public String getStudentSex() 
    {
        return studentSex;
    }

    public void setStudentAge(Integer studentAge) 
    {
        this.studentAge = studentAge;
    }

    public Integer getStudentAge() 
    {
        return studentAge;
    }

    public void setStudentBirthday(Date studentBirthday) 
    {
        this.studentBirthday = studentBirthday;
    }

    public Date getStudentBirthday() 
    {
        return studentBirthday;
    }

    public void setStudentPhone(String studentPhone) 
    {
        this.studentPhone = studentPhone;
    }

    public String getStudentPhone() 
    {
        return studentPhone;
    }

    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
    }

    public void setDelFlag(String delFlag) 
    {
        this.delFlag = delFlag;
    }

    public String getDelFlag() 
    {
        return delFlag;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("studentId", getStudentId())
            .append("studentName", getStudentName())
            .append("studentSex", getStudentSex())
            .append("studentAge", getStudentAge())
            .append("studentBirthday", getStudentBirthday())
            .append("studentPhone", getStudentPhone())
            .append("status", getStatus())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .append("delFlag", getDelFlag())
            .toString();
    }
}

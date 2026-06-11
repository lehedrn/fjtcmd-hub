package com.fjtcmd.hub.demo.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.fjtcmd.hub.common.annotation.Excel;
import com.fjtcmd.hub.common.core.domain.TreeEntity;

/**
 * 产品信息对象 sys_product
 * 
 * @author lihd
 * @date 2026-06-11
 */
public class Product extends TreeEntity
{
    private static final long serialVersionUID = 1L;

    /** 产品id */
    private Long productId;

    /** 产品名称 */
    @Excel(name = "产品名称")
    private String productName;

    /** 产品状态（0正常 1停用） */
    @Excel(name = "产品状态", readConverterExp = "0=正常,1=停用")
    private String status;

    public void setProductId(Long productId) 
    {
        this.productId = productId;
    }

    public Long getProductId() 
    {
        return productId;
    }

    public void setProductName(String productName) 
    {
        this.productName = productName;
    }

    public String getProductName() 
    {
        return productName;
    }

    public void setStatus(String status) 
    {
        this.status = status;
    }

    public String getStatus() 
    {
        return status;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this,ToStringStyle.MULTI_LINE_STYLE)
            .append("productId", getProductId())
            .append("parentId", getParentId())
            .append("ancestors", getAncestors())
            .append("productName", getProductName())
            .append("orderNum", getOrderNum())
            .append("status", getStatus())
            .toString();
    }
}

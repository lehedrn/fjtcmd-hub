package com.fjtcmd.hub.demo.service;

import java.util.List;
import com.fjtcmd.hub.demo.domain.Customer;

/**
 * 客户信息表Service接口
 * 
 * @author lihd
 * @date 2026-06-10
 */
public interface ICustomerService 
{
    /**
     * 查询客户信息表
     * 
     * @param customerId 客户信息表主键
     * @return 客户信息表
     */
    public Customer selectCustomerByCustomerId(Long customerId);

    /**
     * 查询客户信息表列表
     * 
     * @param customer 客户信息表
     * @return 客户信息表集合
     */
    public List<Customer> selectCustomerList(Customer customer);

    /**
     * 新增客户信息表
     * 
     * @param customer 客户信息表
     * @return 结果
     */
    public int insertCustomer(Customer customer);

    /**
     * 修改客户信息表
     * 
     * @param customer 客户信息表
     * @return 结果
     */
    public int updateCustomer(Customer customer);

    /**
     * 批量删除客户信息表
     * 
     * @param customerIds 需要删除的客户信息表主键集合
     * @return 结果
     */
    public int deleteCustomerByCustomerIds(Long[] customerIds);

    /**
     * 删除客户信息表信息
     * 
     * @param customerId 客户信息表主键
     * @return 结果
     */
    public int deleteCustomerByCustomerId(Long customerId);
}

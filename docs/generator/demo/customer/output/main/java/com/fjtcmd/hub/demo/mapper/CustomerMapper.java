package com.fjtcmd.hub.demo.mapper;

import java.util.List;
import com.fjtcmd.hub.demo.domain.Customer;

/**
 * 客户信息Mapper接口
 * 
 * @author lihd
 * @date 2026-06-11
 */
public interface CustomerMapper 
{
    /**
     * 查询客户信息
     * 
     * @param customerId 客户信息主键
     * @return 客户信息
     */
    public Customer selectCustomerByCustomerId(Long customerId);

    /**
     * 查询客户信息列表
     * 
     * @param customer 客户信息
     * @return 客户信息集合
     */
    public List<Customer> selectCustomerList(Customer customer);

    /**
     * 新增客户信息
     * 
     * @param customer 客户信息
     * @return 结果
     */
    public int insertCustomer(Customer customer);

    /**
     * 修改客户信息
     * 
     * @param customer 客户信息
     * @return 结果
     */
    public int updateCustomer(Customer customer);

    /**
     * 删除客户信息
     * 
     * @param customerId 客户信息主键
     * @return 结果
     */
    public int deleteCustomerByCustomerId(Long customerId);

    /**
     * 批量删除客户信息
     * 
     * @param customerIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteCustomerByCustomerIds(Long[] customerIds);
}

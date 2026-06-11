package com.fjtcmd.hub.demo.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.fjtcmd.hub.demo.mapper.CustomerMapper;
import com.fjtcmd.hub.demo.domain.Customer;
import com.fjtcmd.hub.demo.service.ICustomerService;

/**
 * 客户信息Service业务层处理
 * 
 * @author lihd
 * @date 2026-06-11
 */
@Service
public class CustomerServiceImpl implements ICustomerService 
{
    @Autowired
    private CustomerMapper customerMapper;

    /**
     * 查询客户信息
     * 
     * @param customerId 客户信息主键
     * @return 客户信息
     */
    @Override
    public Customer selectCustomerByCustomerId(Long customerId)
    {
        return customerMapper.selectCustomerByCustomerId(customerId);
    }

    /**
     * 查询客户信息列表
     * 
     * @param customer 客户信息
     * @return 客户信息
     */
    @Override
    public List<Customer> selectCustomerList(Customer customer)
    {
        return customerMapper.selectCustomerList(customer);
    }

    /**
     * 新增客户信息
     * 
     * @param customer 客户信息
     * @return 结果
     */
    @Override
    public int insertCustomer(Customer customer)
    {
        return customerMapper.insertCustomer(customer);
    }

    /**
     * 修改客户信息
     * 
     * @param customer 客户信息
     * @return 结果
     */
    @Override
    public int updateCustomer(Customer customer)
    {
        return customerMapper.updateCustomer(customer);
    }

    /**
     * 批量删除客户信息
     * 
     * @param customerIds 需要删除的客户信息主键
     * @return 结果
     */
    @Override
    public int deleteCustomerByCustomerIds(Long[] customerIds)
    {
        return customerMapper.deleteCustomerByCustomerIds(customerIds);
    }

    /**
     * 删除客户信息信息
     * 
     * @param customerId 客户信息主键
     * @return 结果
     */
    @Override
    public int deleteCustomerByCustomerId(Long customerId)
    {
        return customerMapper.deleteCustomerByCustomerId(customerId);
    }
}

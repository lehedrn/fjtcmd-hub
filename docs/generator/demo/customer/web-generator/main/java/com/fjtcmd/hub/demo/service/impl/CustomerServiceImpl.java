package com.fjtcmd.hub.demo.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import com.fjtcmd.hub.common.utils.StringUtils;
import org.springframework.transaction.annotation.Transactional;
import com.fjtcmd.hub.demo.domain.Goods;
import com.fjtcmd.hub.demo.mapper.CustomerMapper;
import com.fjtcmd.hub.demo.domain.Customer;
import com.fjtcmd.hub.demo.service.ICustomerService;

/**
 * 客户信息表Service业务层处理
 * 
 * @author lihd
 * @date 2026-06-10
 */
@Service
public class CustomerServiceImpl implements ICustomerService 
{
    @Autowired
    private CustomerMapper customerMapper;

    /**
     * 查询客户信息表
     * 
     * @param customerId 客户信息表主键
     * @return 客户信息表
     */
    @Override
    public Customer selectCustomerByCustomerId(Long customerId)
    {
        return customerMapper.selectCustomerByCustomerId(customerId);
    }

    /**
     * 查询客户信息表列表
     * 
     * @param customer 客户信息表
     * @return 客户信息表
     */
    @Override
    public List<Customer> selectCustomerList(Customer customer)
    {
        return customerMapper.selectCustomerList(customer);
    }

    /**
     * 新增客户信息表
     * 
     * @param customer 客户信息表
     * @return 结果
     */
    @Transactional
    @Override
    public int insertCustomer(Customer customer)
    {
        int rows = customerMapper.insertCustomer(customer);
        insertGoods(customer);
        return rows;
    }

    /**
     * 修改客户信息表
     * 
     * @param customer 客户信息表
     * @return 结果
     */
    @Transactional
    @Override
    public int updateCustomer(Customer customer)
    {
        customerMapper.deleteGoodsByCustomerId(customer.getCustomerId());
        insertGoods(customer);
        return customerMapper.updateCustomer(customer);
    }

    /**
     * 批量删除客户信息表
     * 
     * @param customerIds 需要删除的客户信息表主键
     * @return 结果
     */
    @Transactional
    @Override
    public int deleteCustomerByCustomerIds(Long[] customerIds)
    {
        customerMapper.deleteGoodsByCustomerIds(customerIds);
        return customerMapper.deleteCustomerByCustomerIds(customerIds);
    }

    /**
     * 删除客户信息表信息
     * 
     * @param customerId 客户信息表主键
     * @return 结果
     */
    @Transactional
    @Override
    public int deleteCustomerByCustomerId(Long customerId)
    {
        customerMapper.deleteGoodsByCustomerId(customerId);
        return customerMapper.deleteCustomerByCustomerId(customerId);
    }

    /**
     * 新增商品信息信息
     * 
     * @param customer 客户信息表对象
     */
    public void insertGoods(Customer customer)
    {
        List<Goods> goodsList = customer.getGoodsList();
        Long customerId = customer.getCustomerId();
        if (StringUtils.isNotNull(goodsList))
        {
            List<Goods> list = new ArrayList<Goods>();
            for (Goods goods : goodsList)
            {
                goods.setCustomerId(customerId);
                list.add(goods);
            }
            if (list.size() > 0)
            {
                customerMapper.batchGoods(list);
            }
        }
    }
}

package com.fjtcmd.hub.demo.mapper;

import java.util.List;
import com.fjtcmd.hub.demo.domain.Customer;
import com.fjtcmd.hub.demo.domain.Goods;

/**
 * 客户信息表Mapper接口
 * 
 * @author lihd
 * @date 2026-06-11
 */
public interface CustomerMapper 
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
     * 删除客户信息表
     * 
     * @param customerId 客户信息表主键
     * @return 结果
     */
    public int deleteCustomerByCustomerId(Long customerId);

    /**
     * 批量删除客户信息表
     * 
     * @param customerIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteCustomerByCustomerIds(Long[] customerIds);

    /**
     * 批量删除商品信息
     * 
     * @param customerIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteGoodsByCustomerIds(Long[] customerIds);
    
    /**
     * 批量新增商品信息
     * 
     * @param goodsList 商品信息列表
     * @return 结果
     */
    public int batchGoods(List<Goods> goodsList);
    

    /**
     * 通过客户信息表主键删除商品信息信息
     * 
     * @param customerId 客户信息表ID
     * @return 结果
     */
    public int deleteGoodsByCustomerId(Long customerId);
}

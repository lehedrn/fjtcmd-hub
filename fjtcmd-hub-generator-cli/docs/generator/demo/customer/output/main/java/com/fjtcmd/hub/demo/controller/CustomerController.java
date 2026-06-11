package com.fjtcmd.hub.demo.controller;

import java.util.List;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.fjtcmd.hub.common.annotation.Log;
import com.fjtcmd.hub.common.core.controller.BaseController;
import com.fjtcmd.hub.common.core.domain.AjaxResult;
import com.fjtcmd.hub.common.enums.BusinessType;
import com.fjtcmd.hub.demo.domain.Customer;
import com.fjtcmd.hub.demo.service.ICustomerService;
import com.fjtcmd.hub.common.utils.poi.ExcelUtil;
import com.fjtcmd.hub.common.core.page.TableDataInfo;

/**
 * 客户信息表Controller
 * 
 * @author lihd
 * @date 2026-06-11
 */
@RestController
@RequestMapping("/demo/customer")
public class CustomerController extends BaseController
{
    @Autowired
    private ICustomerService customerService;

    /**
     * 查询客户信息表列表
     */
    @PreAuthorize("@ss.hasPermi('demo:customer:list')")
    @GetMapping("/list")
    public TableDataInfo list(Customer customer)
    {
        startPage();
        List<Customer> list = customerService.selectCustomerList(customer);
        return getDataTable(list);
    }

    /**
     * 导出客户信息表列表
     */
    @PreAuthorize("@ss.hasPermi('demo:customer:export')")
    @Log(title = "客户信息表", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Customer customer)
    {
        List<Customer> list = customerService.selectCustomerList(customer);
        ExcelUtil<Customer> util = new ExcelUtil<Customer>(Customer.class);
        util.exportExcel(response, list, "客户信息表数据");
    }

    /**
     * 获取客户信息表详细信息
     */
    @PreAuthorize("@ss.hasPermi('demo:customer:query')")
    @GetMapping(value = "/{customerId}")
    public AjaxResult getInfo(@PathVariable("customerId") Long customerId)
    {
        return success(customerService.selectCustomerByCustomerId(customerId));
    }

    /**
     * 新增客户信息表
     */
    @PreAuthorize("@ss.hasPermi('demo:customer:add')")
    @Log(title = "客户信息表", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Customer customer)
    {
        return toAjax(customerService.insertCustomer(customer));
    }

    /**
     * 修改客户信息表
     */
    @PreAuthorize("@ss.hasPermi('demo:customer:edit')")
    @Log(title = "客户信息表", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Customer customer)
    {
        return toAjax(customerService.updateCustomer(customer));
    }

    /**
     * 删除客户信息表
     */
    @PreAuthorize("@ss.hasPermi('demo:customer:remove')")
    @Log(title = "客户信息表", businessType = BusinessType.DELETE)
	@DeleteMapping("/{customerIds}")
    public AjaxResult remove(@PathVariable Long[] customerIds)
    {
        return toAjax(customerService.deleteCustomerByCustomerIds(customerIds));
    }
}

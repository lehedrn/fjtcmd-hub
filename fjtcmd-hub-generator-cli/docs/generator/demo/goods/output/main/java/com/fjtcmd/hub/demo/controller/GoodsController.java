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
import com.fjtcmd.hub.demo.domain.Goods;
import com.fjtcmd.hub.demo.service.IGoodsService;
import com.fjtcmd.hub.common.utils.poi.ExcelUtil;
import com.fjtcmd.hub.common.core.page.TableDataInfo;

/**
 * 商品信息Controller
 * 
 * @author lihd
 * @date 2026-06-11
 */
@RestController
@RequestMapping("/demo/goods")
public class GoodsController extends BaseController
{
    @Autowired
    private IGoodsService goodsService;

    /**
     * 查询商品信息列表
     */
    @PreAuthorize("@ss.hasPermi('demo:goods:list')")
    @GetMapping("/list")
    public TableDataInfo list(Goods goods)
    {
        startPage();
        List<Goods> list = goodsService.selectGoodsList(goods);
        return getDataTable(list);
    }

    /**
     * 导出商品信息列表
     */
    @PreAuthorize("@ss.hasPermi('demo:goods:export')")
    @Log(title = "商品信息", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(HttpServletResponse response, Goods goods)
    {
        List<Goods> list = goodsService.selectGoodsList(goods);
        ExcelUtil<Goods> util = new ExcelUtil<Goods>(Goods.class);
        util.exportExcel(response, list, "商品信息数据");
    }

    /**
     * 获取商品信息详细信息
     */
    @PreAuthorize("@ss.hasPermi('demo:goods:query')")
    @GetMapping(value = "/{goodsId}")
    public AjaxResult getInfo(@PathVariable("goodsId") Long goodsId)
    {
        return success(goodsService.selectGoodsByGoodsId(goodsId));
    }

    /**
     * 新增商品信息
     */
    @PreAuthorize("@ss.hasPermi('demo:goods:add')")
    @Log(title = "商品信息", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@RequestBody Goods goods)
    {
        return toAjax(goodsService.insertGoods(goods));
    }

    /**
     * 修改商品信息
     */
    @PreAuthorize("@ss.hasPermi('demo:goods:edit')")
    @Log(title = "商品信息", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@RequestBody Goods goods)
    {
        return toAjax(goodsService.updateGoods(goods));
    }

    /**
     * 删除商品信息
     */
    @PreAuthorize("@ss.hasPermi('demo:goods:remove')")
    @Log(title = "商品信息", businessType = BusinessType.DELETE)
	@DeleteMapping("/{goodsIds}")
    public AjaxResult remove(@PathVariable Long[] goodsIds)
    {
        return toAjax(goodsService.deleteGoodsByGoodsIds(goodsIds));
    }
}

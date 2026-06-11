package com.fjtcmd.hub.demo.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.fjtcmd.hub.demo.mapper.GoodsMapper;
import com.fjtcmd.hub.demo.domain.Goods;
import com.fjtcmd.hub.demo.service.IGoodsService;

/**
 * 商品信息Service业务层处理
 * 
 * @author lihd
 * @date 2026-06-11
 */
@Service
public class GoodsServiceImpl implements IGoodsService 
{
    @Autowired
    private GoodsMapper goodsMapper;

    /**
     * 查询商品信息
     * 
     * @param goodsId 商品信息主键
     * @return 商品信息
     */
    @Override
    public Goods selectGoodsByGoodsId(Long goodsId)
    {
        return goodsMapper.selectGoodsByGoodsId(goodsId);
    }

    /**
     * 查询商品信息列表
     * 
     * @param goods 商品信息
     * @return 商品信息
     */
    @Override
    public List<Goods> selectGoodsList(Goods goods)
    {
        return goodsMapper.selectGoodsList(goods);
    }

    /**
     * 新增商品信息
     * 
     * @param goods 商品信息
     * @return 结果
     */
    @Override
    public int insertGoods(Goods goods)
    {
        return goodsMapper.insertGoods(goods);
    }

    /**
     * 修改商品信息
     * 
     * @param goods 商品信息
     * @return 结果
     */
    @Override
    public int updateGoods(Goods goods)
    {
        return goodsMapper.updateGoods(goods);
    }

    /**
     * 批量删除商品信息
     * 
     * @param goodsIds 需要删除的商品信息主键
     * @return 结果
     */
    @Override
    public int deleteGoodsByGoodsIds(Long[] goodsIds)
    {
        return goodsMapper.deleteGoodsByGoodsIds(goodsIds);
    }

    /**
     * 删除商品信息信息
     * 
     * @param goodsId 商品信息主键
     * @return 结果
     */
    @Override
    public int deleteGoodsByGoodsId(Long goodsId)
    {
        return goodsMapper.deleteGoodsByGoodsId(goodsId);
    }
}

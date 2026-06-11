package com.fjtcmd.hub.demo.mapper;

import java.util.List;
import com.fjtcmd.hub.demo.domain.Goods;

/**
 * 商品信息Mapper接口
 * 
 * @author lihd
 * @date 2026-06-11
 */
public interface GoodsMapper 
{
    /**
     * 查询商品信息
     * 
     * @param goodsId 商品信息主键
     * @return 商品信息
     */
    public Goods selectGoodsByGoodsId(Long goodsId);

    /**
     * 查询商品信息列表
     * 
     * @param goods 商品信息
     * @return 商品信息集合
     */
    public List<Goods> selectGoodsList(Goods goods);

    /**
     * 新增商品信息
     * 
     * @param goods 商品信息
     * @return 结果
     */
    public int insertGoods(Goods goods);

    /**
     * 修改商品信息
     * 
     * @param goods 商品信息
     * @return 结果
     */
    public int updateGoods(Goods goods);

    /**
     * 删除商品信息
     * 
     * @param goodsId 商品信息主键
     * @return 结果
     */
    public int deleteGoodsByGoodsId(Long goodsId);

    /**
     * 批量删除商品信息
     * 
     * @param goodsIds 需要删除的数据主键集合
     * @return 结果
     */
    public int deleteGoodsByGoodsIds(Long[] goodsIds);
}

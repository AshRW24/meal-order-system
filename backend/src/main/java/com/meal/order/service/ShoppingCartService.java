package com.meal.order.service;

import com.meal.order.dto.ShoppingCartDTO;
import com.meal.order.entity.ShoppingCart;

import java.util.List;

/**
 * 购物车Service接口
 */
public interface ShoppingCartService {

    /**
     * 添加商品到购物车
     * @param userId 用户ID
     * @param dto 购物车数据
     */
    void add(Long userId, ShoppingCartDTO dto);

    /**
     * 查询用户购物车列表
     * @param userId 用户ID
     * @return 购物车列表
     */
    List<ShoppingCart> list(Long userId);

    /**
     * 清空购物车
     * @param userId 用户ID
     */
    void clear(Long userId);

    /**
     * 修改购物车商品数量
     * @param userId 用户ID
     * @param cartId 购物车ID
     * @param quantity 新数量
     */
    void updateQuantity(Long userId, Long cartId, Integer quantity);

    /**
     * 删除购物车中的单个商品
     * @param userId 用户ID
     * @param cartId 购物车ID
     */
    void deleteItem(Long userId, Long cartId);
}

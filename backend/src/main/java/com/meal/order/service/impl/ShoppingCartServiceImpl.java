package com.meal.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.meal.order.dto.ShoppingCartDTO;
import com.meal.order.entity.Dish;
import com.meal.order.entity.Setmeal;
import com.meal.order.entity.ShoppingCart;
import com.meal.order.exception.BusinessException;
import com.meal.order.mapper.DishMapper;
import com.meal.order.mapper.SetmealMapper;
import com.meal.order.mapper.ShoppingCartMapper;
import com.meal.order.service.ShoppingCartService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 购物车Service实现类
 */
@Service
@RequiredArgsConstructor
public class ShoppingCartServiceImpl implements ShoppingCartService {

    private final ShoppingCartMapper shoppingCartMapper;
    private final DishMapper dishMapper;
    private final SetmealMapper setmealMapper;

    @Override
    @Transactional
    public void add(Long userId, ShoppingCartDTO dto) {
        // 1. 检查商品是否存在并读取必要信息
        String itemName;
        String image;
        java.math.BigDecimal price;

        if (dto.getItemType() == 1) {
            // 菜品
            Dish dish = dishMapper.selectById(dto.getItemId());
            if (dish == null) {
                throw new BusinessException("菜品不存在");
            }
            if (dish.getStatus() != 1) {
                throw new BusinessException("菜品已下架");
            }
            itemName = dish.getName();
            image = dish.getImage();
            price = dish.getPrice();
        } else if (dto.getItemType() == 2) {
            // 套餐
            Setmeal setmeal = setmealMapper.selectById(dto.getItemId());
            if (setmeal == null) {
                throw new BusinessException("套餐不存在");
            }
            if (setmeal.getStatus() != 1) {
                throw new BusinessException("套餐已下架");
            }
            itemName = setmeal.getName();
            image = setmeal.getImage();
            price = setmeal.getPrice();
        } else {
            throw new BusinessException("商品类型错误");
        }

        // 2. 查询购物车中是否已存在该商品（按用户+商品ID+类型唯一）
        LambdaQueryWrapper<ShoppingCart> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ShoppingCart::getUserId, userId);
        wrapper.eq(ShoppingCart::getItemId, dto.getItemId());
        wrapper.eq(ShoppingCart::getItemType, dto.getItemType());
        
        ShoppingCart existCart = shoppingCartMapper.selectOne(wrapper);

        if (existCart != null) {
            // 已存在，增加数量
            existCart.setQuantity(existCart.getQuantity() + dto.getQuantity());
            shoppingCartMapper.updateById(existCart);
        } else {
            // 不存在，新增
            ShoppingCart newCart = new ShoppingCart();
            newCart.setUserId(userId);
            newCart.setItemName(itemName);
            newCart.setPrice(price);
            newCart.setQuantity(dto.getQuantity());
            newCart.setImage(image);
            newCart.setItemId(dto.getItemId());
            newCart.setItemType(dto.getItemType());
            newCart.setCreateTime(LocalDateTime.now());
            shoppingCartMapper.insert(newCart);
        }
    }

    @Override
    public List<ShoppingCart> list(Long userId) {
        LambdaQueryWrapper<ShoppingCart> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ShoppingCart::getUserId, userId)
               .orderByDesc(ShoppingCart::getCreateTime);
        return shoppingCartMapper.selectList(wrapper);
    }

    @Override
    @Transactional
    public void clear(Long userId) {
        LambdaQueryWrapper<ShoppingCart> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ShoppingCart::getUserId, userId);
        shoppingCartMapper.delete(wrapper);
    }

    @Override
    @Transactional
    public void updateQuantity(Long userId, Long cartId, Integer quantity) {
        // 1. 查询购物车记录
        ShoppingCart cart = shoppingCartMapper.selectById(cartId);
        if (cart == null) {
            throw new BusinessException("购物车记录不存在");
        }

        // 2. 验证权限（只能修改自己的购物车）
        if (!cart.getUserId().equals(userId)) {
            throw new BusinessException("无权限操作");
        }

        // 3. 验证数量
        if (quantity < 1) {
            throw new BusinessException("数量至少为1");
        }

        // 4. 更新数量
        cart.setQuantity(quantity);
        shoppingCartMapper.updateById(cart);
    }

    @Override
    @Transactional
    public void deleteItem(Long userId, Long cartId) {
        // 1. 查询购物车记录
        ShoppingCart cart = shoppingCartMapper.selectById(cartId);
        if (cart == null) {
            throw new BusinessException("购物车记录不存在");
        }

        // 2. 验证权限（只能删除自己的购物车）
        if (!cart.getUserId().equals(userId)) {
            throw new BusinessException("无权限操作");
        }

        // 3. 删除
        shoppingCartMapper.deleteById(cartId);
    }
}

package com.meal.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.meal.order.dto.DishDTO;
import com.meal.order.entity.Dish;
import com.meal.order.exception.BusinessException;
import com.meal.order.mapper.DishMapper;
import com.meal.order.service.DishService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * 菜品Service实现类
 */
@Service
@RequiredArgsConstructor
public class DishServiceImpl implements DishService {

    private final DishMapper dishMapper;

    @Override
    public Page<Dish> page(Integer page, Integer pageSize, Long categoryId, String name, Integer status) {
        // 构建分页对象
        Page<Dish> pageInfo = new Page<>(page, pageSize);

        // 构建查询条件
        LambdaQueryWrapper<Dish> wrapper = new LambdaQueryWrapper<>();

        // 分类ID过滤
        wrapper.eq(categoryId != null, Dish::getCategoryId, categoryId);

        // 菜品名称模糊查询
        wrapper.like(StringUtils.hasText(name), Dish::getName, name);

        // 状态过滤
        wrapper.eq(status != null, Dish::getStatus, status);

        // 按创建时间降序
        wrapper.orderByDesc(Dish::getCreateTime);

        // 执行查询
        return dishMapper.selectPage(pageInfo, wrapper);
    }

    @Override
    public Dish getById(Long id) {
        Dish dish = dishMapper.selectById(id);
        if (dish == null) {
            throw new BusinessException("菜品不存在");
        }
        return dish;
    }

    @Override
    public void add(DishDTO dishDTO) {
        // 1. 检查菜品名称是否已存在（同分类下）
        LambdaQueryWrapper<Dish> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Dish::getName, dishDTO.getName())
               .eq(Dish::getCategoryId, dishDTO.getCategoryId());
        Dish existDish = dishMapper.selectOne(wrapper);

        if (existDish != null) {
            throw new BusinessException("该分类下已存在同名菜品");
        }

        // 2. 创建菜品
        Dish dish = new Dish();
        BeanUtils.copyProperties(dishDTO, dish);

        // 默认状态为在售
        if (dish.getStatus() == null) {
            dish.setStatus(1);
        }

        // 默认库存为0
        if (dish.getStock() == null) {
            dish.setStock(0);
        }

        dishMapper.insert(dish);
    }

    @Override
    public void update(DishDTO dishDTO) {
        // 1. 检查菜品是否存在
        if (dishDTO.getId() == null) {
            throw new BusinessException("菜品ID不能为空");
        }

        Dish existDish = dishMapper.selectById(dishDTO.getId());
        if (existDish == null) {
            throw new BusinessException("菜品不存在");
        }

        // 2. 检查菜品名称是否重复（排除自己，同分类下）
        LambdaQueryWrapper<Dish> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Dish::getName, dishDTO.getName())
               .eq(Dish::getCategoryId, dishDTO.getCategoryId())
               .ne(Dish::getId, dishDTO.getId());
        Dish duplicateDish = dishMapper.selectOne(wrapper);

        if (duplicateDish != null) {
            throw new BusinessException("该分类下已存在同名菜品");
        }

        // 3. 更新菜品
        Dish dish = new Dish();
        BeanUtils.copyProperties(dishDTO, dish);
        dishMapper.updateById(dish);
    }

    @Override
    public void delete(Long id) {
        // 1. 检查菜品是否存在
        Dish dish = dishMapper.selectById(id);
        if (dish == null) {
            throw new BusinessException("菜品不存在");
        }

        // 2. 删除菜品（逻辑删除，MyBatis Plus自动处理）
        dishMapper.deleteById(id);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        // 1. 检查菜品是否存在
        Dish dish = dishMapper.selectById(id);
        if (dish == null) {
            throw new BusinessException("菜品不存在");
        }

        // 2. 更新状态
        dish.setStatus(status);
        dishMapper.updateById(dish);
    }

    @Override
    public List<Dish> listAvailableDishes(Long categoryId) {
        // 构建查询条件
        LambdaQueryWrapper<Dish> wrapper = new LambdaQueryWrapper<>();

        // 只查询在售菜品（status=1）
        wrapper.eq(Dish::getStatus, 1);

        // 分类ID过滤（可选）
        wrapper.eq(categoryId != null, Dish::getCategoryId, categoryId);

        // 按排序字段和创建时间排序
        wrapper.orderByAsc(Dish::getId)
               .orderByDesc(Dish::getCreateTime);

        return dishMapper.selectList(wrapper);
    }
}

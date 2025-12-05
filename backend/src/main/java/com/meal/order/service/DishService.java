package com.meal.order.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.meal.order.dto.DishDTO;
import com.meal.order.entity.Dish;

import java.util.List;

/**
 * 菜品Service接口
 */
public interface DishService {

    /**
     * 分页查询菜品
     * @param page 当前页
     * @param pageSize 每页大小
     * @param categoryId 分类ID（可选）
     * @param name 菜品名称（模糊查询，可选）
     * @param status 状态（可选）
     * @return 分页结果
     */
    Page<Dish> page(Integer page, Integer pageSize, Long categoryId, String name, Integer status);

    /**
     * 根据ID查询菜品
     * @param id 菜品ID
     * @return 菜品信息
     */
    Dish getById(Long id);

    /**
     * 新增菜品
     * @param dishDTO 菜品信息
     */
    void add(DishDTO dishDTO);

    /**
     * 更新菜品
     * @param dishDTO 菜品信息
     */
    void update(DishDTO dishDTO);

    /**
     * 删除菜品
     * @param id 菜品ID
     */
    void delete(Long id);

    /**
     * 更新菜品状态
     * @param id 菜品ID
     * @param status 状态（1-在售，0-停售）
     */
    void updateStatus(Long id, Integer status);

    /**
     * 查询在售菜品列表（用户端）
     * @param categoryId 分类ID（可选）
     * @return 在售菜品列表
     */
    List<Dish> listAvailableDishes(Long categoryId);
}

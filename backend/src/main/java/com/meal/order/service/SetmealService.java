package com.meal.order.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.meal.order.dto.SetmealDTO;
import com.meal.order.entity.Setmeal;

import java.util.List;

/**
 * 套餐Service接口
 */
public interface SetmealService {
    /**
     * 分页查询套餐
     */
    Page<Setmeal> page(int page, int pageSize, String name, Long categoryId, Integer status);

    /**
     * 新增套餐
     */
    void add(SetmealDTO setmealDTO);

    /**
     * 修改套餐
     */
    void update(SetmealDTO setmealDTO);

    /**
     * 删除套餐
     */
    void delete(Long id);

    /**
     * 根据ID查询套餐详情（包含菜品列表）
     */
    SetmealDTO getById(Long id);

    /**
     * 修改套餐状态（上下架）
     */
    void updateStatus(Long id, Integer status);

    /**
     * 查询用户端在售套餐列表
     */
    List<Setmeal> listAvailableSetmeals(Long categoryId);
}

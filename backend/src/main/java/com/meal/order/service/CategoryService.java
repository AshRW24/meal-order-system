package com.meal.order.service;

import com.meal.order.dto.CategoryDTO;
import com.meal.order.entity.Category;

import java.util.List;

/**
 * 分类Service接口
 */
public interface CategoryService {

    /**
     * 查询所有分类
     * @param type 分类类型（可选）
     * @return 分类列表
     */
    List<Category> list(Integer type);

    /**
     * 根据ID查询分类
     * @param id 分类ID
     * @return 分类信息
     */
    Category getById(Long id);

    /**
     * 新增分类
     * @param categoryDTO 分类信息
     */
    void add(CategoryDTO categoryDTO);

    /**
     * 更新分类
     * @param categoryDTO 分类信息
     */
    void update(CategoryDTO categoryDTO);

    /**
     * 删除分类
     * @param id 分类ID
     */
    void delete(Long id);

    /**
     * 启用/禁用分类
     * @param id 分类ID
     * @param status 状态
     */
    void updateStatus(Long id, Integer status);

    /**
     * 查询启用的分类列表（用户端）
     * @param type 分类类型（可选）
     * @return 启用的分类列表
     */
    List<Category> listActiveCategories(Integer type);
}

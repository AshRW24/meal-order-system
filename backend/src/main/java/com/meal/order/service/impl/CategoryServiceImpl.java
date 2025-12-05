package com.meal.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.meal.order.dto.CategoryDTO;
import com.meal.order.entity.Category;
import com.meal.order.exception.BusinessException;
import com.meal.order.mapper.CategoryMapper;
import com.meal.order.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 分类Service实现类
 */
@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryMapper categoryMapper;

    @Override
    public List<Category> list(Integer type) {
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();

        // 如果指定了类型，则按类型查询
        if (type != null) {
            wrapper.eq(Category::getType, type);
        }

        // 按排序号升序，创建时间降序
        wrapper.orderByAsc(Category::getSort)
               .orderByDesc(Category::getCreateTime);

        return categoryMapper.selectList(wrapper);
    }

    @Override
    public Category getById(Long id) {
        Category category = categoryMapper.selectById(id);
        if (category == null) {
            throw new BusinessException("分类不存在");
        }
        return category;
    }

    @Override
    public void add(CategoryDTO categoryDTO) {
        // 1. 检查分类名称是否已存在（同类型下）
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Category::getName, categoryDTO.getName())
               .eq(Category::getType, categoryDTO.getType());
        Category existCategory = categoryMapper.selectOne(wrapper);

        if (existCategory != null) {
            String typeStr = categoryDTO.getType() == 1 ? "菜品" : "套餐";
            throw new BusinessException(typeStr + "分类名称已存在");
        }

        // 2. 创建分类
        Category category = new Category();
        BeanUtils.copyProperties(categoryDTO, category);

        // 默认状态为启用
        if (category.getStatus() == null) {
            category.setStatus(1);
        }

        // 默认排序号为0
        if (category.getSort() == null) {
            category.setSort(0);
        }

        categoryMapper.insert(category);
    }

    @Override
    public void update(CategoryDTO categoryDTO) {
        // 1. 检查分类是否存在
        if (categoryDTO.getId() == null) {
            throw new BusinessException("分类ID不能为空");
        }

        Category existCategory = categoryMapper.selectById(categoryDTO.getId());
        if (existCategory == null) {
            throw new BusinessException("分类不存在");
        }

        // 2. 检查分类名称是否重复（排除自己）
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Category::getName, categoryDTO.getName())
               .eq(Category::getType, categoryDTO.getType())
               .ne(Category::getId, categoryDTO.getId());
        Category duplicateCategory = categoryMapper.selectOne(wrapper);

        if (duplicateCategory != null) {
            String typeStr = categoryDTO.getType() == 1 ? "菜品" : "套餐";
            throw new BusinessException(typeStr + "分类名称已存在");
        }

        // 3. 更新分类
        Category category = new Category();
        BeanUtils.copyProperties(categoryDTO, category);
        categoryMapper.updateById(category);
    }

    @Override
    public void delete(Long id) {
        // 1. 检查分类是否存在
        Category category = categoryMapper.selectById(id);
        if (category == null) {
            throw new BusinessException("分类不存在");
        }

        // TODO: 检查是否有关联的菜品或套餐（后续开发）

        // 2. 删除分类
        categoryMapper.deleteById(id);
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        // 1. 检查分类是否存在
        Category category = categoryMapper.selectById(id);
        if (category == null) {
            throw new BusinessException("分类不存在");
        }

        // 2. 更新状态
        category.setStatus(status);
        categoryMapper.updateById(category);
    }

    @Override
    public List<Category> listActiveCategories(Integer type) {
        LambdaQueryWrapper<Category> wrapper = new LambdaQueryWrapper<>();

        // 只查询启用的分类（status=1）
        wrapper.eq(Category::getStatus, 1);

        // 如果指定了类型，则按类型查询
        if (type != null) {
            wrapper.eq(Category::getType, type);
        }

        // 按排序号升序，创建时间降序
        wrapper.orderByAsc(Category::getSort)
               .orderByDesc(Category::getCreateTime);

        return categoryMapper.selectList(wrapper);
    }
}

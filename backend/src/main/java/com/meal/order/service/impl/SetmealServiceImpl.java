package com.meal.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.meal.order.dto.SetmealDTO;
import com.meal.order.entity.Setmeal;
import com.meal.order.entity.SetmealDish;
import com.meal.order.mapper.SetmealDishMapper;
import com.meal.order.mapper.SetmealMapper;
import com.meal.order.service.SetmealService;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 套餐Service实现类
 */
@Service
public class SetmealServiceImpl implements SetmealService {

    @Resource
    private SetmealMapper setmealMapper;

    @Resource
    private SetmealDishMapper setmealDishMapper;

    @Override
    public Page<Setmeal> page(int page, int pageSize, String name, Long categoryId, Integer status) {
        Page<Setmeal> pageInfo = new Page<>(page, pageSize);
        LambdaQueryWrapper<Setmeal> queryWrapper = new LambdaQueryWrapper<>();

        // 按名称模糊查询
        queryWrapper.like(name != null && !name.isEmpty(), Setmeal::getName, name);

        // 按分类ID查询
        queryWrapper.eq(categoryId != null, Setmeal::getCategoryId, categoryId);

        // 按状态查询
        queryWrapper.eq(status != null, Setmeal::getStatus, status);

        // 按更新时间降序排序
        queryWrapper.orderByDesc(Setmeal::getUpdateTime);

        return setmealMapper.selectPage(pageInfo, queryWrapper);
    }

    @Override
    @Transactional
    public void add(SetmealDTO setmealDTO) {
        // 1. 插入套餐基本信息
        Setmeal setmeal = new Setmeal();
        BeanUtils.copyProperties(setmealDTO, setmeal);
        setmeal.setStatus(1); // 默认在售
        setmealMapper.insert(setmeal);

        // 2. 插入套餐菜品关联信息
        if (setmealDTO.getDishes() != null && !setmealDTO.getDishes().isEmpty()) {
            List<SetmealDish> setmealDishes = setmealDTO.getDishes().stream()
                .map(item -> {
                    SetmealDish setmealDish = new SetmealDish();
                    setmealDish.setSetmealId(setmeal.getId());
                    setmealDish.setDishId(item.getDishId());
                    setmealDish.setQuantity(item.getQuantity());
                    return setmealDish;
                })
                .collect(Collectors.toList());

            setmealDishes.forEach(setmealDishMapper::insert);
        }
    }

    @Override
    @Transactional
    public void update(SetmealDTO setmealDTO) {
        // 1. 更新套餐基本信息
        Setmeal setmeal = new Setmeal();
        BeanUtils.copyProperties(setmealDTO, setmeal);
        setmealMapper.updateById(setmeal);

        // 2. 删除原有的套餐菜品关联
        LambdaQueryWrapper<SetmealDish> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(SetmealDish::getSetmealId, setmealDTO.getId());
        setmealDishMapper.delete(deleteWrapper);

        // 3. 重新插入套餐菜品关联
        if (setmealDTO.getDishes() != null && !setmealDTO.getDishes().isEmpty()) {
            List<SetmealDish> setmealDishes = setmealDTO.getDishes().stream()
                .map(item -> {
                    SetmealDish setmealDish = new SetmealDish();
                    setmealDish.setSetmealId(setmealDTO.getId());
                    setmealDish.setDishId(item.getDishId());
                    setmealDish.setQuantity(item.getQuantity());
                    return setmealDish;
                })
                .collect(Collectors.toList());

            setmealDishes.forEach(setmealDishMapper::insert);
        }
    }

    @Override
    @Transactional
    public void delete(Long id) {
        // 1. 删除套餐（逻辑删除）
        setmealMapper.deleteById(id);

        // 2. 删除套餐菜品关联
        LambdaQueryWrapper<SetmealDish> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(SetmealDish::getSetmealId, id);
        setmealDishMapper.delete(deleteWrapper);
    }

    @Override
    public SetmealDTO getById(Long id) {
        // 1. 查询套餐基本信息
        Setmeal setmeal = setmealMapper.selectById(id);
        if (setmeal == null) {
            return null;
        }

        // 2. 查询套餐菜品关联
        LambdaQueryWrapper<SetmealDish> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(SetmealDish::getSetmealId, id);
        List<SetmealDish> setmealDishes = setmealDishMapper.selectList(queryWrapper);

        // 3. 组装DTO
        SetmealDTO setmealDTO = new SetmealDTO();
        BeanUtils.copyProperties(setmeal, setmealDTO);

        if (setmealDishes != null && !setmealDishes.isEmpty()) {
            List<SetmealDTO.SetmealDishItem> dishItems = setmealDishes.stream()
                .map(sd -> {
                    SetmealDTO.SetmealDishItem item = new SetmealDTO.SetmealDishItem();
                    item.setDishId(sd.getDishId());
                    item.setQuantity(sd.getQuantity());
                    return item;
                })
                .collect(Collectors.toList());
            setmealDTO.setDishes(dishItems);
        }

        return setmealDTO;
    }

    @Override
    public void updateStatus(Long id, Integer status) {
        Setmeal setmeal = new Setmeal();
        setmeal.setId(id);
        setmeal.setStatus(status);
        setmealMapper.updateById(setmeal);
    }
}

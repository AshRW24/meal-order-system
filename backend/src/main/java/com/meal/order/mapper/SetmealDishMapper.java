package com.meal.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.meal.order.entity.SetmealDish;
import org.apache.ibatis.annotations.Mapper;

/**
 * 套餐菜品关联Mapper接口
 */
@Mapper
public interface SetmealDishMapper extends BaseMapper<SetmealDish> {
}

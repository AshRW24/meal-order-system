package com.meal.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.meal.order.entity.Dish;
import org.apache.ibatis.annotations.Mapper;

/**
 * 菜品Mapper接口
 */
@Mapper
public interface DishMapper extends BaseMapper<Dish> {
}

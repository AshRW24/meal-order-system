package com.meal.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.meal.order.entity.OrderDetail;
import org.apache.ibatis.annotations.Mapper;

/**
 * 订单明细Mapper
 */
@Mapper
public interface OrderDetailMapper extends BaseMapper<OrderDetail> {
}

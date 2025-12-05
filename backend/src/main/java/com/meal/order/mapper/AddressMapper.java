package com.meal.order.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.meal.order.entity.Address;
import org.apache.ibatis.annotations.Mapper;

/**
 * 地址Mapper接口
 */
@Mapper
public interface AddressMapper extends BaseMapper<Address> {
}

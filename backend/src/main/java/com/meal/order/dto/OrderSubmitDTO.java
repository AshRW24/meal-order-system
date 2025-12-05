package com.meal.order.dto;

import lombok.Data;

/**
 * 订单提交DTO
 */
@Data
public class OrderSubmitDTO {

    /**
     * 地址ID
     */
    private Long addressId;

    /**
     * 备注
     */
    private String remark;
}

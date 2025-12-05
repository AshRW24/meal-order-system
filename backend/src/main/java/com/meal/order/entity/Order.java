package com.meal.order.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单实体类
 */
@Data
@TableName("orders")
public class Order {

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 订单号
     */
    private String orderNumber;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 地址ID
     */
    private Long addressId;

    /**
     * 订单金额
     */
    private BigDecimal amount;

    /**
     * 订单状态（1-待确认，2-已确认，3-配送中，4-已完成，5-已取消）
     */
    private Integer status;

    /**
     * 支付状态（0-未支付，1-已支付）
     */
    private Integer payStatus;

    /**
     * 备注
     */
    private String remark;

    /**
     * 收货人
     */
    private String consignee;

    /**
     * 联系电话
     */
    private String phone;

    /**
     * 收货地址
     */
    private String address;

    /**
     * 下单时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime orderTime;

    /**
     * 支付时间
     */
    private LocalDateTime payTime;

    /**
     * 完成时间
     */
    private LocalDateTime completeTime;
}

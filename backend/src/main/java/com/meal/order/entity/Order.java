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
    @TableField("order_number")
    private String orderNumber;

    /**
     * 用户ID
     */
    @TableField("user_id")
    private Long userId;

    /**
     * 地址ID
     */
    @TableField("address_id")
    private Long addressId;

    /**
     * 订单金额
     */
    @TableField("amount")
    private BigDecimal amount;

    /**
     * 订单状态（1-待确认，2-已确认，3-配送中，4-已完成，5-已取消）
     */
    @TableField("status")
    private Integer status;

    /**
     * 支付状态（0-未支付，1-已支付）
     */
    @TableField("pay_status")
    private Integer payStatus;

    /**
     * 备注
     */
    @TableField("remark")
    private String remark;

    /**
     * 收货人
     */
    @TableField("consignee")
    private String consignee;

    /**
     * 联系电话
     */
    @TableField("phone")
    private String phone;

    /**
     * 收货地址
     */
    @TableField("address")
    private String address;

    /**
     * 下单时间
     */
    @TableField(value = "order_time", fill = FieldFill.INSERT)
    private LocalDateTime orderTime;

    /**
     * 支付时间
     */
    @TableField("pay_time")
    private LocalDateTime payTime;

    /**
     * 完成时间
     */
    @TableField("complete_time")
    private LocalDateTime completeTime;
}

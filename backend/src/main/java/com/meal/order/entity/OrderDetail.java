package com.meal.order.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 订单明细实体类
 */
@Data
@TableName("order_detail")
public class OrderDetail {

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 订单ID
     */
    @TableField("order_id")
    private Long orderId;

    /**
     * 商品ID
     */
    @TableField("dish_id")
    private Long dishId;

    /**
     * 商品套餐ID
     */
    @TableField("setmeal_id")
    private Long setmealId;

    /**
     * 商品名称
     */
    @TableField("dish_name")
    private String dishName;

    /**
     * 单价
     */
    @TableField("price")
    private BigDecimal price;

    /**
     * 数量
     */
    @TableField("quantity")
    private Integer quantity;

    /**
     * 小计
     */
    @TableField("amount")
    private BigDecimal amount;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

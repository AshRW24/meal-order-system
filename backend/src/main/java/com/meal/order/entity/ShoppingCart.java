package com.meal.order.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 购物车实体类
 */
@Data
@TableName("shopping_cart")
public class ShoppingCart {

    /** 主键ID */
    @TableId(type = IdType.AUTO)
    private Long id;

    /** 用户ID */
    @TableField("user_id")
    private Long userId;

    /** 商品类型：1-菜品，2-套餐 */
    @TableField("item_type")
    private Integer itemType;

    /** 商品ID（菜品或套餐ID） */
    @TableField("item_id")
    private Long itemId;

    /** 商品名称 */
    @TableField("item_name")
    private String itemName;

    /** 商品图片 */
    @TableField("image")
    private String image;

    /** 单价 */
    @TableField("price")
    private BigDecimal price;

    /** 数量 */
    @TableField("quantity")
    private Integer quantity;

    /** 创建时间 */
    @TableField("create_time")
    private LocalDateTime createTime;
}

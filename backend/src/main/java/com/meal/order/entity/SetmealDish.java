package com.meal.order.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 套餐菜品关联实体类
 */
@Data
@TableName("setmeal_dish")
public class SetmealDish {
    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 套餐ID
     */
    private Long setmealId;

    /**
     * 菜品ID
     */
    private Long dishId;

    /**
     * 菜品数量
     */
    private Integer quantity;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
}

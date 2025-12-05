package com.meal.order.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 菜品实体类
 */
@Data
@TableName("dish")
public class Dish {

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 分类ID
     */
    private Long categoryId;

    /**
     * 菜品名称
     */
    private String name;

    /**
     * 价格
     */
    private BigDecimal price;

    /**
     * 图片URL
     */
    private String image;

    /**
     * 描述
     */
    private String description;

    /**
     * 库存数量
     */
    private Integer stock;

    /**
     * 状态（1-在售，0-停售）
     */
    private Integer status;

    /**
     * 是否删除（1-已删除，0-未删除）
     */
    @TableLogic
    private Integer isDeleted;

    /**
     * 创建时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    /**
     * 更新时间
     */
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}

package com.meal.order.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 套餐实体类
 */
@Data
@TableName("setmeal")
public class Setmeal {
    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 分类ID
     */
    @TableField("category_id")
    private Long categoryId;

    /**
     * 套餐名称
     */
    @TableField("name")
    private String name;

    /**
     * 价格
     */
    @TableField("price")
    private BigDecimal price;

    /**
     * 图片URL
     */
    @TableField("image")
    private String image;

    /**
     * 描述
     */
    @TableField("description")
    private String description;

    /**
     * 状态（1-在售，0-停售）
     */
    @TableField("status")
    private Integer status;

    /**
     * 是否删除（1-已删除，0-未删除）
     */
    @TableField("is_deleted")
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

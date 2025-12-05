package com.meal.order.dto;

import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

/**
 * 套餐DTO（用于新增和编辑）
 */
@Data
public class SetmealDTO {
    /**
     * 套餐ID（编辑时需要）
     */
    private Long id;

    /**
     * 分类ID
     */
    @NotNull(message = "分类不能为空")
    private Long categoryId;

    /**
     * 套餐名称
     */
    @NotBlank(message = "套餐名称不能为空")
    private String name;

    /**
     * 价格
     */
    @NotNull(message = "价格不能为空")
    @Min(value = 0, message = "价格必须大于等于0")
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
     * 状态（1-在售，0-停售）
     */
    private Integer status;

    /**
     * 套餐包含的菜品列表
     */
    private List<SetmealDishItem> dishes;

    /**
     * 套餐菜品项
     */
    @Data
    public static class SetmealDishItem {
        /**
         * 菜品ID
         */
        @NotNull(message = "菜品不能为空")
        private Long dishId;

        /**
         * 菜品数量
         */
        @NotNull(message = "数量不能为空")
        @Min(value = 1, message = "数量必须大于0")
        private Integer quantity;
    }
}

package com.meal.order.dto;

import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 购物车DTO
 */
@Data
public class ShoppingCartDTO {

    /**
     * 商品ID（菜品或套餐）
     */
    @NotNull(message = "商品ID不能为空")
    private Long itemId;

    /**
     * 商品类型（1-菜品，2-套餐）
     */
    @NotNull(message = "商品类型不能为空")
    private Integer itemType;

    /**
     * 数量
     */
    @NotNull(message = "数量不能为空")
    @Min(value = 1, message = "数量至少为1")
    private Integer quantity;
}

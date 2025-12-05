package com.meal.order.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;

/**
 * 菜品DTO
 */
@Data
@ApiModel("菜品数据传输对象")
public class DishDTO {

    @ApiModelProperty("菜品ID（更新时需要）")
    private Long id;

    @NotNull(message = "分类ID不能为空")
    @ApiModelProperty(value = "分类ID", required = true)
    private Long categoryId;

    @NotBlank(message = "菜品名称不能为空")
    @ApiModelProperty(value = "菜品名称", required = true)
    private String name;

    @NotNull(message = "价格不能为空")
    @Min(value = 0, message = "价格不能小于0")
    @ApiModelProperty(value = "价格", required = true)
    private BigDecimal price;

    @ApiModelProperty("图片URL")
    private String image;

    @ApiModelProperty("描述")
    private String description;

    @NotNull(message = "库存不能为空")
    @Min(value = 0, message = "库存不能小于0")
    @ApiModelProperty(value = "库存数量", required = true)
    private Integer stock;

    @ApiModelProperty("状态（1-在售，0-停售）")
    private Integer status;
}

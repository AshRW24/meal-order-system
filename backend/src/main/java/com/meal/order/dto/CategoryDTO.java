package com.meal.order.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;

import javax.validation.constraints.Min;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;

/**
 * 分类DTO
 */
@Data
@ApiModel("分类数据传输对象")
public class CategoryDTO {

    @ApiModelProperty("分类ID（更新时需要）")
    private Long id;

    @NotBlank(message = "分类名称不能为空")
    @ApiModelProperty(value = "分类名称", required = true)
    private String name;

    @NotNull(message = "分类类型不能为空")
    @ApiModelProperty(value = "类型（1-菜品分类，2-套餐分类）", required = true)
    private Integer type;

    @Min(value = 0, message = "排序号不能小于0")
    @ApiModelProperty(value = "排序号", required = true)
    private Integer sort;

    @ApiModelProperty("状态（1-启用，0-禁用）")
    private Integer status;
}

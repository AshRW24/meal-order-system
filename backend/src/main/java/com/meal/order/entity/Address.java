package com.meal.order.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * 地址实体类
 */
@Data
@TableName("address")
public class Address {

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    @TableField("user_id")
    private Long userId;

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
     * 省份编码
     */
    @TableField("province_code")
    private String provinceCode;

    /**
     * 省份名称
     */
    @TableField("province_name")
    private String provinceName;

    /**
     * 城市编码
     */
    @TableField("city_code")
    private String cityCode;

    /**
     * 城市名称
     */
    @TableField("city_name")
    private String cityName;

    /**
     * 区县编码
     */
    @TableField("district_code")
    private String districtCode;

    /**
     * 区县名称
     */
    @TableField("district_name")
    private String districtName;

    /**
     * 详细地址
     */
    @TableField("detail")
    private String detail;

    /**
     * 地址标签（家/公司/学校）
     */
    @TableField("tag")
    private String tag;

    /**
     * 是否默认（1-是，0-否）
     */
    @TableField("is_default")
    private Integer isDefault;

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

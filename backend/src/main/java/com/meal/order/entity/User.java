package com.meal.order.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户实体类
 */
@Data
@TableName("user")
public class User {

    /**
     * 主键ID
     */
    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户名
     */
    @TableField("username")
    private String username;

    /**
     * 密码（明文-MVP版本）
     */
    @TableField("password")
    private String password;

    /**
     * 密保问题
     */
    @TableField("security_question")
    private String securityQuestion;

    /**
     * 密保答案
     */
    @TableField("security_answer")
    private String securityAnswer;

    /**
     * 手机号
     */
    @TableField("phone")
    private String phone;

    /**
     * 邮箱
     */
    @TableField("email")
    private String email;

    /**
     * 头像URL
     */
    @TableField("avatar")
    private String avatar;

    /**
     * 账户余额
     */
    @TableField("balance")
    private BigDecimal balance;

    /**
     * 状态（1-正常，0-禁用）
     */
    @TableField("status")
    private Integer status;

    /**
     * 用户类型（1-普通用户，2-管理员）
     */
    @TableField("user_type")
    private Integer userType;

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

package com.meal.order.dto;

import lombok.Data;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;

/**
 * 注册DTO
 */
@Data
public class RegisterDTO {

    /**
     * 用户名
     */
    @NotBlank(message = "用户名不能为空")
    @Size(min = 3, max = 20, message = "用户名长度为3-20位")
    private String username;

    /**
     * 密码
     */
    @NotBlank(message = "密码不能为空")
    @Size(min = 6, max = 20, message = "密码长度为6-20位")
    private String password;

    /**
     * 确认密码
     */
    @NotBlank(message = "确认密码不能为空")
    private String confirmPassword;

    /**
     * 密保问题
     */
    @NotBlank(message = "密保问题不能为空")
    private String securityQuestion;

    /**
     * 密保答案
     */
    @NotBlank(message = "密保答案不能为空")
    @Size(min = 1, max = 50, message = "密保答案长度为1-50位")
    private String securityAnswer;

    /**
     * 手机号（可选）
     */
    private String phone;
}

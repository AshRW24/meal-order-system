package com.meal.order.service;

import com.meal.order.dto.LoginDTO;
import com.meal.order.dto.RegisterDTO;
import com.meal.order.dto.ResetPasswordDTO;
import com.meal.order.entity.User;

import java.math.BigDecimal;

/**
 * 用户Service接口
 */
public interface UserService {

    /**
     * 用户注册
     *
     * @param registerDTO 注册信息
     * @param userType    用户类型（1-普通用户，2-管理员）
     */
    void register(RegisterDTO registerDTO, Integer userType);

    /**
     * 用户登录
     *
     * @param loginDTO 登录信息
     * @param userType 用户类型（1-普通用户，2-管理员）
     * @return 用户信息
     */
    User login(LoginDTO loginDTO, Integer userType);

    /**
     * 重置密码
     *
     * @param resetPasswordDTO 重置密码信息
     * @param userType         用户类型（1-普通用户，2-管理员）
     */
    void resetPassword(ResetPasswordDTO resetPasswordDTO, Integer userType);

    /**
     * 根据用户名和用户类型查询用户
     *
     * @param username 用户名
     * @param userType 用户类型
     * @return 用户信息
     */
    User getByUsernameAndType(String username, Integer userType);

    /**
     * 用户充值
     *
     * @param userId 用户ID
     * @param amount 充值金额
     * @return 充值后的余额
     */
    BigDecimal recharge(Long userId, BigDecimal amount);

    /**
     * 扣减余额（支付订单）
     *
     * @param userId 用户ID
     * @param amount 扣减金额
     */
    void deductBalance(Long userId, BigDecimal amount);

    /**
     * 查询用户余额
     *
     * @param userId 用户ID
     * @return 余额
     */
    BigDecimal getBalance(Long userId);
}

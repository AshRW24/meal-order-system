package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.dto.LoginDTO;
import com.meal.order.dto.RechargeDTO;
import com.meal.order.dto.RegisterDTO;
import com.meal.order.dto.ResetPasswordDTO;
import com.meal.order.entity.User;
import com.meal.order.service.UserService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * 用户端Controller
 */
@Slf4j
@RestController
@RequestMapping("/user")
@RequiredArgsConstructor
@Api(tags = "用户端接口")
public class UserController {

    private final UserService userService;

    /**
     * 用户注册
     */
    @PostMapping("/register")
    @ApiOperation("用户注册")
    public Result<String> register(@Validated @RequestBody RegisterDTO registerDTO) {
        log.info("用户注册：{}", registerDTO.getUsername());
        userService.register(registerDTO, 1); // userType=1 表示普通用户
        return Result.success("注册成功");
    }

    /**
     * 用户登录
     */
    @PostMapping("/login")
    @ApiOperation("用户登录")
    public Result<Map<String, Object>> login(@Validated @RequestBody LoginDTO loginDTO,
                                               HttpSession session) {
        log.info("用户登录：{}", loginDTO.getUsername());

        User user = userService.login(loginDTO, 1); // userType=1 表示普通用户

        // 保存到Session
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getId());
        session.setAttribute("userType", user.getUserType());

        // 返回用户信息（隐藏密码）
        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("phone", user.getPhone());
        data.put("email", user.getEmail());
        data.put("avatar", user.getAvatar());
        data.put("balance", user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO);

        return Result.success(data);
    }

    /**
     * 找回密码 - 第一步：获取密保问题
     */
    @GetMapping("/security-question")
    @ApiOperation("获取密保问题")
    public Result<String> getSecurityQuestion(@RequestParam String username) {
        log.info("获取密保问题：{}", username);

        User user = userService.getByUsernameAndType(username, 1);
        if (user == null) {
            return Result.error("用户不存在");
        }

        if (user.getSecurityQuestion() == null) {
            return Result.error("该用户未设置密保问题");
        }

        return Result.success(user.getSecurityQuestion());
    }

    /**
     * 找回密码 - 第二步：重置密码
     */
    @PostMapping("/reset-password")
    @ApiOperation("重置密码")
    public Result<String> resetPassword(@Validated @RequestBody ResetPasswordDTO resetPasswordDTO) {
        log.info("重置密码：{}", resetPasswordDTO.getUsername());
        userService.resetPassword(resetPasswordDTO, 1); // userType=1 表示普通用户
        return Result.success("密码重置成功");
    }

    /**
     * 用户充值
     */
    @PostMapping("/recharge")
    @ApiOperation("用户充值")
    public Result<Map<String, Object>> recharge(@Validated @RequestBody RechargeDTO rechargeDTO,
                                                 HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return Result.error("请先登录");
        }

        log.info("用户充值，用户ID：{}，充值金额：{}", userId, rechargeDTO.getAmount());

        BigDecimal newBalance = userService.recharge(userId, rechargeDTO.getAmount());

        Map<String, Object> data = new HashMap<>();
        data.put("balance", newBalance);
        data.put("rechargeAmount", rechargeDTO.getAmount());

        return Result.success(data);
    }

    /**
     * 查询用户余额
     */
    @GetMapping("/balance")
    @ApiOperation("查询用户余额")
    public Result<Map<String, Object>> getBalance(HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return Result.error("请先登录");
        }

        BigDecimal balance = userService.getBalance(userId);

        Map<String, Object> data = new HashMap<>();
        data.put("balance", balance);

        return Result.success(data);
    }

    /**
     * 登出
     */
    @PostMapping("/logout")
    @ApiOperation("登出")
    public Result<String> logout(HttpSession session) {
        log.info("用户登出");
        session.invalidate();
        return Result.success("登出成功");
    }
}

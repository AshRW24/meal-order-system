package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.dto.LoginDTO;
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
import java.util.HashMap;
import java.util.Map;

/**
 * 管理端Controller
 */
@Slf4j
@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@Api(tags = "管理端接口")
public class AdminController {

    private final UserService userService;

    /**
     * 管理员注册
     */
    @PostMapping("/register")
    @ApiOperation("管理员注册")
    public Result<String> register(@Validated @RequestBody RegisterDTO registerDTO) {
        log.info("管理员注册：{}", registerDTO.getUsername());
        userService.register(registerDTO, 2);
        return Result.success("注册成功");
    }

    /**
     * 管理员登录
     */
    @PostMapping("/login")
    @ApiOperation("管理员登录")
    public Result<Map<String, Object>> login(@Validated @RequestBody LoginDTO loginDTO,
                                               HttpSession session) {
        log.info("管理员登录：{}", loginDTO.getUsername());

        User user = userService.login(loginDTO, 2); // userType=2 表示管理员

        // 保存到Session
        session.setAttribute("admin", user);
        session.setAttribute("adminId", user.getId());
        session.setAttribute("userType", user.getUserType());

        // 返回用户信息（隐藏密码）
        Map<String, Object> data = new HashMap<>();
        data.put("id", user.getId());
        data.put("username", user.getUsername());
        data.put("phone", user.getPhone());
        data.put("email", user.getEmail());
        data.put("avatar", user.getAvatar());

        return Result.success(data);
    }

    /**
     * 找回密码 - 第一步：获取密保问题
     */
    @GetMapping("/security-question")
    @ApiOperation("获取密保问题")
    public Result<String> getSecurityQuestion(@RequestParam String username) {
        log.info("获取密保问题：{}", username);

        User user = userService.getByUsernameAndType(username, 2);
        if (user == null) {
            return Result.error("管理员不存在");
        }

        if (user.getSecurityQuestion() == null) {
            return Result.error("该管理员未设置密保问题");
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
        userService.resetPassword(resetPasswordDTO, 2);
        return Result.success("密码重置成功");
    }

    /**
     * 登出
     */
    @PostMapping("/logout")
    @ApiOperation("登出")
    public Result<String> logout(HttpSession session) {
        log.info("管理员登出");
        session.invalidate();
        return Result.success("登出成功");
    }
}

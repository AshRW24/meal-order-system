package com.meal.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.meal.order.common.JwtUtil;
import com.meal.order.common.PasswordUtil;
import com.meal.order.dto.LoginDTO;
import com.meal.order.dto.RegisterDTO;
import com.meal.order.dto.ResetPasswordDTO;
import com.meal.order.entity.User;
import com.meal.order.exception.BusinessException;
import com.meal.order.mapper.UserMapper;
import com.meal.order.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

/**
 * 用户Service实现类
 */
@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final JwtUtil jwtUtil;

    @Override
    public void register(RegisterDTO registerDTO, Integer userType) {
        // 1. 校验两次密码是否一致
        if (!registerDTO.getPassword().equals(registerDTO.getConfirmPassword())) {
            throw new BusinessException("两次密码输入不一致");
        }

        // 2. 检查用户名是否已存在（同类型用户）
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, registerDTO.getUsername())
                .eq(User::getUserType, userType);
        User existUser = userMapper.selectOne(wrapper);
        if (existUser != null) {
            String userTypeStr = userType == 2 ? "管理员" : "用户";
            throw new BusinessException(userTypeStr + "账号已存在");
        }

        // 3. 创建用户
        User user = new User();
        user.setUsername(registerDTO.getUsername());
        // 使用PasswordUtil进行密码加密
        user.setPassword(PasswordUtil.encode(registerDTO.getPassword(), registerDTO.getUsername()));
        user.setSecurityQuestion(registerDTO.getSecurityQuestion());
        user.setSecurityAnswer(registerDTO.getSecurityAnswer());

        // 处理空字符串，避免唯一约束冲突
        String phone = registerDTO.getPhone();
        user.setPhone((phone == null || phone.trim().isEmpty()) ? null : phone);

        user.setUserType(userType);
        user.setStatus(1); // 默认启用
        user.setBalance(BigDecimal.ZERO); // 初始余额为0

        userMapper.insert(user);
    }

    @Override
    public User login(LoginDTO loginDTO, Integer userType) {
        // 1. 查询用户
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, loginDTO.getUsername())
                .eq(User::getUserType, userType);
        User user = userMapper.selectOne(wrapper);

        // 2. 校验用户是否存在
        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }

        // 3. 校验密码（使用PasswordUtil进行验证）
        if (!PasswordUtil.verify(loginDTO.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }

        // 4. 校验用户状态
        if (user.getStatus() == 0) {
            throw new BusinessException("账号已被禁用，请联系管理员");
        }

        // 5. 生成JWT Token并存储到user对象中
        String token = jwtUtil.generateToken(user.getId(), user.getUsername());
        user.setPassword(token); // 临时存储token到password字段以便返回给前端

        return user;
    }

    @Override
    public void resetPassword(ResetPasswordDTO resetPasswordDTO, Integer userType) {
        // 1. 校验两次密码是否一致
        if (!resetPasswordDTO.getNewPassword().equals(resetPasswordDTO.getConfirmPassword())) {
            throw new BusinessException("两次密码输入不一致");
        }

        // 2. 查询用户
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, resetPasswordDTO.getUsername())
                .eq(User::getUserType, userType);
        User user = userMapper.selectOne(wrapper);

        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 3. 校验密保答案
        if (!user.getSecurityAnswer().equals(resetPasswordDTO.getSecurityAnswer())) {
            throw new BusinessException("密保答案错误");
        }

        // 4. 更新密码（使用PasswordUtil进行加密）
        user.setPassword(PasswordUtil.encode(resetPasswordDTO.getNewPassword(), user.getUsername()));
        userMapper.updateById(user);
    }

    @Override
    public User getByUsernameAndType(String username, Integer userType) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getUsername, username)
                .eq(User::getUserType, userType);
        return userMapper.selectOne(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public BigDecimal recharge(Long userId, BigDecimal amount) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        BigDecimal currentBalance = user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO;
        BigDecimal newBalance = currentBalance.add(amount);
        user.setBalance(newBalance);
        userMapper.updateById(user);

        return newBalance;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deductBalance(Long userId, BigDecimal amount) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        BigDecimal currentBalance = user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO;
        if (currentBalance.compareTo(amount) < 0) {
            throw new BusinessException("账户余额不足，请先充值");
        }

        BigDecimal newBalance = currentBalance.subtract(amount);
        user.setBalance(newBalance);
        userMapper.updateById(user);
    }

    @Override
    public BigDecimal getBalance(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BusinessException("用户不存在");
        }
        return user.getBalance() != null ? user.getBalance() : BigDecimal.ZERO;
    }
}

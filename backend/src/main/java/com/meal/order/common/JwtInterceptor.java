package com.meal.order.common;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * JWT拦截器
 * 用于验证Token的有效性
 */
@Slf4j
@Component
public class JwtInterceptor implements HandlerInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    /**
     * 请求前置处理
     * 验证Token有效性
     */
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 处理OPTIONS请求
        if ("OPTIONS".equals(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return true;
        }

        // 从请求头中获取Authorization
        String authorizationHeader = request.getHeader("Authorization");

        // 如果没有Authorization header，则允许通过（某些接口可能不需要认证）
        if (authorizationHeader == null || authorizationHeader.isEmpty()) {
            log.debug("请求没有Authorization header: {}", request.getRequestURI());
            return true;
        }

        // 从header中提取Token
        String token = jwtUtil.extractTokenFromHeader(authorizationHeader);

        // 验证Token
        if (token != null && jwtUtil.validateToken(token)) {
            // Token有效，将用户信息存储到request中，方便后续使用
            Long userId = jwtUtil.getUserIdFromToken(token);
            String username = jwtUtil.getUsernameFromToken(token);

            request.setAttribute("userId", userId);
            request.setAttribute("username", username);

            log.debug("Token验证成功，userId: {}, username: {}", userId, username);
            return true;
        } else {
            // Token无效或过期
            log.warn("Token验证失败，authorizationHeader: {}", authorizationHeader);
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"message\":\"Token验证失败或已过期\"}");
            return false;
        }
    }
}

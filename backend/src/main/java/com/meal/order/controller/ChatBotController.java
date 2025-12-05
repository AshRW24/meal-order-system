package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.dto.ChatMessageDTO;
import com.meal.order.service.ChatBotService;
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
 * ChatBot AI 客服控制器
 * 提供AI智能客服功能
 */
@Slf4j
@RestController
@RequestMapping("/chatbot")
@RequiredArgsConstructor
@Api(tags = "AI客服接口")
public class ChatBotController {

    private final ChatBotService chatBotService;

    /**
     * 发送消息到AI客服
     *
     * @param chatMessageDTO 消息内容
     * @param session HTTP会话（用于获取用户ID）
     * @return AI回复
     */
    @PostMapping("/message")
    @ApiOperation("发送消息到AI客服")
    public Result<Map<String, Object>> sendMessage(
            @Validated @RequestBody ChatMessageDTO chatMessageDTO,
            HttpSession session) {

        try {
            Long userId = (Long) session.getAttribute("userId");
            String username = (String) session.getAttribute("username");
            Integer userType = (Integer) session.getAttribute("userType");

            // 权限验证：只有普通用户(userType=1)才能使用chatbot，管理员(userType=2)不允许
            if (userType == null || userType != 1) {
                log.warn("非法的AI客服访问尝试 - 用户: {}, 类型: {}", username, userType);
                return Result.error("仅普通用户可以使用AI客服功能");
            }

            if (userId == null) {
                return Result.error("请先登录");
            }

            log.info("用户 {} 发送消息到AI客服: {}", username, chatMessageDTO.getMessage());

            // 调用ChatBot服务获取AI回复
            String aiResponse = chatBotService.chat(chatMessageDTO.getMessage());

            // 构建返回数据
            Map<String, Object> data = new HashMap<>();
            data.put("message", aiResponse);
            data.put("timestamp", System.currentTimeMillis());
            data.put("userId", userId);
            data.put("username", username);

            return Result.success(data);

        } catch (Exception e) {
            log.error("调用AI客服失败: {}", e.getMessage(), e);
            return Result.error("客服回复失败，请稍后重试");
        }
    }

    /**
     * 检查AI客服是否可用
     *
     * @return 可用状态
     */
    @GetMapping("/status")
    @ApiOperation("检查AI客服状态")
    public Result<Map<String, Object>> checkStatus() {
        try {
            boolean available = chatBotService.isApiAvailable();

            Map<String, Object> data = new HashMap<>();
            data.put("available", available);
            data.put("timestamp", System.currentTimeMillis());

            return Result.success(data);

        } catch (Exception e) {
            log.error("检查AI客服状态失败: {}", e.getMessage());
            return Result.error("检查状态失败");
        }
    }

    /**
     * 获取AI客服欢迎语
     *
     * @return 欢迎语信息
     */
    @GetMapping("/welcome")
    @ApiOperation("获取AI客服欢迎语")
    public Result<Map<String, Object>> getWelcomeMessage() {
        Map<String, Object> data = new HashMap<>();
        data.put("message", "您好！👋 我是AI客服助手，很高兴为您服务。\n\n" +
                "我可以帮您解答关于以下问题：\n" +
                "🍽️ 菜品信息\n" +
                "📦 订单查询\n" +
                "🚗 配送进度\n" +
                "📍 地址管理\n" +
                "💰 价格与优惠\n\n" +
                "请随时告诉我您的问题！");
        data.put("timestamp", System.currentTimeMillis());

        return Result.success(data);
    }
}

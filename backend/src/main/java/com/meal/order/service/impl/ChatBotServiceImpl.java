package com.meal.order.service.impl;

import com.meal.order.service.ChatBotService;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.stereotype.Service;

import java.io.IOException;

/**
 * ChatBot AI 客服服务实现
 * 集成 DeepSeek API
 */
@Slf4j
@Service
public class ChatBotServiceImpl implements ChatBotService {

    // API Key 硬编码 - 直接可用，无需环境变量配置
    private static final String apiKey = "sk-b4014770ac644c349bf25eb7b35b3836";
    private static final String apiUrl = "https://api.deepseek.com/v1/chat/completions";
    private static final String model = "deepseek-chat";
    private static final long timeout = 30;

    private static final OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .readTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .writeTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
            .build();

    private static final String SYSTEM_PROMPT = "你是一个外卖订餐系统的AI客服助手。\n" +
            "你的职责是：\n" +
            "1. 友善、礼貌地回答用户关于订餐系统的问题\n" +
            "2. 帮助用户了解菜品、订单、配送等信息\n" +
            "3. 解决用户的常见问题\n" +
            "4. 如果用户问的不是关于订餐的问题，也要友善地引导\n" +
            "\n" +
            "请用简洁、亲切的语言回复用户。";

    @Override
    public String chat(String message) throws Exception {
        if (!isApiAvailable()) {
            log.warn("DeepSeek API 不可用，返回降级回复");
            return getDefaultResponse(message);
        }

        try {
            String response = callDeepSeekAPI(message);
            log.info("DeepSeek API 调用成功");
            return response;
        } catch (Exception e) {
            log.error("调用 DeepSeek API 失败: {}", e.getMessage());
            return getDefaultResponse(message);
        }
    }

    /**
     * 调用 DeepSeek API
     */
    private String callDeepSeekAPI(String message) throws Exception {
        // 构建请求体
        String requestBody = buildRequestBody(message);

        // 创建请求
        Request request = new Request.Builder()
                .url(apiUrl)
                .addHeader("Authorization", "Bearer " + apiKey)
                .addHeader("Content-Type", "application/json")
                .post(RequestBody.create(
                        requestBody,
                        MediaType.parse("application/json")
                ))
                .build();

        // 执行请求
        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new IOException("API返回错误，状态码: " + response.code());
            }

            String responseBody = response.body().string();
            return parseResponse(responseBody);
        }
    }

    /**
     * 构建请求体
     */
    private String buildRequestBody(String message) {
        return String.format(
                "{\"model\":\"%s\"," +
                        "\"messages\":[" +
                        "{\"role\":\"system\",\"content\":\"%s\"}," +
                        "{\"role\":\"user\",\"content\":\"%s\"}" +
                        "]," +
                        "\"temperature\":0.7," +
                        "\"max_tokens\":500}",
                model,
                escapeJson(SYSTEM_PROMPT),
                escapeJson(message)
        );
    }

    /**
     * 解析 API 响应
     */
    private String parseResponse(String responseBody) throws Exception {
        try {
            // 简单的JSON解析（可使用更好的JSON库如Jackson）
            int startIndex = responseBody.indexOf("\"content\":\"");
            if (startIndex == -1) {
                throw new Exception("无法从响应中解析内容");
            }

            startIndex += "\"content\":\"".length();
            int endIndex = responseBody.indexOf("\"", startIndex);

            if (endIndex == -1) {
                throw new Exception("无法从响应中解析内容");
            }

            String content = responseBody.substring(startIndex, endIndex);
            // 反转义JSON字符串
            content = unescapeJson(content);

            return content;
        } catch (Exception e) {
            log.error("解析API响应失败: {}", e.getMessage());
            throw e;
        }
    }

    /**
     * JSON转义字符串
     */
    private String escapeJson(String input) {
        if (input == null) return "";
        return input
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    /**
     * JSON反转义字符串
     */
    private String unescapeJson(String input) {
        if (input == null) return "";
        return input
                .replace("\\n", "\n")
                .replace("\\r", "\r")
                .replace("\\t", "\t")
                .replace("\\\"", "\"")
                .replace("\\\\", "\\");
    }

    @Override
    public boolean isApiAvailable() {
        // 检查API密钥是否配置
        return apiKey != null && !apiKey.isEmpty() && !apiKey.equals("your-api-key");
    }

    /**
     * 降级回复（API不可用时）
     */
    private String getDefaultResponse(String message) {
        log.info("使用默认回复");

        // 简单的关键词匹配回复
        String lowerMessage = message.toLowerCase();

        if (lowerMessage.contains("菜") || lowerMessage.contains("menu") || lowerMessage.contains("dish")) {
            return "亲，我们平台上有丰富的菜品选择，包括各种口味的美食。您可以在菜单页面浏览所有菜品，点击菜品可以查看详细信息和评价。如有具体想了解的菜品，欢迎继续提问！😊";
        }

        if (lowerMessage.contains("订单") || lowerMessage.contains("order")) {
            return "关于订单的问题，您可以在订单页面查看订单状态、配送进度等信息。如果遇到问题，欢迎告诉我具体情况！";
        }

        if (lowerMessage.contains("配送") || lowerMessage.contains("delivery")) {
            return "我们通常在30分钟-1小时内送达。具体配送时间会根据您的位置和订单量有所调整。您可以在订单详情中实时查看配送进度！";
        }

        if (lowerMessage.contains("地址") || lowerMessage.contains("address")) {
            return "地址管理功能在个人中心可以找到，您可以添加、修改和删除地址，也可以设置默认地址以便下次快速下单。";
        }

        if (lowerMessage.contains("价格") || lowerMessage.contains("price") || lowerMessage.contains("钱")) {
            return "菜品价格在菜单中都有显示，我们定期会有优惠活动，敬请关注！";
        }

        if (lowerMessage.contains("谢谢") || lowerMessage.contains("谢") || lowerMessage.contains("thanks")) {
            return "不客气，很高兴为您服务！如有其他问题随时咨询我。😊";
        }

        if (lowerMessage.contains("你好") || lowerMessage.contains("hello") || lowerMessage.contains("hi")) {
            return "您好！欢迎使用我们的订餐系统！有什么可以帮助您的吗？";
        }

        // 默认回复
        return "感谢您的咨询！我是AI客服助手，可以帮您解答关于菜品、订单、配送等问题。" +
                "如果您需要人工客服支持，请联系我们的客服团队。";
    }
}

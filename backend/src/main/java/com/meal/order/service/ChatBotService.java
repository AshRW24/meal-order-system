package com.meal.order.service;

/**
 * ChatBot AI 客服服务接口
 */
public interface ChatBotService {

    /**
     * 与AI客服进行对话
     *
     * @param message 用户消息
     * @return AI回复
     */
    String chat(String message) throws Exception;

    /**
     * 检查 API 是否可用
     *
     * @return 是否可用
     */
    boolean isApiAvailable();
}

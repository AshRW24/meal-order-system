package com.meal.order.dto;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.NotBlank;

/**
 * ChatBot 消息DTO
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@ApiModel(description = "ChatBot消息请求")
public class ChatMessageDTO {

    @NotBlank(message = "消息内容不能为空")
    @ApiModelProperty(value = "用户消息内容", example = "你好，我想了解一下菜单")
    private String message;

    @ApiModelProperty(value = "对话ID（可选，用于多轮对话）", example = "123")
    private String conversationId;
}

<template>
  <div class="chatbot-container">
    <!-- 聊天历史 -->
    <div class="message-list" ref="messageListRef">
      <div
        v-for="(msg, index) in messages"
        :key="index"
        :class="['message-item', msg.role === 'user' ? 'user-msg' : 'ai-msg']"
      >
        <!-- AI 消息 -->
        <div v-if="msg.role === 'ai'" class="ai-message">
          <div class="avatar ai-avatar">🤖</div>
          <div class="content">
            <p class="text">{{ msg.content }}</p>
            <span class="time">{{ formatTime(msg.time) }}</span>
          </div>
        </div>

        <!-- 用户消息 -->
        <div v-else class="user-message">
          <div class="content">
            <p class="text">{{ msg.content }}</p>
            <span class="time">{{ formatTime(msg.time) }}</span>
          </div>
          <div class="avatar user-avatar">👤</div>
        </div>
      </div>

      <!-- 加载中 -->
      <div v-if="loading" class="message-item ai-msg">
        <div class="ai-message">
          <div class="avatar ai-avatar">🤖</div>
          <div class="content">
            <div class="loading-dots">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 输入区 -->
    <div class="input-area">
      <input
        v-model="userInput"
        @keyup.enter="sendMessage"
        @focus="inputFocused = true"
        @blur="inputFocused = false"
        placeholder="输入问题，按 Enter 发送..."
        class="message-input"
        :disabled="loading"
        maxlength="500"
      />
      <button
        @click="sendMessage"
        :disabled="loading || !userInput.trim()"
        class="send-btn"
        :class="{ 'btn-loading': loading }"
      >
        <span v-if="!loading">发送</span>
        <span v-else>发送中...</span>
      </button>
    </div>

    <!-- 字符计数 -->
    <div class="char-count">{{ userInput.length }}/500</div>
  </div>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted } from 'vue'
import { sendChatMessage, getChatBotWelcome } from '@/services/chatbotApi'

interface Message {
  role: 'user' | 'ai'
  content: string
  time: number
}

const messages = ref<Message[]>([])
const userInput = ref('')
const loading = ref(false)
const inputFocused = ref(false)
const messageListRef = ref<HTMLElement>()

/**
 * 发送消息
 */
const sendMessage = async () => {
  const message = userInput.value.trim()
  if (!message || loading.value) return

  // 添加用户消息
  messages.value.push({
    role: 'user',
    content: message,
    time: Date.now()
  })

  userInput.value = ''
  loading.value = true

  try {
    // 调用API
    const result = await sendChatMessage(message)

    if (result.success) {
      // 添加 AI 回复
      messages.value.push({
        role: 'ai',
        content: result.data.message,
        time: Date.now()
      })
    } else {
      // 错误回复
      messages.value.push({
        role: 'ai',
        content: result.error || '抱歉，无法回复，请稍后重试',
        time: Date.now()
      })
    }
  } catch (error: any) {
    console.error('发送消息失败:', error)
    messages.value.push({
      role: 'ai',
      content: '抱歉，系统出错，请稍后重试',
      time: Date.now()
    })
  } finally {
    loading.value = false
    // 滚动到底部
    await nextTick()
    scrollToBottom()
  }
}

/**
 * 滚动到底部
 */
const scrollToBottom = () => {
  if (messageListRef.value) {
    messageListRef.value.scrollTop = messageListRef.value.scrollHeight
  }
}

/**
 * 格式化时间
 */
const formatTime = (timestamp: number): string => {
  const date = new Date(timestamp)
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${hours}:${minutes}`
}

/**
 * 初始化 - 获取欢迎语
 */
const initWelcome = async () => {
  try {
    const result = await getChatBotWelcome()
    if (result.success) {
      messages.value.push({
        role: 'ai',
        content: result.data.message,
        time: Date.now()
      })
      await nextTick()
      scrollToBottom()
    }
  } catch (error) {
    console.error('获取欢迎语失败:', error)
  }
}

onMounted(() => {
  initWelcome()
})
</script>

<style scoped>
.chatbot-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

/* 消息列表 */
.message-list {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 12px;
  background: white;
}

.message-item {
  display: flex;
  animation: slideIn 0.3s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* AI 消息 */
.ai-msg {
  justify-content: flex-start;
}

.ai-message {
  display: flex;
  gap: 8px;
  align-items: flex-end;
}

.ai-avatar {
  font-size: 24px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.ai-message .content {
  background: #f5f5f5;
  border-radius: 8px;
  padding: 10px 12px;
  max-width: 70%;
  word-wrap: break-word;
  white-space: pre-wrap;
}

.ai-message .text {
  color: #333;
  margin: 0;
  font-size: 14px;
  line-height: 1.5;
}

.ai-message .time {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
  display: block;
}

/* 用户消息 */
.user-msg {
  justify-content: flex-end;
}

.user-message {
  display: flex;
  gap: 8px;
  align-items: flex-end;
}

.user-avatar {
  font-size: 24px;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.user-message .content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 8px;
  padding: 10px 12px;
  max-width: 70%;
  word-wrap: break-word;
  white-space: pre-wrap;
}

.user-message .text {
  color: white;
  margin: 0;
  font-size: 14px;
  line-height: 1.5;
}

.user-message .time {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
  display: block;
}

/* 加载动画 */
.loading-dots {
  display: flex;
  gap: 4px;
  padding: 8px 0;
}

.loading-dots span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #667eea;
  animation: loading 1.4s infinite;
}

.loading-dots span:nth-child(1) {
  animation-delay: -0.32s;
}

.loading-dots span:nth-child(2) {
  animation-delay: -0.16s;
}

.loading-dots span:nth-child(3) {
  animation-delay: 0s;
}

@keyframes loading {
  0%, 80%, 100% {
    opacity: 0.5;
    transform: scale(0.8);
  }
  40% {
    opacity: 1;
    transform: scale(1);
  }
}

/* 输入区 */
.input-area {
  display: flex;
  gap: 8px;
  padding: 12px;
  background: white;
  border-top: 1px solid #eee;
}

.message-input {
  flex: 1;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 14px;
  font-family: inherit;
  resize: none;
  transition: all 0.3s;
}

.message-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.message-input:disabled {
  background: #f5f5f5;
  cursor: not-allowed;
}

/* 发送按钮 */
.send-btn {
  padding: 10px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.3s;
  white-space: nowrap;
  flex-shrink: 0;
}

.send-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.send-btn:active:not(:disabled) {
  transform: translateY(0);
}

.send-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.send-btn.btn-loading {
  pointer-events: none;
}

/* 字符计数 */
.char-count {
  padding: 4px 12px 0 12px;
  font-size: 12px;
  color: #999;
  text-align: right;
  background: white;
  border-top: 1px solid #f0f0f0;
  padding-bottom: 8px;
}

/* 滚动条样式 */
.message-list::-webkit-scrollbar {
  width: 6px;
}

.message-list::-webkit-scrollbar-track {
  background: transparent;
}

.message-list::-webkit-scrollbar-thumb {
  background: #ddd;
  border-radius: 3px;
}

.message-list::-webkit-scrollbar-thumb:hover {
  background: #ccc;
}

/* 响应式 */
@media (max-width: 768px) {
  .ai-message .content,
  .user-message .content {
    max-width: 85%;
  }

  .message-input {
    font-size: 16px; /* 防止 iOS 自动放大 */
  }
}
</style>

<template>
  <!-- AI 客服浮窗 -->
  <div v-if="isOpen" class="chatbot-window">
    <!-- 窗口标题栏 -->
    <div class="window-header">
      <div class="header-left">
        <span class="title">💬 AI 客服助手</span>
      </div>
      <div class="header-right">
        <button class="minimize-btn" @click="isMinimized = !isMinimized" :title="isMinimized ? '展开' : '最小化'">
          {{ isMinimized ? '📈' : '📉' }}
        </button>
        <button class="close-btn" @click="closeWindow" title="关闭">✕</button>
      </div>
    </div>

    <!-- 窗口内容 -->
    <div v-if="!isMinimized" class="window-content">
      <ChatBot />
    </div>

    <!-- 最小化状态 -->
    <div v-else class="minimized-state">
      点击展开聊天
    </div>
  </div>

  <!-- 浮动按钮（关闭状态） -->
  <div v-else class="floating-button" @click="openWindow" title="打开客服">
    💬
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import ChatBot from './ChatBot.vue'

const isOpen = ref(false)
const isMinimized = ref(false)

const openWindow = () => {
  isOpen.value = true
  isMinimized.value = false
}

const closeWindow = () => {
  isOpen.value = false
  isMinimized.value = false
}

// 全局事件监听
onMounted(() => {
  const handleOpenChatbot = () => {
    openWindow()
  }
  window.addEventListener('open-chatbot', handleOpenChatbot)
  return () => {
    window.removeEventListener('open-chatbot', handleOpenChatbot)
  }
})

// 暴露打开方法供外部调用
defineExpose({
  openWindow,
  closeWindow
})
</script>

<style scoped>
/* 浮动按钮 */
.floating-button {
  position: fixed;
  bottom: 30px;
  right: 30px;
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  cursor: pointer;
  transition: all 0.3s ease;
  z-index: 999;
  user-select: none;
}

.floating-button:hover {
  transform: scale(1.1);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.6);
}

.floating-button:active {
  transform: scale(0.95);
}

/* 聊天窗口 */
.chatbot-window {
  position: fixed;
  bottom: 30px;
  right: 30px;
  width: 400px;
  height: 600px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 5px 30px rgba(0, 0, 0, 0.2);
  display: flex;
  flex-direction: column;
  z-index: 1000;
  animation: slideUp 0.3s ease-out;
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 窗口标题栏 */
.window-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px 12px 0 0;
  color: white;
  user-select: none;
}

.header-left {
  flex: 1;
}

.title {
  font-size: 14px;
  font-weight: 600;
}

.header-right {
  display: flex;
  gap: 8px;
}

.minimize-btn,
.close-btn {
  width: 24px;
  height: 24px;
  border: none;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border-radius: 4px;
  cursor: pointer;
  font-size: 12px;
  transition: all 0.2s;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}

.minimize-btn:hover,
.close-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

/* 窗口内容 */
.window-content {
  flex: 1;
  overflow: hidden;
}

/* 最小化状态 */
.minimized-state {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 50px;
  color: #666;
  font-size: 12px;
  cursor: pointer;
  border-radius: 0 0 12px 12px;
  background: #f9f9f9;
  transition: all 0.2s;
}

.minimized-state:hover {
  background: #f0f0f0;
}

/* 响应式设计 */
@media (max-width: 480px) {
  .chatbot-window {
    width: calc(100vw - 40px);
    height: calc(100vh - 100px);
    max-width: 100%;
    max-height: 100%;
    bottom: 20px;
    right: 20px;
    left: 20px;
  }

  .floating-button {
    bottom: 20px;
    right: 20px;
  }
}
</style>

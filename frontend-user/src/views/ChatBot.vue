<template>
  <div class="chatbot-page">
    <div class="page-header">
      <button class="back-btn" @click="goBack">← 返回</button>
      <h1>AI 客服助手</h1>
      <div style="width: 40px"></div>
    </div>

    <div class="chatbot-wrapper">
      <ChatBot />
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import ChatBot from '@/components/ChatBot.vue'

const router = useRouter()

const goBack = () => {
  router.back()
}
</script>

<style scoped>
.chatbot-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: #f5f5f5;
}

.page-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  background: white;
  border-bottom: 1px solid #eee;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.page-header h1 {
  font-size: 20px;
  font-weight: 600;
  color: #333;
  margin: 0;
  flex: 1;
  text-align: center;
}

.back-btn {
  padding: 8px 16px;
  background: transparent;
  border: 1px solid #ddd;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  color: #333;
  transition: all 0.3s;
}

.back-btn:hover {
  background: #f5f5f5;
  border-color: #bbb;
}

.chatbot-wrapper {
  flex: 1;
  overflow: hidden;
  padding: 16px;
  display: flex;
  flex-direction: column;
}
</style>

<template>
  <Teleport to="body">
    <div class="global-notification-container">
      <transition-group name="notification-slide" tag="div">
        <div
          v-for="notification in notifications"
          :key="notification.id"
          :class="['notification-item', `notification-${notification.type}`]"
        >
          <div class="notification-content">
            <el-icon class="notification-icon">
              <component :is="getIcon(notification.type)" />
            </el-icon>
            <span class="notification-message">{{ notification.message }}</span>
            <el-icon class="notification-close" @click="closeNotification(notification.id)">
              <Close />
            </el-icon>
          </div>
          <div class="notification-progress" :style="{ width: notification.progress + '%' }"></div>
        </div>
      </transition-group>
    </div>
  </Teleport>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Close, SuccessFilled, CircleCloseFilled, WarningFilled, InfoFilled } from '@element-plus/icons-vue'

const notifications = ref([])
let nextId = 0

// 获取对应类型的图标
const getIcon = (type) => {
  const iconMap = {
    success: 'SuccessFilled',
    error: 'CircleCloseFilled',
    warning: 'WarningFilled',
    info: 'InfoFilled'
  }
  return iconMap[type] || 'InfoFilled'
}

// 添加通知
const addNotification = (message, type = 'info', duration = 3000) => {
  const id = nextId++
  const notification = {
    id,
    message,
    type,
    progress: 100
  }

  notifications.value.push(notification)

  // 进度条动画
  if (duration > 0) {
    let startTime = Date.now()
    const updateProgress = () => {
      const elapsed = Date.now() - startTime
      const newProgress = Math.max(0, 100 - (elapsed / duration) * 100)
      
      const notif = notifications.value.find(n => n.id === id)
      if (notif) {
        notif.progress = newProgress
      }

      if (newProgress > 0) {
        requestAnimationFrame(updateProgress)
      } else {
        closeNotification(id)
      }
    }

    requestAnimationFrame(updateProgress)
  }
}

// 关闭通知
const closeNotification = (id) => {
  const index = notifications.value.findIndex(n => n.id === id)
  if (index > -1) {
    notifications.value.splice(index, 1)
  }
}

// 暴露给全局
onMounted(() => {
  window.$notification = {
    success: (message, duration = 3000) => addNotification(message, 'success', duration),
    error: (message, duration = 3000) => addNotification(message, 'error', duration),
    warning: (message, duration = 3000) => addNotification(message, 'warning', duration),
    info: (message, duration = 3000) => addNotification(message, 'info', duration),
    close: closeNotification
  }
})
</script>

<style scoped>
.global-notification-container {
  position: fixed;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  z-index: 9999;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.notification-item {
  display: flex;
  flex-direction: column;
  min-width: 350px;
  max-width: 500px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  overflow: hidden;
  animation: slideIn 0.3s ease-out;
}

.notification-content {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  background: #fff;
}

.notification-icon {
  font-size: 20px;
  flex-shrink: 0;
}

.notification-message {
  flex: 1;
  font-size: 14px;
  color: #333;
  word-break: break-word;
}

.notification-close {
  font-size: 18px;
  color: #999;
  cursor: pointer;
  flex-shrink: 0;
  transition: color 0.2s;
}

.notification-close:hover {
  color: #666;
}

.notification-progress {
  height: 3px;
  background: #666;
  transition: width 0.05s linear;
}

/* 根据类型设置样式 */
.notification-success {
  border-left: 4px solid var(--success-color);
}

.notification-success .notification-icon {
  color: var(--success-color);
}

.notification-success .notification-progress {
  background: var(--success-color);
}

.notification-error {
  border-left: 4px solid var(--danger-color);
}

.notification-error .notification-icon {
  color: var(--danger-color);
}

.notification-error .notification-progress {
  background: var(--danger-color);
}

.notification-warning {
  border-left: 4px solid var(--warning-color);
}

.notification-warning .notification-icon {
  color: var(--warning-color);
}

.notification-warning .notification-progress {
  background: var(--warning-color);
}

.notification-info {
  border-left: 4px solid var(--info-color);
}

.notification-info .notification-icon {
  color: var(--info-color);
}

.notification-info .notification-progress {
  background: var(--info-color);
}

/* 动画 */
@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.notification-slide-enter-active {
  transition: all 0.3s ease-out;
}

.notification-slide-leave-active {
  transition: all 0.2s ease-in;
}

.notification-slide-enter-from {
  opacity: 0;
  transform: translateY(-20px);
}

.notification-slide-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}
</style>


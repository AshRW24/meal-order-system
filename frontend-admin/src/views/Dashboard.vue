<template>
  <div class="dashboard">
    <h2>欢迎使用外卖订餐管理系统</h2>

    <el-row :gutter="20" style="margin-top: 30px">
      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <el-icon class="stat-icon" :style="{color: 'var(--primary-color)'}" :size="40"><Document /></el-icon>
            <div class="stat-content">
              <div class="stat-value">{{ stats.orderCount }}</div>
              <div class="stat-label">今日订单</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <el-icon class="stat-icon" :style="{color: 'var(--secondary-color)'}" :size="40"><Money /></el-icon>
            <div class="stat-content">
              <div class="stat-value">¥{{ stats.todayAmount }}</div>
              <div class="stat-label">今日销售额</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <el-icon class="stat-icon" :style="{color: 'var(--warning-color)'}" :size="40"><Food /></el-icon>
            <div class="stat-content">
              <div class="stat-value">{{ stats.dishCount }}</div>
              <div class="stat-label">菜品总数</div>
            </div>
          </div>
        </el-card>
      </el-col>

      <el-col :span="6">
        <el-card shadow="hover">
          <div class="stat-item">
            <el-icon class="stat-icon" :style="{color: 'var(--danger-color)'}" :size="40"><User /></el-icon>
            <div class="stat-content">
              <div class="stat-value">{{ stats.userCount }}</div>
              <div class="stat-label">用户总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import request from '../utils/request'

const stats = ref({
  orderCount: 0,
  todayAmount: 0,
  dishCount: 0,
  userCount: 0
})

// 获取统计数据
const fetchStats = async () => {
  try {
    // const res = await request.get('/admin/dashboard/stats')
    // stats.value = res.data

    // 模拟数据
    stats.value = {
      orderCount: 128,
      todayAmount: 15680,
      dishCount: 56,
      userCount: 1234
    }
  } catch (error) {
    console.error('获取统计数据失败：', error)
  }
}

onMounted(() => {
  fetchStats()
})
</script>

<style scoped>
.dashboard {
  padding: 20px;
  width: 100%;
}

.dashboard h2 {
  margin: 0 0 20px 0;
  color: var(--primary-color);
  font-size: 24px;
  font-weight: 600;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 20px;
}

.stat-icon {
  flex-shrink: 0;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #333;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #999;
}
</style>

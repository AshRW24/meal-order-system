<template>
  <div class="app-wrapper">
    <div class="app-window">
      <el-header class="header">
        <div class="header-content">
          <!-- Back Button added for consistency -->
          <el-button @click="$router.push('/')">返回首页</el-button>
          <h2 class="title">我的订单</h2>
          <div style="width: 80px"></div> <!-- Spacer for centering title -->
        </div>
      </el-header>

      <el-main class="window-content">
        <div class="orders-content">
          <div v-if="loading" class="loading">
            <el-icon class="is-loading"><Loading /></el-icon>
            <span>加载中...</span>
          </div>

          <div v-else-if="orderList.length === 0" class="empty">
            <el-empty description="暂无订单" />
          </div>

          <div v-else class="order-list">
            <el-card v-for="order in orderList" :key="order.id" class="order-item" shadow="hover">
              <div class="order-header">
                <span class="order-number">订单号：{{ order.orderNumber }}</span>
                <el-tag :type="getStatusType(order.status)">{{ getStatusText(order.status) }}</el-tag>
              </div>
              <div class="order-body">
                <div class="order-info">
                  <div class="info-row">
                    <span class="label">收货人：</span>
                    <span>{{ order.consignee }} {{ order.phone }}</span>
                  </div>
                  <div class="info-row">
                    <span class="label">收货地址：</span>
                    <span>{{ order.address }}</span>
                  </div>
                  <div class="info-row" v-if="order.remark">
                    <span class="label">备注：</span>
                    <span>{{ order.remark }}</span>
                  </div>
                  <div class="info-row">
                    <span class="label">下单时间：</span>
                    <span>{{ formatTime(order.orderTime) }}</span>
                  </div>
                </div>
                <div class="order-amount">
                  <div class="amount-label">订单金额</div>
                  <div class="amount-value">¥{{ order.amount.toFixed(2) }}</div>
                   <!-- 确认收货按钮：仅在状态为3(配送中)时显示 -->
                   <el-button 
                     v-if="order.status === 3" 
                     type="primary" 
                     size="small" 
                     style="margin-top: 10px;"
                     @click="handleConfirmReceipt(order)"
                   >
                     确认收货
                   </el-button>
                </div>
              </div>
            </el-card>
          </div>
        </div>
      </el-main>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { Loading } from '@element-plus/icons-vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getOrderList, confirmReceipt } from '../api/order'

const orderList = ref([])
const loading = ref(false)

// 获取订单状态文本
const getStatusText = (status) => {
  const statusMap = {
    1: '待确认',
    2: '已确认',
    3: '配送中',
    4: '已完成',
    5: '已取消'
  }
  return statusMap[status] || '未知'
}

// 获取订单状态类型
const getStatusType = (status) => {
  const typeMap = {
    1: 'warning',
    2: 'success',
    3: 'primary',
    4: 'info',
    5: 'danger'
  }
  return typeMap[status] || 'info'
}

// 格式化时间
const formatTime = (timeStr) => {
  if (!timeStr) return ''
  const date = new Date(timeStr)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 加载订单列表
const loadOrderList = async () => {
  loading.value = true
  try {
    const response = await getOrderList()
    if (response.code === 200) {
      orderList.value = response.data
    } else {
      ElMessage.error(response.msg || '加载订单列表失败')
    }
  } catch (error) {
    console.error('加载订单列表失败:', error)
    ElMessage.error('加载订单列表失败')
  } finally {
    loading.value = false
  }
}

// 确认收货处理
const handleConfirmReceipt = (order) => {
  ElMessageBox.confirm('确认已收到商品吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const res = await confirmReceipt(order.id)
      if (res.code === 200) {
        ElMessage.success('确认收货成功')
        loadOrderList() // 刷新列表
      }
    } catch (error) {
      console.error(error)
    }
  })
}

onMounted(() => {
  loadOrderList()
})
</script>

<style scoped>
.header {
  background: #fff;
  border-bottom: 1px solid #eee;
  padding: 0;
  height: 60px;
  flex-shrink: 0; /* Prevent shrinking */
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  padding: 0 20px;
}

.title {
  margin: 0;
  color: #333;
  font-size: 18px;
  font-weight: 600;
}

.orders-content {
  padding: 20px;
  max-width: 1000px;
  margin: 0 auto;
}

/* ... rest same ... */
/* Remove old container styles */
/*
.orders-container {
  max-width: 1200px;
  margin: 20px auto;
  padding: 0 20px;
}

.orders-card {
  margin-bottom: 20px;
}
*/

.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 50px 0;
  color: #999;
}
/* ... rest same ... */

.loading .el-icon {
  font-size: 40px;
  margin-bottom: 10px;
}

.empty {
  padding: 50px 0;
}

.order-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.order-item {
  border: 1px solid #ebeef5;
}

.order-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 15px;
  border-bottom: 1px solid #ebeef5;
  margin-bottom: 15px;
}

.order-number {
  font-size: 14px;
  color: #666;
}

.order-body {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
}

.order-info {
  flex: 1;
}

.info-row {
  margin-bottom: 10px;
  font-size: 14px;
  color: #666;
}

.info-row:last-child {
  margin-bottom: 0;
}

.label {
  color: #999;
  margin-right: 5px;
}

.order-amount {
  text-align: right;
  margin-left: 20px;
}

.amount-label {
  font-size: 14px;
  color: #999;
  margin-bottom: 5px;
}

.amount-value {
  font-size: 24px;
  color: #f56c6c;
  font-weight: 600;
}
</style>

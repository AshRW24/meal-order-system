<template>
  <div class="app-wrapper">
    <div class="app-window">
      <el-header class="header">
        <div class="header-content">
          <el-button @click="$router.back()">返回</el-button>
          <h2 class="title">账户充值</h2>
          <div style="width: 60px"></div>
        </div>
      </el-header>

      <el-main class="window-content">
        <div class="recharge-content">
          <!-- 当前余额显示 -->
          <el-card class="balance-card" shadow="never">
            <div class="balance-info">
              <div class="balance-label">当前余额</div>
              <div class="balance-value">¥{{ balance.toFixed(2) }}</div>
            </div>
          </el-card>

          <!-- 充值金额选择 -->
          <el-card class="amount-card" shadow="never">
            <template #header>
              <h3>选择充值金额</h3>
            </template>
            <div class="amount-options">
              <el-button
                v-for="amount in presetAmounts"
                :key="amount"
                :type="selectedAmount === amount ? 'primary' : ''"
                class="amount-btn"
                @click="selectedAmount = amount"
              >
                ¥{{ amount }}
              </el-button>
            </div>
            <div class="custom-amount">
              <el-input-number
                v-model="customAmount"
                :min="0.01"
                :precision="2"
                :step="10"
                placeholder="或输入自定义金额"
                style="width: 100%"
                size="large"
                @change="handleCustomAmountChange"
              />
            </div>
          </el-card>

          <!-- 充值说明 -->
          <el-card class="info-card" shadow="never">
            <el-alert
              title="充值说明"
              type="info"
              :closable="false"
              show-icon
            >
              <template #default>
                <ul class="info-list">
                  <li>充值金额将直接存入您的账户余额</li>
                  <li>余额可用于支付订单，支持部分支付</li>
                  <li>充值后余额永久有效</li>
                </ul>
              </template>
            </el-alert>
          </el-card>

          <!-- 充值按钮 -->
          <div class="submit-section">
            <el-button
              type="primary"
              size="large"
              :disabled="!canRecharge"
              :loading="recharging"
              @click="handleRecharge"
              style="width: 100%; height: 50px; font-size: 18px;"
            >
              确认充值 ¥{{ rechargeAmount.toFixed(2) }}
            </el-button>
          </div>
        </div>
      </el-main>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { recharge, getBalance } from '../api/user'

const router = useRouter()

const balance = ref(0)
const selectedAmount = ref(null)
const customAmount = ref(null)
const recharging = ref(false)

// 预设充值金额
const presetAmounts = [10, 20, 50, 100, 200, 500]

// 计算充值金额
const rechargeAmount = computed(() => {
  if (customAmount.value && customAmount.value > 0) {
    return customAmount.value
  }
  return selectedAmount.value || 0
})

// 是否可以充值
const canRecharge = computed(() => {
  return rechargeAmount.value > 0
})

// 自定义金额变化
const handleCustomAmountChange = () => {
  if (customAmount.value && customAmount.value > 0) {
    selectedAmount.value = null
  }
}

// 加载余额
const loadBalance = async () => {
  try {
    const res = await getBalance()
    if (res.code === 200) {
      balance.value = res.data.balance || 0
    }
  } catch (error) {
    console.error('加载余额失败:', error)
  }
}

// 充值
const handleRecharge = async () => {
  if (!canRecharge.value) {
    ElMessage.warning('请选择或输入充值金额')
    return
  }

  recharging.value = true
  try {
    const res = await recharge(rechargeAmount.value)
    if (res.code === 200) {
      ElMessage.success(`充值成功！当前余额：¥${res.data.balance.toFixed(2)}`)
      balance.value = res.data.balance
      // 重置选择
      selectedAmount.value = null
      customAmount.value = null
      // 延迟返回
      setTimeout(() => {
        router.back()
      }, 1500)
    }
  } catch (error) {
    console.error('充值失败:', error)
  } finally {
    recharging.value = false
  }
}

onMounted(() => {
  loadBalance()
})
</script>

<style scoped>
.header {
  background: #fff;
  border-bottom: 1px solid #eee;
  padding: 0;
  height: 60px;
  flex-shrink: 0;
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

.recharge-content {
  padding: 30px;
  max-width: 600px;
  margin: 0 auto;
}

.balance-card {
  margin-bottom: 20px;
  background: linear-gradient(135deg, #FFD700 0%, #D4AF37 100%);
  border: none;
}

.balance-info {
  text-align: center;
  padding: 20px 0;
}

.balance-label {
  font-size: 16px;
  color: rgba(0, 0, 0, 0.7);
  margin-bottom: 10px;
}

.balance-value {
  font-size: 48px;
  font-weight: bold;
  color: #000;
}

.amount-card {
  margin-bottom: 20px;
}

.amount-card h3 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.amount-options {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
  margin-bottom: 20px;
}

.amount-btn {
  height: 60px;
  font-size: 18px;
  font-weight: 600;
}

.custom-amount {
  margin-top: 20px;
}

.info-card {
  margin-bottom: 30px;
}

.info-list {
  margin: 10px 0 0 0;
  padding-left: 20px;
  color: #666;
  line-height: 1.8;
}

.info-list li {
  margin-bottom: 5px;
}

.submit-section {
  margin-top: 30px;
}
</style>


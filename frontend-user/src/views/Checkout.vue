<template>
  <div class="app-wrapper">
    <div class="app-window">
      <el-header class="header">
        <div class="header-content">
          <el-button @click="$router.back()">返回</el-button>
          <h2 class="title">确认订单</h2>
          <div style="width: 60px"></div>
        </div>
      </el-header>

      <el-main class="window-content">
        <div class="checkout-content">
          <!-- 地址选择 -->
          <div class="section">
            <h3>配送地址</h3>
            <el-radio-group v-model="selectedAddressId" class="address-group">
              <el-radio
                v-for="addr in addressList"
                :key="addr.id"
                :label="addr.id"
                class="address-radio"
              >
                <div class="address-item">
                  <div class="address-info">
                    <span class="consignee">{{ addr.consignee }}</span>
                    <span class="phone">{{ addr.phone }}</span>
                    <el-tag v-if="addr.isDefault === 1" type="success" size="small">默认</el-tag>
                  </div>
                  <div class="address-detail">
                    {{ addr.province }} {{ addr.city }} {{ addr.district }} {{ addr.detail }}
                  </div>
                </div>
              </el-radio>
            </el-radio-group>
            <el-button type="text" @click="goToAddressManagement">
              管理地址
            </el-button>
          </div>

          <!-- 商品列表 -->
          <div class="section">
            <h3>商品清单</h3>
            <div class="cart-items">
              <div v-for="item in cartItems" :key="item.id" class="cart-item">
                <img :src="item.image || '/default-dish.png'" class="item-image" />
                <div class="item-info">
                  <div class="item-name">{{ item.itemName }}</div>
                  <div class="item-price">¥{{ item.price }} × {{ item.quantity }}</div>
                </div>
                <div class="item-subtotal">¥{{ (item.price * item.quantity).toFixed(2) }}</div>
              </div>
            </div>
          </div>

          <!-- 备注 -->
          <div class="section">
            <h3>订单备注</h3>
            <el-input
              v-model="remark"
              type="textarea"
              :rows="3"
              placeholder="选填，请输入备注信息"
              maxlength="200"
              show-word-limit
            />
          </div>

          <!-- 账户余额 -->
          <div class="section balance-section">
            <div class="balance-row">
              <span>账户余额：</span>
              <span class="balance-amount">¥{{ userBalance.toFixed(2) }}</span>
              <el-button type="primary" size="small" link @click="goToRecharge">去充值</el-button>
            </div>
            <el-alert
              v-if="userBalance < totalAmount"
              title="余额不足，请先充值"
              type="warning"
              :closable="false"
              show-icon
              style="margin-top: 10px;"
            />
          </div>

          <!-- 总计 -->
          <div class="section total-section">
            <div class="total-row">
              <span>商品总额：</span>
              <span class="amount">¥{{ totalAmount.toFixed(2) }}</span>
            </div>
            <div class="total-row">
              <span>配送费：</span>
              <span class="amount">¥0.00</span>
            </div>
            <div class="total-row final-total">
              <span>实付款：</span>
              <span class="amount">¥{{ totalAmount.toFixed(2) }}</span>
            </div>
          </div>

          <!-- 提交按钮 -->
          <div class="submit-section">
            <el-button type="primary" size="large" @click="handleSubmitOrder" :loading="submitting">
              提交订单
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
import { ElMessage, ElMessageBox } from 'element-plus'
import { getCartList } from '../api/cart'
import { getAddressList } from '../api/address'
import { submitOrder } from '../api/order'
import { getBalance } from '../api/user'

const router = useRouter()

const cartItems = ref([])
const addressList = ref([])
const selectedAddressId = ref(null)
const remark = ref('')
const submitting = ref(false)
const userBalance = ref(0)

// 计算总金额
const totalAmount = computed(() => {
  return cartItems.value.reduce((total, item) => {
    return total + item.price * item.quantity
  }, 0)
})

// 加载购物车数据
const loadCartItems = async () => {
  try {
    const response = await getCartList()
    if (response.code === 200) {
      cartItems.value = response.data
    }
  } catch (error) {
    console.error('加载购物车失败:', error)
    ElMessage.error('加载购物车失败')
  }
}

// 加载地址列表
const loadAddressList = async () => {
  try {
    const response = await getAddressList()
    if (response.code === 200) {
      addressList.value = response.data
      // 自动选择默认地址
      const defaultAddress = addressList.value.find(addr => addr.isDefault === 1)
      if (defaultAddress) {
        selectedAddressId.value = defaultAddress.id
      } else if (addressList.value.length > 0) {
        selectedAddressId.value = addressList.value[0].id
      }
    }
  } catch (error) {
    console.error('加载地址列表失败:', error)
    ElMessage.error('加载地址列表失败')
  }
}

// 加载余额
const loadBalance = async () => {
  try {
    const res = await getBalance()
    if (res.code === 200) {
      userBalance.value = res.data.balance || 0
    }
  } catch (error) {
    console.error('加载余额失败:', error)
  }
}

// 去充值
const goToRecharge = () => {
  router.push('/recharge')
}

// 提交订单
const handleSubmitOrder = async () => {
  if (!selectedAddressId.value) {
    ElMessage.warning('请选择收货地址')
    return
  }

  if (cartItems.value.length === 0) {
    ElMessage.warning('购物车为空，无法下单')
    return
  }

  // 检查余额
  if (userBalance.value < totalAmount.value) {
    ElMessage.warning('账户余额不足，请先充值')
    return
  }

  try {
    await ElMessageBox.confirm(
      `确认提交订单吗？总金额：¥${totalAmount.value.toFixed(2)}`,
      '确认订单',
      {
        confirmButtonText: '确认',
        cancelButtonText: '取消',
        type: 'info'
      }
    )

    submitting.value = true
    const response = await submitOrder({
      addressId: selectedAddressId.value,
      remark: remark.value
    })

    if (response.code === 200) {
      ElMessage.success('订单提交成功')
      // 刷新余额
      await loadBalance()
      // 跳转到订单列表页面
      router.push('/orders')
    } else {
      ElMessage.error(response.msg || '订单提交失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      console.error('提交订单失败:', error)
      ElMessage.error('订单提交失败')
    }
  } finally {
    submitting.value = false
  }
}

// 跳转到地址管理
const goToAddressManagement = () => {
  router.push('/address')
}

onMounted(() => {
  loadCartItems()
  loadAddressList()
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

.checkout-content {
  padding: 30px;
  max-width: 900px;
  margin: 0 auto;
}

.section {
  margin-bottom: 30px;
}

.section h3 {
  margin: 0 0 15px 0;
  font-size: 18px;
  color: #333;
  border-left: 4px solid var(--primary-color);
  padding-left: 10px;
}

/* 余额显示 */
.balance-section {
  margin-bottom: 30px;
  padding: 15px;
  background: #f9f9f9;
  border-radius: 8px;
}

.balance-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 16px;
}

.balance-amount {
  color: var(--secondary-color);
  font-weight: bold;
  font-size: 18px;
}
/* ... rest same ... */

/* 地址选择样式 */
.address-group {
  width: 100%;
}

.address-radio {
  width: 100%;
  margin-bottom: 15px;
  padding: 15px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  transition: all 0.3s;
}

.address-radio:hover {
  border-color: #409eff;
  background-color: #f5f7fa;
}

.address-radio.is-checked {
  border-color: #409eff;
  background-color: #ecf5ff;
}

.address-item {
  margin-left: 10px;
}

.address-info {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 5px;
}

.consignee {
  font-weight: 500;
  color: #333;
}

.phone {
  color: #666;
}

.address-detail {
  color: #666;
  font-size: 14px;
}

/* 商品列表样式 */
.cart-items {
  border: 1px solid #ebeef5;
  border-radius: 4px;
}

.cart-item {
  display: flex;
  align-items: center;
  padding: 15px;
  border-bottom: 1px solid #ebeef5;
}

.cart-item:last-child {
  border-bottom: none;
}

.item-image {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 4px;
  margin-right: 15px;
}

.item-info {
  flex: 1;
}

.item-name {
  font-size: 16px;
  color: #333;
  margin-bottom: 5px;
}

.item-price {
  font-size: 14px;
  color: #666;
}

.item-subtotal {
  font-size: 18px;
  color: #f56c6c;
  font-weight: 500;
}

/* 总计样式 */
.total-section {
  border-top: 2px solid #ebeef5;
  padding-top: 20px;
}

.total-row {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  margin-bottom: 10px;
  font-size: 16px;
}

.total-row span:first-child {
  margin-right: 20px;
  color: #666;
}

.total-row .amount {
  font-size: 18px;
  color: #f56c6c;
  font-weight: 500;
}

.final-total {
  font-size: 18px;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px dashed #ebeef5;
}

.final-total span:first-child {
  font-weight: 500;
  color: #333;
}

.final-total .amount {
  font-size: 24px;
  font-weight: 600;
}

/* 提交按钮样式 */
.submit-section {
  display: flex;
  justify-content: flex-end;
  margin-top: 30px;
}

.submit-section .el-button {
  width: 200px;
}
</style>

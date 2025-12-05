<template>
  <div class="app-wrapper">
    <div class="app-window">
      <el-container class="full-height">
        <!-- 顶部导航栏 -->
        <el-header class="header">
          <div class="header-content">
            <el-button :icon="ArrowLeft" @click="handleBack">返回</el-button>
            <h2 class="title">购物车</h2>
            <el-button type="danger" text @click="handleClearCart" v-if="cartList.length > 0">清空购物车</el-button>
          </div>
        </el-header>

        <!-- 主体内容 -->
        <el-main class="main-content window-content">
          <!-- 空购物车提示 -->
          <el-empty v-if="cartList.length === 0 && !loading" description="购物车还是空的，快去选购商品吧！">
            <el-button type="primary" @click="handleGoShopping">去选购</el-button>
          </el-empty>

          <!-- 购物车列表 -->
          <div v-else v-loading="loading" class="cart-content-wrapper">
            <div class="cart-list">
              <el-card v-for="item in cartList" :key="item.id" class="cart-item" shadow="hover">
                <div class="item-content">
                  <!-- 商品图片 -->
                  <div class="item-image-container">
                    <el-image
                      v-if="item.image"
                      :src="getImageUrl(item.image)"
                      fit="cover"
                      class="item-image"
                    >
                      <template #error>
                        <div class="image-error">
                          <el-icon><Picture /></el-icon>
                        </div>
                      </template>
                    </el-image>
                    <div v-else class="image-error">
                      <el-icon><Picture /></el-icon>
                    </div>
                  </div>

                  <!-- 商品信息 -->
                  <div class="item-info">
                    <h3 class="item-name">{{ item.itemName }}</h3>
                    <div class="item-type-tag">
                      <el-tag :type="item.itemType === 1 ? 'success' : 'warning'" size="small">
                        {{ item.itemType === 1 ? '菜品' : '套餐' }}
                      </el-tag>
                    </div>
                    <div class="item-price">
                      <span class="price-label">¥</span>
                      <span class="price-value" style="color: var(--secondary-color);">{{ item.price }}</span>
                      <span class="price-unit"> / 份</span>
                    </div>
                  </div>

                  <!-- 数量和操作 -->
                  <div class="item-actions">
                    <div class="quantity-control">
                      <el-input-number
                        v-model="item.quantity"
                        :min="1"
                        :max="99"
                        @change="handleQuantityChange(item)"
                      />
                    </div>
                    <div class="subtotal">
                      <span class="subtotal-label">小计：</span>
                      <span class="subtotal-value" style="color: var(--secondary-color); font-weight: bold;">¥{{ (item.price * item.quantity).toFixed(2) }}</span>
                    </div>
                    <el-button type="danger" size="small" @click="handleDeleteItem(item)">
                      删除
                    </el-button>
                  </div>
                </div>
              </el-card>
            </div>

            <!-- 底部统计 -->
            <el-card v-if="cartList.length > 0" class="cart-summary" shadow="never">
              <div class="summary-content">
                <div class="summary-left">
                  <span class="total-items">共 {{ totalItems }} 件商品</span>
                </div>
                <div class="summary-right">
                  <div class="total-price">
                    <span class="total-label">合计：</span>
                    <span class="total-symbol" style="color: var(--secondary-color);">¥</span>
                    <span class="total-value" style="color: var(--secondary-color); font-weight: bold; font-size: 28px;">{{ totalAmount }}</span>
                  </div>
                  <el-button type="primary" size="large" @click="handleCheckout">
                    去结算
                  </el-button>
                </div>
              </div>
            </el-card>
          </div>
        </el-main>
      </el-container>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { ArrowLeft, Picture } from '@element-plus/icons-vue'
import { getCartList, clearCart, updateCartQuantity, deleteCartItem } from '../api/cart'

const router = useRouter()
const loading = ref(false)
const cartList = ref([])

// 初始化
onMounted(() => {
  loadCartList()
})

// 加载购物车列表
const loadCartList = async () => {
  loading.value = true
  try {
    const res = await getCartList()
    if (res.code === 200) {
      cartList.value = res.data
    }
  } catch (error) {
    window.$notification?.error('加载购物车失败')
  } finally {
    loading.value = false
  }
}

// 计算总数量
const totalItems = computed(() => {
  return cartList.value.reduce((sum, item) => sum + item.quantity, 0)
})

// 计算总金额
const totalAmount = computed(() => {
  const amount = cartList.value.reduce((sum, item) => {
    return sum + (item.price * item.quantity)
  }, 0)
  return amount.toFixed(2)
})

// 获取图片URL
const getImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `http://localhost:8080/api${url}`
}

// 数量变化
const handleQuantityChange = async (item) => {
  try {
    const res = await updateCartQuantity(item.id, item.quantity)
    if (res.code === 200) {
      window.$notification?.success('修改成功')
      // 不需要重新加载列表，因为数量已经通过 v-model 更新了
    }
  } catch (error) {
    window.$notification?.error('修改失败')
    // 失败时重新加载列表，恢复原数量
    loadCartList()
  }
}

// 删除单个商品
const handleDeleteItem = (item) => {
  ElMessageBox.confirm(`确定要删除"${item.itemName}"吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const res = await deleteCartItem(item.id)
      if (res.code === 200) {
        window.$notification?.success('删除成功')
        loadCartList()
      }
    } catch (error) {
      window.$notification?.error('删除失败')
    }
  }).catch(() => {})
}

// 返回
const handleBack = () => {
  router.push('/home')
}

// 去选购
const handleGoShopping = () => {
  router.push('/home')
}

// 清空购物车
const handleClearCart = () => {
  ElMessageBox.confirm('确定要清空购物车吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      const res = await clearCart()
      if (res.code === 200) {
        window.$notification?.success('购物车已清空')
        cartList.value = []
      }
    } catch (error) {
      window.$notification?.error('清空失败')
    }
  }).catch(() => {})
}

// 去结算
const handleCheckout = () => {
  router.push('/checkout')
}
</script>

<style scoped>
.cart-container {
  min-height: 100vh;
  background: #f5f5f5;
}

.header {
  background: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 0;
  height: 60px;
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
  flex: 1;
  text-align: center;
}

.main-content {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

/* 购物车列表 */
.cart-list {
  margin-bottom: 20px;
}

.cart-item {
  margin-bottom: 15px;
}

.item-content {
  display: flex;
  gap: 20px;
  align-items: center;
}

/* 商品图片 */
.item-image-container {
  flex-shrink: 0;
  width: 100px;
  height: 100px;
  border-radius: 8px;
  overflow: hidden;
  background: #f5f5f5;
}

.item-image {
  width: 100%;
  height: 100%;
}

.image-error {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 100%;
  background: #f5f5f5;
  color: #ccc;
}

/* 商品信息 */
.item-info {
  flex: 1;
  min-width: 0;
}

.item-name {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: bold;
  color: #333;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.item-type-tag {
  margin-bottom: 8px;
}

.item-price {
  display: flex;
  align-items: baseline;
  color: #ff6b6b;
}

.price-label {
  font-size: 14px;
  font-weight: bold;
}

.price-value {
  font-size: 20px;
  font-weight: bold;
  margin-left: 2px;
}

.price-unit {
  font-size: 12px;
  color: #999;
  margin-left: 4px;
}

/* 操作区域 */
.item-actions {
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
}

.quantity-control {
  width: 120px;
}

.subtotal {
  display: flex;
  align-items: baseline;
  gap: 5px;
}

.subtotal-label {
  font-size: 14px;
  color: #666;
}

.subtotal-value {
  font-size: 18px;
  font-weight: bold;
  color: #ff6b6b;
}

/* 底部统计 */
.cart-summary {
  position: sticky;
  bottom: 20px;
  z-index: 100;
  border: 2px solid #409EFF;
}

.summary-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
}

.summary-left {
  flex: 1;
}

.total-items {
  font-size: 16px;
  color: #666;
}

.summary-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.total-price {
  display: flex;
  align-items: baseline;
}

.total-label {
  font-size: 16px;
  color: #333;
  margin-right: 5px;
}

.total-symbol {
  font-size: 18px;
  font-weight: bold;
  color: #ff6b6b;
}

.total-value {
  font-size: 28px;
  font-weight: bold;
  color: #ff6b6b;
}

/* 响应式 */
@media (max-width: 768px) {
  .item-content {
    flex-direction: column;
    align-items: flex-start;
  }

  .item-actions {
    width: 100%;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
  }

  .summary-content {
    flex-direction: column;
    gap: 15px;
  }

  .summary-right {
    width: 100%;
    justify-content: space-between;
  }
}
</style>

<template>
  <div class="app-wrapper">
    <div class="app-window">
      <el-container class="full-height">
        <!-- 顶部导航栏 -->
        <el-header class="header">
          <div class="header-content">
            <h2 class="logo">外卖订餐系统</h2>
            <div class="user-info">
              <el-button :icon="ShoppingCart" @click="handleGoToCart">购物车</el-button>
              <div class="balance-info">
                <span class="balance-label">余额：</span>
                <span class="balance-value">¥{{ userBalance.toFixed(2) }}</span>
                <el-button type="primary" size="small" @click="handleRecharge" style="margin-left: 10px;">充值</el-button>
              </div>
              <!-- AI客服浮窗按钮 -->
              <el-button type="success" @click="openChatWindow" style="margin: 0 10px; font-weight: bold;">
                💬 AI客服助手
              </el-button>
              <span>欢迎，{{ userInfo.username }}</span>
              <el-button type="danger" text @click="handleLogout">退出登录</el-button>
            </div>
          </div>
        </el-header>

        <!-- 主体内容 -->
        <el-container class="main-container window-content">
          <!-- 左侧分类导航 -->
          <el-aside width="220px" class="category-aside">
            <el-card class="category-card">
              <template #header>
                <div class="category-header">
                  <el-icon><Grid /></el-icon>
                  <span>菜品分类</span>
                </div>
              </template>

              <el-menu
                :default-active="selectedCategoryId ? selectedCategoryId.toString() : ''"
                @select="handleCategorySelect"
              >
                <el-menu-item index="">
                  <el-icon><TakeawayBox /></el-icon>
                  <span>全部菜品</span>
                </el-menu-item>
                <el-menu-item
                  v-for="category in categoryList"
                  :key="category.id"
                  :index="category.id.toString()"
                >
                  <el-icon><Food /></el-icon>
                  <span>{{ category.name }}</span>
                </el-menu-item>
              </el-menu>
            </el-card>
          </el-aside>

          <!-- 右侧菜品列表 -->
          <el-main class="dish-main">
            <el-card class="dish-card">
              <template #header>
                <div class="dish-header">
                  <div>
                    <el-icon><ShoppingCart /></el-icon>
                    <span class="title">
                      {{ selectedCategoryId ? getCategoryName(selectedCategoryId) : '全部菜品' }}
                    </span>
                  </div>
                  <span class="dish-count">共 {{ dishList.length }} 道菜品</span>
                </div>
              </template>

              <!-- 菜品网格 -->
              <div v-loading="loading" class="dish-grid">
                <el-empty v-if="!loading && dishList.length === 0" description="暂无菜品" />

                <el-card
                  v-for="dish in dishList"
                  :key="dish.id"
                  shadow="hover"
                  class="dish-item-card"
                >
                  <!-- 菜品图片 -->
                  <div class="dish-image-container">
                    <el-image
                      v-if="dish.image"
                      :src="getImageUrl(dish.image)"
                      fit="cover"
                      class="dish-image"
                      :preview-src-list="[getImageUrl(dish.image)]"
                      :preview-teleported="true"
                    >
                      <template #error>
                        <div class="image-error">
                          <el-icon :size="40"><Picture /></el-icon>
                        </div>
                      </template>
                    </el-image>
                    <div v-else class="image-error">
                      <el-icon :size="40"><Picture /></el-icon>
                    </div>
                  </div>

                  <!-- 菜品信息 -->
                  <div class="dish-info">
                    <h3 class="dish-name">{{ dish.name }}</h3>
                    <p class="dish-description">{{ dish.description || '暂无描述' }}</p>

                    <div class="dish-footer">
                      <div class="dish-price">
                        <span class="price-label">¥</span>
                        <span class="price-value">{{ dish.price }}</span>
                      </div>
                      <el-button type="primary" :icon="ShoppingCart" circle @click="handleAddToCart(dish)" />
                    </div>
                  </div>
                </el-card>
              </div>
            </el-card>
          </el-main>
        </el-container>
      </el-container>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { ShoppingCart, Grid, Food, TakeawayBox, Picture } from '@element-plus/icons-vue'
import { getCategoryList } from '../api/category'
import { getDishList } from '../api/dish'
import { addToCart } from '../api/cart'
import { getBalance } from '../api/user'
import request from '../utils/request'

const router = useRouter()
const userInfo = ref({})
const userBalance = ref(0)
const loading = ref(false)

// 分类和菜品数据
const categoryList = ref([])
const dishList = ref([])
const selectedCategoryId = ref(null)

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
const handleRecharge = () => {
  router.push('/recharge')
}

// 初始化
onMounted(() => {
  const storedUserInfo = localStorage.getItem('userInfo')
  if (storedUserInfo) {
    userInfo.value = JSON.parse(storedUserInfo)
    userBalance.value = userInfo.value.balance || 0
  }

  loadCategoryList()
  loadDishList()
  loadBalance()
})

// 加载分类列表
const loadCategoryList = async () => {
  try {
    const res = await getCategoryList({ type: 1 })  // 只查询菜品分类
    if (res.code === 200) {
      categoryList.value = res.data
    }
  } catch (error) {
    console.error('加载分类列表失败:', error)
  }
}

// 加载菜品列表
const loadDishList = async (categoryId = null) => {
  loading.value = true
  try {
    const res = await getDishList({ categoryId })
    if (res.code === 200) {
      dishList.value = res.data
    }
  } catch (error) {
    window.$notification?.error('加载菜品列表失败')
  } finally {
    loading.value = false
  }
}

// 选择分类
const handleCategorySelect = (index) => {
  selectedCategoryId.value = index ? Number(index) : null
  loadDishList(selectedCategoryId.value)
}

// 获取分类名称
const getCategoryName = (categoryId) => {
  const category = categoryList.value.find(c => c.id === categoryId)
  return category ? category.name : ''
}

// 获取图片URL
const getImageUrl = (url) => {
  if (!url) return ''
  if (url.startsWith('http')) return url
  return `http://localhost:8080/api${url}`
}

// 添加到购物车
const handleAddToCart = async (dish) => {
  try {
    const res = await addToCart({
      itemId: dish.id,
      itemType: 1,  // 1-菜品
      quantity: 1
    })
    if (res.code === 200) {
      window.$notification?.success('添加成功')
    }
  } catch (error) {
    window.$notification?.error('添加失败')
  }
}

// 去购物车
const handleGoToCart = () => {
  router.push('/cart')
}

// 打开AI客服浮窗
const openChatWindow = () => {
  window.dispatchEvent(new Event('open-chatbot'))
}

// 退出登录
const handleLogout = async () => {
  try {
    // 调用后端登出接口
    await request.post('/user/logout')
  } catch (error) {
    console.error('登出失败：', error)
  } finally {
    // 无论后端请求是否成功，都清除本地信息并跳转
    localStorage.removeItem('token')
    localStorage.removeItem('userInfo')
    window.$notification?.success('退出登录成功')
    router.push('/login')
  }
}
</script>

<style scoped>
.full-height {
  height: 100%;
}

.header {
  background: #fff;
  border-bottom: 1px solid #eee;
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

.logo {
  margin: 0;
  color: var(--primary-color);
  font-weight: bold;
  font-size: 20px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.balance-info {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 5px 10px;
  background: rgba(212, 175, 55, 0.1);
  border-radius: 4px;
}

.balance-label {
  color: #666;
  font-size: 14px;
}

.balance-value {
  color: var(--secondary-color);
  font-weight: bold;
  font-size: 16px;
}

.main-container {
  /* height: calc(100vh - 60px); Removed: let flex handle it */
  flex: 1;
  overflow: hidden; /* Contain inner scrolling */
}

/* 左侧分类导航 */
.category-aside {
  padding: 20px 0 20px 20px;
  background: #fff; /* Ensure it matches window */
}

.category-card {
  height: 100%;
  overflow-y: auto;
  border: none; /* Clean look inside window */
  box-shadow: none !important;
}
/* ... rest same ... */

/* 右侧菜品列表 */
.dish-main {
  padding: 20px;
  overflow-y: auto; /* Enable scrolling for main content */
}

.dish-card {
  min-height: 100%; /* Fill height */
  border: none;
  box-shadow: none !important;
}

/* ... rest same ... */

.dish-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dish-header > div {
  display: flex;
  align-items: center;
  gap: 8px;
}

.dish-header .title {
  font-weight: bold;
  font-size: 16px;
}

.dish-count {
  color: #000000;
  font-size: 14px;
}

/* 菜品网格 */
.dish-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
  min-height: 400px;
}

.dish-item-card {
  cursor: pointer;
  transition: all 0.3s;
}

.dish-item-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

/* 菜品图片 */
.dish-image-container {
  width: 100%;
  height: 200px;
  border-radius: 8px;
  overflow: hidden;
  background: #f5f5f5;
}

.dish-image {
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

/* 菜品信息 */
.dish-info {
  padding: 12px 0 0 0;
}

.dish-name {
  margin: 0 0 8px 0;
  font-size: 16px;
  font-weight: bold;
  color: #000000;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.dish-description {
  margin: 0 0 12px 0;
  color: #000000;
  font-size: 13px;
  line-height: 1.5;
  height: 40px;
  overflow: hidden;
  text-overflow: ellipsis;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.dish-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: auto;
}

.dish-price {
  display: flex;
  align-items: baseline;
  color: var(--secondary-color);
}

.price-label {
  font-size: 14px;
  font-weight: bold;
}

.price-value {
  font-size: 24px;
  font-weight: bold;
  margin-left: 2px;
}
</style>

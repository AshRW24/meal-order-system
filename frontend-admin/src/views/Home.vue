<template>
  <div class="app-wrapper">
    <div class="app-window">
      <el-container class="layout-container">
        <!-- 侧边栏 -->
        <el-aside width="200px" class="aside">
          <div class="logo">
            <h3>订餐管理系统</h3>
          </div>
          <el-menu
            :default-active="activeMenu"
            router
            class="el-menu-vertical"
          >
            <el-menu-item index="/dashboard">
              <el-icon><HomeFilled /></el-icon>
              <span>首页</span>
            </el-menu-item>
            <el-menu-item index="/category">
              <el-icon><Menu /></el-icon>
              <span>分类管理</span>
            </el-menu-item>
            <el-menu-item index="/dish">
              <el-icon><Food /></el-icon>
              <span>菜品管理</span>
            </el-menu-item>
            <el-menu-item index="/setmeal">
              <el-icon><Box /></el-icon>
              <span>套餐管理</span>
            </el-menu-item>
            <el-menu-item index="/order">
              <el-icon><Document /></el-icon>
              <span>订单管理</span>
            </el-menu-item>
            <el-menu-item index="/sales">
              <el-icon><DataAnalysis /></el-icon>
              <span>销量统计</span>
            </el-menu-item>
          </el-menu>
        </el-aside>

        <!-- 主体内容 -->
        <el-container>
          <!-- 顶部导航 -->
          <el-header class="header">
            <div class="header-right">
              <el-dropdown @command="handleCommand">
                <span class="user-info">
                  {{ userStore.userInfo.username || '管理员' }}
                  <el-icon class="el-icon--right"><arrow-down /></el-icon>
                </span>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item command="logout">退出登录</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </el-header>

          <!-- 内容区域 -->
          <el-main class="main window-content">
            <router-view />
          </el-main>
        </el-container>
      </el-container>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { DataAnalysis } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import request from '../utils/request'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

const activeMenu = computed(() => route.path)

const handleCommand = async (command) => {
  if (command === 'logout') {
    ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(async () => {
      try {
        // 调用后端登出接口
        await request.post('/admin/logout')
      } catch (error) {
        console.error('登出失败：', error)
      } finally {
        // 无论后端请求是否成功，都清除本地信息并跳转
        userStore.clearUserInfo()
        router.push('/login')
      }
    }).catch(() => {})
  }
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.aside {
  background-color: var(--primary-color);
  color: #000000;
}

.logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: var(--primary-dark);
}

.logo h3 {
  color: #000000;
  font-size: 16px;
  margin: 0;
  font-weight: bold;
}

.el-menu-vertical {
  border-right: none;
}

.header {
  background-color: #fff;
  box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
  display: flex;
  justify-content: flex-end;
  align-items: center;
  padding: 0 20px;
  color: #000000;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  cursor: pointer;
  display: flex;
  align-items: center;
}

.main {
  background-color: #f0f2f5;
  padding: 0;
  width: 100%;
}

.main > * {
  width: 100%;
}
</style>

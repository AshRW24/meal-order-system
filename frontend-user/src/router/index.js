import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Home from '../views/Home.vue'
import Cart from '../views/Cart.vue'
import Address from '../views/Address.vue'
import Checkout from '../views/Checkout.vue'
import Orders from '../views/Orders.vue'
import Recharge from '../views/Recharge.vue'
import ChatBot from '../views/ChatBot.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/home',
    name: 'HomePage',
    component: Home
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/cart',
    name: 'Cart',
    component: Cart
  },
  {
    path: '/address',
    name: 'Address',
    component: Address
  },
  {
    path: '/checkout',
    name: 'Checkout',
    component: Checkout
  },
  {
    path: '/orders',
    name: 'Orders',
    component: Orders
  },
  {
    path: '/recharge',
    name: 'Recharge',
    component: Recharge
  },
  {
    path: '/chatbot',
    name: 'ChatBot',
    component: ChatBot
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')

  // 不需要登录的页面
  const whiteList = ['/login', '/', '/home', '/chatbot']

  if (whiteList.includes(to.path)) {
    next()
  } else {
    if (token) {
      next()
    } else {
      next('/login')
    }
  }
})

export default router

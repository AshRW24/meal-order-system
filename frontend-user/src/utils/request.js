import axios from 'axios'

// 创建 axios 实例（Session 认证方式）
const request = axios.create({
  baseURL: '/api',
  timeout: 10000,
  withCredentials: true  // 关键：允许携带 Cookie（Session ID）
})

// 请求拦截器（Session 方式不需要手动添加 Token）
request.interceptors.request.use(
  config => {
    // Session 方式会自动携带 Cookie，无需手动处理
    return config
  },
  error => {
    console.error('请求错误：', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
request.interceptors.response.use(
  response => {
    const res = response.data

    // 根据后端返回的状态码判断
    if (res.code !== 200) {
      // 使用全局通知系统
      if (window.$notification) {
        window.$notification.error(res.msg || '请求失败')
      }
      return Promise.reject(new Error(res.msg || '请求失败'))
    }

    return res
  },
  error => {
    console.error('响应错误：', error)
    if (window.$notification) {
      window.$notification.error(error.message || '网络错误')
    }
    return Promise.reject(error)
  }
)

export default request

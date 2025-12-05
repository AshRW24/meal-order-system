import axios from 'axios'

/**
 * ChatBot API 服务
 * 与后端 AI 客服进行交互
 */

const api = axios.create({
  baseURL: '/api',
  timeout: 30000,
  withCredentials: true // 允许跨域请求时发送 Cookie（Session）
})

/**
 * 发送消息到 AI 客服
 * @param message 用户消息
 * @param conversationId 对话ID（可选）
 * @returns AI 回复
 */
export const sendChatMessage = async (message: string, conversationId?: string) => {
  try {
    const response = await api.post('/chatbot/message', {
      message,
      conversationId
    })

    if (response.data.code === 200) {
      return {
        success: true,
        data: response.data.data
      }
    } else {
      return {
        success: false,
        error: response.data.msg || '消息发送失败'
      }
    }
  } catch (error: any) {
    console.error('发送消息失败:', error)
    return {
      success: false,
      error: error.message || '网络错误，请稍后重试'
    }
  }
}

/**
 * 检查 AI 客服状态
 * @returns 客服状态
 */
export const checkChatBotStatus = async () => {
  try {
    const response = await api.get('/chatbot/status')

    if (response.data.code === 200) {
      return {
        success: true,
        data: response.data.data
      }
    } else {
      return {
        success: false,
        error: response.data.msg || '检查失败'
      }
    }
  } catch (error: any) {
    console.error('检查客服状态失败:', error)
    return {
      success: false,
      error: error.message || '网络错误'
    }
  }
}

/**
 * 获取欢迎语
 * @returns 欢迎语
 */
export const getChatBotWelcome = async () => {
  try {
    const response = await api.get('/chatbot/welcome')

    if (response.data.code === 200) {
      return {
        success: true,
        data: response.data.data
      }
    } else {
      return {
        success: false,
        error: response.data.msg || '获取失败'
      }
    }
  } catch (error: any) {
    console.error('获取欢迎语失败:', error)
    return {
      success: false,
      error: error.message || '网络错误'
    }
  }
}

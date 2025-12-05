import request from '../utils/request'

/**
 * Get sales statistics
 */
export const getSalesStatistics = (params) => {
  return request({
    url: '/sales/statistics',
    method: 'get',
    params: {
      days: params?.days || 7,
      period: params?.period || 'day',
      ...params
    }
  })
}

/**
 * Get top selling dishes
 */
export const getTopDishes = (limit = 10) => {
  return request({
    url: '/sales/top-dishes',
    method: 'get',
    params: { limit }
  })
}

/**
 * Get sales by category
 */
export const getSalesByCategory = () => {
  return request({
    url: '/sales/by-category',
    method: 'get'
  })
}

/**
 * Get revenue trends
 */
export const getRevenueTrends = (days = 30) => {
  return request({
    url: '/sales/revenue-trends',
    method: 'get',
    params: { days }
  })
}

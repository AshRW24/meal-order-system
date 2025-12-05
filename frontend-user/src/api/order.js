import request from '../utils/request'

/**
 * 提交订单
 */
export function submitOrder(data) {
  return request({
    url: '/user/orders',
    method: 'post',
    data
  })
}

/**
 * 查询订单列表
 */
export function getOrderList() {
  return request({
    url: '/user/orders',
    method: 'get'
  })
}

/**
 * 查询订单详情
 */
export function getOrderDetail(id) {
  return request({
    url: `/user/orders/${id}`,
    method: 'get'
  })
}

/**
 * 确认收货
 */
export function confirmReceipt(id) {
  return request({
    url: `/user/orders/${id}/confirm`,
    method: 'put'
  })
}

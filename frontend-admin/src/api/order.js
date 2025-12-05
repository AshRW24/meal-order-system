import request from '../utils/request'

/**
 * 分页查询订单
 */
export function getOrderPage(params) {
  return request({
    url: '/admin/orders',
    method: 'get',
    params
  })
}

/**
 * 根据ID查询订单详情
 */
export function getOrderById(id) {
  return request({
    url: `/admin/orders/${id}`,
    method: 'get'
  })
}

/**
 * 修改订单状态
 */
export function updateOrderStatus(id, status) {
  return request({
    url: `/admin/orders/${id}/status`,
    method: 'put',
    params: { status }
  })
}

/**
 * 删除订单
 */
export function deleteOrder(id) {
  return request({
    url: `/admin/orders/${id}`,
    method: 'delete'
  })
}


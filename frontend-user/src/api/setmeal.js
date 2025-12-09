import request from '../utils/request'

/**
 * 查询在售套餐列表（用户端）
 */
export function getSetmealList(params) {
  return request({
    url: '/user/setmeals',
    method: 'get',
    params
  })
}

/**
 * 根据ID获取套餐详情（包含菜品列表）
 */
export function getSetmealDetail(id) {
  return request({
    url: `/user/setmeals/${id}`,
    method: 'get'
  })
}

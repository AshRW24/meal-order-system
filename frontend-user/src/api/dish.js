import request from '../utils/request'

/**
 * 查询在售菜品列表（用户端）
 */
export function getDishList(params) {
  return request({
    url: '/user/dishes',
    method: 'get',
    params
  })
}

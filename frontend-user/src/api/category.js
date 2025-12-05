import request from '../utils/request'

/**
 * 查询分类列表
 */
export function getCategoryList(params) {
  return request({
    url: '/user/categories',
    method: 'get',
    params
  })
}

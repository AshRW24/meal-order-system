import request from '../utils/request'

/**
 * 分页查询菜品列表
 */
export function getDishPage(params) {
  return request({
    url: '/admin/dishes',
    method: 'get',
    params
  })
}

/**
 * 根据ID查询菜品详情
 */
export function getDishById(id) {
  return request({
    url: `/admin/dishes/${id}`,
    method: 'get'
  })
}

/**
 * 新增菜品
 */
export function addDish(data) {
  return request({
    url: '/admin/dishes',
    method: 'post',
    data
  })
}

/**
 * 修改菜品
 */
export function updateDish(data) {
  return request({
    url: '/admin/dishes',
    method: 'put',
    data
  })
}

/**
 * 删除菜品
 */
export function deleteDish(id) {
  return request({
    url: `/admin/dishes/${id}`,
    method: 'delete'
  })
}

/**
 * 修改菜品状态
 */
export function updateDishStatus(id, status) {
  return request({
    url: `/admin/dishes/${id}/status`,
    method: 'put',
    params: { status }
  })
}

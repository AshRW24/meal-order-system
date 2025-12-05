import request from '../utils/request'

/**
 * 查询分类列表
 */
export function getCategoryList(params) {
  return request({
    url: '/admin/categories',
    method: 'get',
    params
  })
}

/**
 * 根据ID查询分类详情
 */
export function getCategoryById(id) {
  return request({
    url: `/admin/categories/${id}`,
    method: 'get'
  })
}

/**
 * 新增分类
 */
export function addCategory(data) {
  return request({
    url: '/admin/categories',
    method: 'post',
    data
  })
}

/**
 * 修改分类
 */
export function updateCategory(data) {
  return request({
    url: '/admin/categories',
    method: 'put',
    data
  })
}

/**
 * 删除分类
 */
export function deleteCategory(id) {
  return request({
    url: `/admin/categories/${id}`,
    method: 'delete'
  })
}

/**
 * 启用/禁用分类
 */
export function updateCategoryStatus(id, status) {
  return request({
    url: `/admin/categories/${id}/status`,
    method: 'put',
    params: { status }
  })
}

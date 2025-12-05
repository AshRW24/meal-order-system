import request from '../utils/request'

/**
 * 分页查询套餐列表
 */
export function getSetmealPage(params) {
  return request({
    url: '/admin/setmeals',
    method: 'get',
    params
  })
}

/**
 * 新增套餐
 */
export function addSetmeal(data) {
  return request({
    url: '/admin/setmeals',
    method: 'post',
    data
  })
}

/**
 * 修改套餐
 */
export function updateSetmeal(data) {
  return request({
    url: '/admin/setmeals',
    method: 'put',
    data
  })
}

/**
 * 删除套餐
 */
export function deleteSetmeal(id) {
  return request({
    url: `/admin/setmeals/${id}`,
    method: 'delete'
  })
}

/**
 * 根据ID查询套餐详情
 */
export function getSetmealById(id) {
  return request({
    url: `/admin/setmeals/${id}`,
    method: 'get'
  })
}

/**
 * 修改套餐状态
 */
export function updateSetmealStatus(id, status) {
  return request({
    url: `/admin/setmeals/${id}/status`,
    method: 'post',
    params: { status }
  })
}

import request from '../utils/request'

/**
 * 查询地址列表
 */
export function getAddressList() {
  return request({
    url: '/user/addresses',
    method: 'get'
  })
}

/**
 * 查询地址详情
 * @param {number} id - 地址ID
 */
export function getAddressById(id) {
  return request({
    url: `/user/addresses/${id}`,
    method: 'get'
  })
}

/**
 * 新增地址
 * @param {object} data - 地址信息
 */
export function addAddress(data) {
  return request({
    url: '/user/addresses',
    method: 'post',
    data
  })
}

/**
 * 更新地址
 * @param {object} data - 地址信息
 */
export function updateAddress(data) {
  return request({
    url: '/user/addresses',
    method: 'put',
    data
  })
}

/**
 * 删除地址
 * @param {number} id - 地址ID
 */
export function deleteAddress(id) {
  return request({
    url: `/user/addresses/${id}`,
    method: 'delete'
  })
}

/**
 * 设置默认地址
 * @param {number} id - 地址ID
 */
export function setDefaultAddress(id) {
  return request({
    url: `/user/addresses/${id}/default`,
    method: 'put'
  })
}

/**
 * 查询默认地址
 */
export function getDefaultAddress() {
  return request({
    url: '/user/addresses/default',
    method: 'get'
  })
}

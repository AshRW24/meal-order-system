import request from '../utils/request'

/**
 * 添加商品到购物车
 */
export function addToCart(data) {
  return request({
    url: '/user/shoppingCart',
    method: 'post',
    data
  })
}

/**
 * 查询购物车列表
 */
export function getCartList() {
  return request({
    url: '/user/shoppingCart',
    method: 'get'
  })
}

/**
 * 清空购物车
 */
export function clearCart() {
  return request({
    url: '/user/shoppingCart',
    method: 'delete'
  })
}

/**
 * 修改购物车商品数量
 */
export function updateCartQuantity(cartId, quantity) {
  return request({
    url: `/user/shoppingCart/${cartId}/quantity`,
    method: 'put',
    params: { quantity }
  })
}

/**
 * 删除购物车中的单个商品
 */
export function deleteCartItem(cartId) {
  return request({
    url: `/user/shoppingCart/${cartId}`,
    method: 'delete'
  })
}

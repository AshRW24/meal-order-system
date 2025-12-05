import request from '../utils/request'

/**
 * 用户充值
 */
export function recharge(amount) {
  return request({
    url: '/user/recharge',
    method: 'post',
    data: { amount }
  })
}

/**
 * 查询用户余额
 */
export function getBalance() {
  return request({
    url: '/user/balance',
    method: 'get'
  })
}


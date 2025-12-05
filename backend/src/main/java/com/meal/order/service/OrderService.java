package com.meal.order.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.meal.order.dto.OrderSubmitDTO;
import com.meal.order.entity.Order;

import java.util.List;

/**
 * 订单服务接口
 */
public interface OrderService {

    /**
     * 提交订单
     *
     * @param userId 用户ID
     * @param orderSubmitDTO 订单提交信息
     * @return 订单ID
     */
    Long submitOrder(Long userId, OrderSubmitDTO orderSubmitDTO);

    /**
     * 查询用户订单列表
     *
     * @param userId 用户ID
     * @return 订单列表
     */
    List<Order> listByUserId(Long userId);

    /**
     * 查询订单详情（用户）
     *
     * @param userId 用户ID
     * @param orderId 订单ID
     * @return 订单详情
     */
    Order getById(Long userId, Long orderId);

    /**
     * 根据ID查询订单（管理端）
     *
     * @param orderId 订单ID
     * @return 订单详情
     */
    Order getById(Long orderId);

    /**
     * 分页查询订单（管理端）
     *
     * @param page 当前页
     * @param pageSize 每页大小
     * @param orderNumber 订单号
     * @param userId 用户ID
     * @param status 订单状态
     * @return 订单分页数据
     */
    Page<Order> pageAdmin(Integer page, Integer pageSize, String orderNumber, Long userId, Integer status);

    /**
     * 用户确认收货
     *
     * @param userId 用户ID
     * @param orderId 订单ID
     */
    void userConfirmReceipt(Long userId, Long orderId);

    /**
     * 修改订单状态
     *
     * @param orderId 订单ID
     * @param status 新状态
     */
    void updateStatus(Long orderId, Integer status);

    /**
     * 删除订单
     *
     * @param orderId 订单ID
     */
    void deleteById(Long orderId);
}

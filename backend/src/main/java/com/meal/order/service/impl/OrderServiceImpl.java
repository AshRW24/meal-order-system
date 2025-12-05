package com.meal.order.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.meal.order.exception.BusinessException;
import com.meal.order.dto.OrderSubmitDTO;
import com.meal.order.entity.Address;
import com.meal.order.entity.Order;
import com.meal.order.entity.OrderDetail;
import com.meal.order.entity.ShoppingCart;
import com.meal.order.mapper.AddressMapper;
import com.meal.order.mapper.OrderDetailMapper;
import com.meal.order.mapper.OrderMapper;
import com.meal.order.mapper.ShoppingCartMapper;
import com.meal.order.service.OrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

/**
 * 订单服务实现类
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderMapper orderMapper;
    private final OrderDetailMapper orderDetailMapper;
    private final AddressMapper addressMapper;
    private final ShoppingCartMapper shoppingCartMapper;
    private final com.meal.order.service.UserService userService;

    private static final AtomicLong ORDER_NUMBER_SEQUENCE = new AtomicLong(0);

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Long submitOrder(Long userId, OrderSubmitDTO orderSubmitDTO) {
        log.info("提交订单，用户ID：{}，地址ID：{}", userId, orderSubmitDTO.getAddressId());

        // 1. 验证地址
        Address address = addressMapper.selectById(orderSubmitDTO.getAddressId());
        if (address == null || !address.getUserId().equals(userId)) {
            throw new BusinessException("地址不存在");
        }

        // 2. 查询购物车
        LambdaQueryWrapper<ShoppingCart> cartWrapper = new LambdaQueryWrapper<>();
        cartWrapper.eq(ShoppingCart::getUserId, userId);
        List<ShoppingCart> cartItems = shoppingCartMapper.selectList(cartWrapper);

        if (cartItems == null || cartItems.isEmpty()) {
            throw new BusinessException("购物车为空，无法下单");
        }

        // 3. 计算订单金额
        BigDecimal totalAmount = BigDecimal.ZERO;
        for (ShoppingCart item : cartItems) {
            BigDecimal itemAmount = item.getPrice().multiply(new BigDecimal(item.getQuantity()));
            totalAmount = totalAmount.add(itemAmount);
        }

        // 4. 检查余额并扣款
        userService.deductBalance(userId, totalAmount);

        // 5. 生成订单号
        String orderNumber = generateOrderNumber();

        // 6. 创建订单
        Order order = new Order();
        order.setOrderNumber(orderNumber);
        order.setUserId(userId);
        order.setAddressId(address.getId());
        order.setAmount(totalAmount);
        order.setStatus(1);  // 待确认
        order.setPayStatus(1);  // 已支付（从余额扣款）
        order.setPayTime(LocalDateTime.now());
        order.setRemark(orderSubmitDTO.getRemark());
        order.setConsignee(address.getConsignee());
        order.setPhone(address.getPhone());
        // 拼接完整地址
        String fullAddress = address.getProvince() + address.getCity() +
                            address.getDistrict() + address.getDetail();
        order.setAddress(fullAddress);
        order.setOrderTime(LocalDateTime.now());

        orderMapper.insert(order);

        // 6. 创建订单明细
        for (ShoppingCart cartItem : cartItems) {
            OrderDetail orderDetail = new OrderDetail();
            orderDetail.setOrderId(order.getId());
            orderDetail.setItemId(cartItem.getItemId());
            orderDetail.setItemName(cartItem.getItemName());
            orderDetail.setItemType(cartItem.getItemType());
            orderDetail.setPrice(cartItem.getPrice());
            orderDetail.setQuantity(cartItem.getQuantity());
            orderDetail.setAmount(cartItem.getPrice().multiply(new BigDecimal(cartItem.getQuantity())));

            orderDetailMapper.insert(orderDetail);
        }

        // 7. 清空购物车
        LambdaQueryWrapper<ShoppingCart> deleteWrapper = new LambdaQueryWrapper<>();
        deleteWrapper.eq(ShoppingCart::getUserId, userId);
        shoppingCartMapper.delete(deleteWrapper);

        log.info("订单创建成功，订单ID：{}，订单号：{}", order.getId(), orderNumber);
        return order.getId();
    }

    @Override
    public List<Order> listByUserId(Long userId) {
        log.info("查询用户订单列表，用户ID：{}", userId);

        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Order::getUserId, userId)
                .orderByDesc(Order::getOrderTime);

        return orderMapper.selectList(wrapper);
    }

    @Override
    public Order getById(Long userId, Long orderId) {
        log.info("查询订单详情，用户ID：{}，订单ID：{}", userId, orderId);

        Order order = orderMapper.selectById(orderId);
        if (order == null || !order.getUserId().equals(userId)) {
            throw new BusinessException("订单不存在");
        }

        return order;
    }

    @Override
    public Order getById(Long orderId) {
        log.info("查询订单详情，订单ID：{}", orderId);
        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }
        return order;
    }

    @Override
    public Page<Order> pageAdmin(Integer page, Integer pageSize, String orderNumber, Long userId, Integer status) {
        log.info("分页查询订单，页码：{}，大小：{}，订单号：{}，用户ID：{}，状态：{}", 
                page, pageSize, orderNumber, userId, status);

        LambdaQueryWrapper<Order> wrapper = new LambdaQueryWrapper<>();
        if (orderNumber != null && !orderNumber.isEmpty()) {
            wrapper.like(Order::getOrderNumber, orderNumber);
        }
        if (userId != null) {
            wrapper.eq(Order::getUserId, userId);
        }
        if (status != null) {
            wrapper.eq(Order::getStatus, status);
        }
        wrapper.orderByDesc(Order::getOrderTime);

        return orderMapper.selectPage(new Page<>(page, pageSize), wrapper);
    }

    @Override
    public void userConfirmReceipt(Long userId, Long orderId) {
        log.info("用户确认收货，用户ID：{}，订单ID：{}", userId, orderId);
        Order order = getById(userId, orderId);
        if (order.getStatus() != 3) { // 只有"配送中"的订单才能确认收货
            throw new BusinessException("订单状态不正确，无法确认收货");
        }
        order.setStatus(4); // 已完成
        order.setCompleteTime(LocalDateTime.now());
        orderMapper.updateById(order);
    }

    @Override
    public void updateStatus(Long orderId, Integer status) {
        log.info("修改订单状态，订单ID：{}，新状态：{}", orderId, status);

        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }

        order.setStatus(status);
        orderMapper.updateById(order);
    }

    @Override
    public void deleteById(Long orderId) {
        log.info("删除订单，订单ID：{}", orderId);

        Order order = orderMapper.selectById(orderId);
        if (order == null) {
            throw new BusinessException("订单不存在");
        }

        // 删除订单详情
        LambdaQueryWrapper<OrderDetail> detailWrapper = new LambdaQueryWrapper<>();
        detailWrapper.eq(OrderDetail::getOrderId, orderId);
        orderDetailMapper.delete(detailWrapper);

        // 删除订单
        orderMapper.deleteById(orderId);
    }

    /**
     * 生成订单号
     * 格式：时间戳(yyyyMMddHHmmss) + 4位序列号
     *
     * @return 订单号
     */
    private String generateOrderNumber() {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        long sequence = ORDER_NUMBER_SEQUENCE.incrementAndGet() % 10000;
        return timestamp + String.format("%04d", sequence);
    }
}

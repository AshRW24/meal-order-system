package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.dto.OrderSubmitDTO;
import com.meal.order.entity.Order;
import com.meal.order.service.OrderService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

/**
 * 用户端-订单管理接口
 */
@Slf4j
@RestController
@RequestMapping("/user/orders")
@RequiredArgsConstructor
@Api(tags = "用户端-订单管理接口")
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @ApiOperation("提交订单")
    public Result<Long> submitOrder(
            @ApiParam("订单提交信息") @RequestBody OrderSubmitDTO orderSubmitDTO,
            HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("提交订单，用户ID：{}，订单信息：{}", userId, orderSubmitDTO);

        Long orderId = orderService.submitOrder(userId, orderSubmitDTO);
        return Result.success(orderId);
    }

    @GetMapping
    @ApiOperation("查询订单列表")
    public Result<List<Order>> list(HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("查询订单列表，用户ID：{}", userId);

        List<Order> orders = orderService.listByUserId(userId);
        return Result.success(orders);
    }

    @GetMapping("/{id}")
    @ApiOperation("查询订单详情")
    public Result<Order> getById(
            @ApiParam("订单ID") @PathVariable Long id,
            HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("查询订单详情，用户ID：{}，订单ID：{}", userId, id);

        Order order = orderService.getById(userId, id);
        return Result.success(order);
    }

    @PutMapping("/{id}/confirm")
    @ApiOperation("确认收货")
    public Result<String> confirmReceipt(@ApiParam("订单ID") @PathVariable Long id, HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("用户确认收货，用户ID：{}，订单ID：{}", userId, id);
        orderService.userConfirmReceipt(userId, id);
        return Result.success("确认收货成功");
    }
}

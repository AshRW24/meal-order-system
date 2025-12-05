package com.meal.order.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.meal.order.common.Result;
import com.meal.order.entity.Order;
import com.meal.order.service.OrderService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

/**
 * 管理端-订单管理接口
 */
@Slf4j
@RestController
@RequestMapping("/admin/orders")
@RequiredArgsConstructor
@Api(tags = "管理端-订单管理接口")
public class AdminOrderController {

    private final OrderService orderService;

    /**
     * 分页查询订单列表
     */
    @GetMapping
    @ApiOperation("分页查询订单")
    public Result<Page<Order>> page(
            @ApiParam("当前页") @RequestParam(defaultValue = "1") Integer page,
            @ApiParam("每页大小") @RequestParam(defaultValue = "10") Integer pageSize,
            @ApiParam("订单号") @RequestParam(required = false) String orderNumber,
            @ApiParam("用户ID") @RequestParam(required = false) Long userId,
            @ApiParam("订单状态 1-待支付 2-待发货 3-已发货 4-已完成 5-已取消") @RequestParam(required = false) Integer status) {
        log.info("分页查询订单，页码：{}，大小：{}，订单号：{}，用户ID：{}，状态：{}",
                page, pageSize, orderNumber, userId, status);
        Page<Order> pageInfo = orderService.pageAdmin(page, pageSize, orderNumber, userId, status);
        return Result.success(pageInfo);
    }

    /**
     * 查询订单详情
     */
    @GetMapping("/{id}")
    @ApiOperation("查询订单详情")
    public Result<Order> getById(@ApiParam("订单ID") @PathVariable Long id) {
        log.info("查询订单详情，订单ID：{}", id);
        Order order = orderService.getById(id);
        return Result.success(order);
    }

    /**
     * 修改订单状态
     */
    @PutMapping("/{id}/status")
    @ApiOperation("修改订单状态")
    public Result<String> updateStatus(
            @ApiParam("订单ID") @PathVariable Long id,
            @ApiParam("订单状态 1-待支付 2-待发货 3-已发货 4-已完成 5-已取消") @RequestParam Integer status) {
        log.info("修改订单状态，订单ID：{}，新状态：{}", id, status);
        orderService.updateStatus(id, status);
        return Result.success("状态更新成功");
    }

    /**
     * 删除订单
     */
    @DeleteMapping("/{id}")
    @ApiOperation("删除订单")
    public Result<String> delete(@ApiParam("订单ID") @PathVariable Long id) {
        log.info("删除订单，订单ID：{}", id);
        orderService.deleteById(id);
        return Result.success("删除成功");
    }
}


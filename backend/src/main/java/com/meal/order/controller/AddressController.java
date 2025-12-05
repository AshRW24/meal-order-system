package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.entity.Address;
import com.meal.order.service.AddressService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

/**
 * 用户端-地址管理接口
 */
@Slf4j
@RestController
@RequestMapping("/user/addresses")
@RequiredArgsConstructor
@Api(tags = "用户端-地址管理接口")
public class AddressController {

    private final AddressService addressService;

    @GetMapping
    @ApiOperation("查询地址列表")
    public Result<List<Address>> list(HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("查询地址列表，用户ID：{}", userId);

        List<Address> list = addressService.listByUserId(userId);
        return Result.success(list);
    }

    @GetMapping("/{id}")
    @ApiOperation("查询地址详情")
    public Result<Address> getById(
            @ApiParam("地址ID") @PathVariable Long id,
            HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("查询地址详情，用户ID：{}，地址ID：{}", userId, id);

        Address address = addressService.getById(userId, id);
        return Result.success(address);
    }

    @PostMapping
    @ApiOperation("新增地址")
    public Result<Void> add(
            @ApiParam("地址信息") @RequestBody Address address,
            HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("新增地址，用户ID：{}，地址信息：{}", userId, address);

        addressService.add(userId, address);
        return Result.success();
    }

    @PutMapping
    @ApiOperation("更新地址")
    public Result<Void> update(
            @ApiParam("地址信息") @RequestBody Address address,
            HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("更新地址，用户ID：{}，地址信息：{}", userId, address);

        addressService.update(userId, address);
        return Result.success();
    }

    @DeleteMapping("/{id}")
    @ApiOperation("删除地址")
    public Result<Void> delete(
            @ApiParam("地址ID") @PathVariable Long id,
            HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("删除地址，用户ID：{}，地址ID：{}", userId, id);

        addressService.delete(userId, id);
        return Result.success();
    }

    @PutMapping("/{id}/default")
    @ApiOperation("设置默认地址")
    public Result<Void> setDefault(
            @ApiParam("地址ID") @PathVariable Long id,
            HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("设置默认地址，用户ID：{}，地址ID：{}", userId, id);

        addressService.setDefault(userId, id);
        return Result.success();
    }

    @GetMapping("/default")
    @ApiOperation("查询默认地址")
    public Result<Address> getDefault(HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        log.info("查询默认地址，用户ID：{}", userId);

        Address address = addressService.getDefault(userId);
        return Result.success(address);
    }
}

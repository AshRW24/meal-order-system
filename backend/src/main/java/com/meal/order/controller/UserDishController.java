package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.entity.Dish;
import com.meal.order.service.DishService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户端菜品Controller
 */
@Slf4j
@RestController
@RequestMapping("/user/dishes")
@RequiredArgsConstructor
@Api(tags = "用户端-菜品接口")
public class UserDishController {

    private final DishService dishService;

    /**
     * 根据分类ID查询在售菜品
     */
    @GetMapping
    @ApiOperation("查询在售菜品列表")
    public Result<List<Dish>> list(
            @ApiParam("分类ID（可选）") @RequestParam(required = false) Long categoryId) {
        log.info("用户端查询在售菜品，分类ID：{}", categoryId);
        List<Dish> dishes = dishService.listAvailableDishes(categoryId);
        return Result.success(dishes);
    }
}

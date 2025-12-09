package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.dto.SetmealDTO;
import com.meal.order.entity.Setmeal;
import com.meal.order.service.SetmealService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户端套餐Controller
 */
@Slf4j
@RestController
@RequestMapping("/user/setmeals")
@RequiredArgsConstructor
@Api(tags = "用户端-套餐接口")
public class UserSetmealController {

    private final SetmealService setmealService;

    /**
     * 查询在售套餐列表
     */
    @GetMapping
    @ApiOperation("查询在售套餐列表")
    public Result<List<Setmeal>> list(
            @ApiParam("分类ID（可选）") @RequestParam(required = false) Long categoryId) {
        log.info("用户端查询在售套餐，分类ID：{}", categoryId);
        List<Setmeal> setmeals = setmealService.listAvailableSetmeals(categoryId);
        return Result.success(setmeals);
    }

    /**
     * 根据ID获取套餐详情（包含菜品列表）
     */
    @GetMapping("/{id}")
    @ApiOperation("获取套餐详情")
    public Result<SetmealDTO> getDetail(
            @ApiParam("套餐ID") @PathVariable Long id) {
        log.info("用户端查询套餐详情，ID：{}", id);
        SetmealDTO setmealDTO = setmealService.getById(id);
        if (setmealDTO == null) {
            return Result.error("套餐不存在");
        }
        return Result.success(setmealDTO);
    }
}

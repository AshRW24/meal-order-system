package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.entity.Category;
import com.meal.order.service.CategoryService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 用户端分类Controller
 */
@Slf4j
@RestController
@RequestMapping("/user/categories")
@RequiredArgsConstructor
@Api(tags = "用户端-分类接口")
public class UserCategoryController {

    private final CategoryService categoryService;

    /**
     * 查询启用的分类列表
     */
    @GetMapping
    @ApiOperation("查询启用的分类列表")
    public Result<List<Category>> list(
            @ApiParam("分类类型（1-菜品分类，2-套餐分类）") @RequestParam(required = false) Integer type) {
        log.info("用户端查询分类列表，类型：{}", type);
        List<Category> categories = categoryService.listActiveCategories(type);
        return Result.success(categories);
    }
}

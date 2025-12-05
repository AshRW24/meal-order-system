package com.meal.order.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.meal.order.common.Result;
import com.meal.order.dto.DishDTO;
import com.meal.order.entity.Dish;
import com.meal.order.service.DishService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * 菜品管理Controller
 */
@Slf4j
@RestController
@RequestMapping("/admin/dishes")
@RequiredArgsConstructor
@Api(tags = "菜品管理接口")
public class DishController {

    private final DishService dishService;

    /**
     * 分页查询菜品
     */
    @GetMapping
    @ApiOperation("分页查询菜品")
    public Result<Page<Dish>> page(
            @ApiParam("当前页") @RequestParam(defaultValue = "1") Integer page,
            @ApiParam("每页大小") @RequestParam(defaultValue = "10") Integer pageSize,
            @ApiParam("分类ID") @RequestParam(required = false) Long categoryId,
            @ApiParam("菜品名称") @RequestParam(required = false) String name,
            @ApiParam("状态（1-在售，0-停售）") @RequestParam(required = false) Integer status) {
        log.info("分页查询菜品，页码：{}，大小：{}，分类ID：{}，名称：{}，状态：{}",
                 page, pageSize, categoryId, name, status);
        Page<Dish> pageInfo = dishService.page(page, pageSize, categoryId, name, status);
        return Result.success(pageInfo);
    }

    /**
     * 根据ID查询菜品
     */
    @GetMapping("/{id}")
    @ApiOperation("根据ID查询菜品")
    public Result<Dish> getById(@PathVariable Long id) {
        log.info("查询菜品详情，ID：{}", id);
        Dish dish = dishService.getById(id);
        return Result.success(dish);
    }

    /**
     * 新增菜品
     */
    @PostMapping
    @ApiOperation("新增菜品")
    public Result<String> add(@Validated @RequestBody DishDTO dishDTO) {
        log.info("新增菜品：{}", dishDTO.getName());
        dishService.add(dishDTO);
        return Result.success("菜品新增成功");
    }

    /**
     * 更新菜品
     */
    @PutMapping
    @ApiOperation("更新菜品")
    public Result<String> update(@Validated @RequestBody DishDTO dishDTO) {
        log.info("更新菜品，ID：{}", dishDTO.getId());
        dishService.update(dishDTO);
        return Result.success("菜品更新成功");
    }

    /**
     * 删除菜品
     */
    @DeleteMapping("/{id}")
    @ApiOperation("删除菜品")
    public Result<String> delete(@PathVariable Long id) {
        log.info("删除菜品，ID：{}", id);
        dishService.delete(id);
        return Result.success("菜品删除成功");
    }

    /**
     * 更新菜品状态（上下架）
     */
    @PutMapping("/{id}/status")
    @ApiOperation("更新菜品状态")
    public Result<String> updateStatus(
            @PathVariable Long id,
            @ApiParam("状态（1-在售，0-停售）") @RequestParam Integer status) {
        log.info("更新菜品状态，ID：{}，状态：{}", id, status);
        dishService.updateStatus(id, status);
        String msg = status == 1 ? "菜品已上架" : "菜品已下架";
        return Result.success(msg);
    }
}

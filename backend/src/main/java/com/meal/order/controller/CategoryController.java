package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.dto.CategoryDTO;
import com.meal.order.entity.Category;
import com.meal.order.service.CategoryService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 分类管理Controller
 */
@Slf4j
@RestController
@RequestMapping("/admin/categories")
@RequiredArgsConstructor
@Api(tags = "分类管理接口")
public class CategoryController {

    private final CategoryService categoryService;

    /**
     * 查询所有分类
     */
    @GetMapping
    @ApiOperation("查询所有分类")
    public Result<List<Category>> list(
            @ApiParam("分类类型（1-菜品分类，2-套餐分类）") @RequestParam(required = false) Integer type) {
        log.info("查询分类列表，类型：{}", type);
        List<Category> categories = categoryService.list(type);
        return Result.success(categories);
    }

    /**
     * 根据ID查询分类
     */
    @GetMapping("/{id}")
    @ApiOperation("根据ID查询分类")
    public Result<Category> getById(@PathVariable Long id) {
        log.info("查询分类详情，ID：{}", id);
        Category category = categoryService.getById(id);
        return Result.success(category);
    }

    /**
     * 新增分类
     */
    @PostMapping
    @ApiOperation("新增分类")
    public Result<String> add(@Validated @RequestBody CategoryDTO categoryDTO) {
        log.info("新增分类：{}", categoryDTO.getName());
        categoryService.add(categoryDTO);
        return Result.success("分类新增成功");
    }

    /**
     * 更新分类
     */
    @PutMapping
    @ApiOperation("更新分类")
    public Result<String> update(@Validated @RequestBody CategoryDTO categoryDTO) {
        log.info("更新分类，ID：{}", categoryDTO.getId());
        categoryService.update(categoryDTO);
        return Result.success("分类更新成功");
    }

    /**
     * 删除分类
     */
    @DeleteMapping("/{id}")
    @ApiOperation("删除分类")
    public Result<String> delete(@PathVariable Long id) {
        log.info("删除分类，ID：{}", id);
        categoryService.delete(id);
        return Result.success("分类删除成功");
    }

    /**
     * 启用/禁用分类
     */
    @PutMapping("/{id}/status")
    @ApiOperation("启用/禁用分类")
    public Result<String> updateStatus(
            @PathVariable Long id,
            @ApiParam("状态（1-启用，0-禁用）") @RequestParam Integer status) {
        log.info("更新分类状态，ID：{}，状态：{}", id, status);
        categoryService.updateStatus(id, status);
        String msg = status == 1 ? "分类已启用" : "分类已禁用";
        return Result.success(msg);
    }
}

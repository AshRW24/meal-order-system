package com.meal.order.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.meal.order.common.Result;
import com.meal.order.dto.SetmealDTO;
import com.meal.order.entity.Setmeal;
import com.meal.order.service.SetmealService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

/**
 * 套餐管理Controller
 */
@Slf4j
@RestController
@RequestMapping("/admin/setmeals")
@Api(tags = "套餐管理接口")
public class SetmealController {

    @Resource
    private SetmealService setmealService;

    /**
     * 分页查询套餐列表
     */
    @GetMapping
    @ApiOperation("分页查询套餐列表")
    public Result<Page<Setmeal>> page(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "10") int pageSize,
            @RequestParam(required = false) String name,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) Integer status,
            HttpSession session
    ) {
        // 验证登录
        if (session.getAttribute("admin") == null) {
            return Result.error("请先登录");
        }

        log.info("分页查询套餐，page={}, pageSize={}, name={}, categoryId={}, status={}",
                page, pageSize, name, categoryId, status);

        Page<Setmeal> pageResult = setmealService.page(page, pageSize, name, categoryId, status);
        return Result.success(pageResult);
    }

    /**
     * 新增套餐
     */
    @PostMapping
    @ApiOperation("新增套餐")
    public Result<String> add(@RequestBody @Validated SetmealDTO setmealDTO, HttpSession session) {
        // 验证登录
        if (session.getAttribute("admin") == null) {
            return Result.error("请先登录");
        }

        log.info("新增套餐: {}", setmealDTO);

        setmealService.add(setmealDTO);
        return Result.success("新增套餐成功");
    }

    /**
     * 修改套餐
     */
    @PutMapping
    @ApiOperation("修改套餐")
    public Result<String> update(@RequestBody @Validated SetmealDTO setmealDTO, HttpSession session) {
        // 验证登录
        if (session.getAttribute("admin") == null) {
            return Result.error("请先登录");
        }

        log.info("修改套餐: {}", setmealDTO);

        setmealService.update(setmealDTO);
        return Result.success("修改套餐成功");
    }

    /**
     * 删除套餐
     */
    @DeleteMapping("/{id}")
    @ApiOperation("删除套餐")
    public Result<String> delete(@PathVariable Long id, HttpSession session) {
        // 验证登录
        if (session.getAttribute("admin") == null) {
            return Result.error("请先登录");
        }

        log.info("删除套餐，id={}", id);

        setmealService.delete(id);
        return Result.success("删除套餐成功");
    }

    /**
     * 根据ID查询套餐详情
     */
    @GetMapping("/{id}")
    @ApiOperation("根据ID查询套餐详情")
    public Result<SetmealDTO> getById(@PathVariable Long id, HttpSession session) {
        // 验证登录
        if (session.getAttribute("admin") == null) {
            return Result.error("请先登录");
        }

        log.info("查询套餐详情，id={}", id);

        SetmealDTO setmealDTO = setmealService.getById(id);
        if (setmealDTO == null) {
            return Result.error("套餐不存在");
        }
        return Result.success(setmealDTO);
    }

    /**
     * 修改套餐状态（上下架）
     */
    @PostMapping("/{id}/status")
    @ApiOperation("修改套餐状态")
    public Result<String> updateStatus(
            @PathVariable Long id,
            @RequestParam Integer status,
            HttpSession session
    ) {
        // 验证登录
        if (session.getAttribute("admin") == null) {
            return Result.error("请先登录");
        }

        log.info("修改套餐状态，id={}, status={}", id, status);

        setmealService.updateStatus(id, status);
        String message = status == 1 ? "上架成功" : "下架成功";
        return Result.success(message);
    }
}

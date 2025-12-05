package com.meal.order.controller;

import com.meal.order.common.Result;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 测试控制器
 */
@Api(tags = "测试接口")
@RestController
@RequestMapping("/test")
public class TestController {

    @ApiOperation("测试接口")
    @GetMapping("/hello")
    public Result<String> hello() {
        return Result.success("Hello, Meal Order System!");
    }
}

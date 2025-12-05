package com.meal.order.controller;

import com.meal.order.common.Result;
import com.meal.order.dto.ShoppingCartDTO;
import com.meal.order.entity.ShoppingCart;
import com.meal.order.service.ShoppingCartService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;

/**
 * 购物车Controller
 */
@Slf4j
@RestController
@RequestMapping("/user/shoppingCart")
@RequiredArgsConstructor
@Api(tags = "用户端-购物车接口")
public class ShoppingCartController {

    private final ShoppingCartService shoppingCartService;

    /**
     * 添加商品到购物车
     */
    @PostMapping
    @ApiOperation("添加商品到购物车")
    public Result<String> add(@Validated @RequestBody ShoppingCartDTO dto, HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return Result.error("请先登录");
        }

        log.info("用户 {} 添加商品到购物车：itemId={}, itemType={}, quantity={}",
                userId, dto.getItemId(), dto.getItemType(), dto.getQuantity());

        shoppingCartService.add(userId, dto);
        return Result.success("添加成功");
    }

    /**
     * 查询购物车列表
     */
    @GetMapping
    @ApiOperation("查询购物车列表")
    public Result<List<ShoppingCart>> list(HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return Result.error("请先登录");
        }

        log.info("用户 {} 查询购物车列表", userId);

        List<ShoppingCart> cartList = shoppingCartService.list(userId);
        return Result.success(cartList);
    }

    /**
     * 清空购物车
     */
    @DeleteMapping
    @ApiOperation("清空购物车")
    public Result<String> clear(HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return Result.error("请先登录");
        }

        log.info("用户 {} 清空购物车", userId);

        shoppingCartService.clear(userId);
        return Result.success("清空成功");
    }

    /**
     * 修改购物车商品数量
     */
    @PutMapping("/{cartId}/quantity")
    @ApiOperation("修改购物车商品数量")
    public Result<String> updateQuantity(@PathVariable Long cartId,
                                          @RequestParam Integer quantity,
                                          HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return Result.error("请先登录");
        }

        log.info("用户 {} 修改购物车商品数量：cartId={}, quantity={}", userId, cartId, quantity);

        shoppingCartService.updateQuantity(userId, cartId, quantity);
        return Result.success("修改成功");
    }

    /**
     * 删除购物车中的单个商品
     */
    @DeleteMapping("/{cartId}")
    @ApiOperation("删除购物车中的单个商品")
    public Result<String> deleteItem(@PathVariable Long cartId, HttpSession session) {
        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return Result.error("请先登录");
        }

        log.info("用户 {} 删除购物车商品：cartId={}", userId, cartId);

        shoppingCartService.deleteItem(userId, cartId);
        return Result.success("删除成功");
    }
}

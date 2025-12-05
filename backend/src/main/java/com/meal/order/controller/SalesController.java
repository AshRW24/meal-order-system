package com.meal.order.controller;

import com.meal.order.common.Result;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.*;

/**
 * Sales Statistics Controller
 */
@Slf4j
@RestController
@RequestMapping("/api/sales")
@Api(tags = "Sales Management")
public class SalesController {

    /**
     * Get sales statistics by date range
     * Supports daily, weekly, and monthly aggregation
     */
    @GetMapping("/statistics")
    @ApiOperation("Get sales statistics")
    public Result<Map<String, Object>> getSalesStatistics(
            @RequestParam(required = false, defaultValue = "7") Integer days,
            @RequestParam(required = false, defaultValue = "day") String period) {

        try {
            log.info("Getting sales statistics for {} days, period: {}", days, period);

            // Generate mock data for demonstration
            Map<String, Object> data = generateSalesData(days, period);

            return Result.success(data);
        } catch (Exception e) {
            log.error("Failed to get sales statistics: {}", e.getMessage());
            return Result.error("Failed to get sales statistics");
        }
    }

    /**
     * Get top selling dishes
     */
    @GetMapping("/top-dishes")
    @ApiOperation("Get top selling dishes")
    public Result<Map<String, Object>> getTopDishes(
            @RequestParam(required = false, defaultValue = "10") Integer limit) {

        try {
            log.info("Getting top {} selling dishes", limit);

            Map<String, Object> data = generateTopDishesData(limit);

            return Result.success(data);
        } catch (Exception e) {
            log.error("Failed to get top dishes: {}", e.getMessage());
            return Result.error("Failed to get top dishes");
        }
    }

    /**
     * Get sales by category
     */
    @GetMapping("/by-category")
    @ApiOperation("Get sales by category")
    public Result<Map<String, Object>> getSalesByCategory() {

        try {
            log.info("Getting sales by category");

            Map<String, Object> data = generateCategorySalesData();

            return Result.success(data);
        } catch (Exception e) {
            log.error("Failed to get category sales: {}", e.getMessage());
            return Result.error("Failed to get category sales");
        }
    }

    /**
     * Get revenue trends
     */
    @GetMapping("/revenue-trends")
    @ApiOperation("Get revenue trends")
    public Result<Map<String, Object>> getRevenueTrends(
            @RequestParam(required = false, defaultValue = "30") Integer days) {

        try {
            log.info("Getting revenue trends for {} days", days);

            Map<String, Object> data = generateRevenueTrendsData(days);

            return Result.success(data);
        } catch (Exception e) {
            log.error("Failed to get revenue trends: {}", e.getMessage());
            return Result.error("Failed to get revenue trends");
        }
    }

    // ==================== Data Generation Methods ====================

    private Map<String, Object> generateSalesData(Integer days, String period) {
        Map<String, Object> data = new HashMap<>();
        List<String> dates = new ArrayList<>();
        List<Integer> salesVolume = new ArrayList<>();
        List<Double> salesAmount = new ArrayList<>();

        // Generate dates based on period
        Calendar calendar = Calendar.getInstance();
        for (int i = days - 1; i >= 0; i--) {
            calendar.add(Calendar.DAY_OF_MONTH, -i);
            dates.add(String.format("%04d-%02d-%02d",
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH) + 1,
                calendar.get(Calendar.DAY_OF_MONTH)));

            // Mock sales data
            salesVolume.add((int)(Math.random() * 100) + 20);
            salesAmount.add(Math.random() * 5000 + 1000);
        }

        data.put("dates", dates);
        data.put("salesVolume", salesVolume);
        data.put("salesAmount", salesAmount);
        data.put("totalOrders", salesVolume.stream().mapToInt(Integer::intValue).sum());
        data.put("totalRevenue", String.format("%.2f",
            salesAmount.stream().mapToDouble(Double::doubleValue).sum()));

        return data;
    }

    private Map<String, Object> generateTopDishesData(Integer limit) {
        Map<String, Object> data = new HashMap<>();
        List<String> dishNames = new ArrayList<>();
        List<Integer> quantities = new ArrayList<>();
        List<Double> revenues = new ArrayList<>();

        String[] dishes = {"Kung Pao Chicken", "Mapo Tofu", "Sweet and Sour Pork",
                          "Fried Rice", "Chow Mein", "Hot Pot", "Dumplings",
                          "Spring Rolls", "Peking Duck", "Braised Beef"};

        for (int i = 0; i < Math.min(limit, dishes.length); i++) {
            dishNames.add(dishes[i]);
            quantities.add((int)(Math.random() * 500) + 100);
            revenues.add(Math.random() * 2000 + 500);
        }

        data.put("dishNames", dishNames);
        data.put("quantities", quantities);
        data.put("revenues", revenues);

        return data;
    }

    private Map<String, Object> generateCategorySalesData() {
        Map<String, Object> data = new HashMap<>();
        List<String> categories = Arrays.asList("Main Courses", "Appetizers",
                                               "Beverages", "Desserts", "Soups");
        List<Integer> sales = new ArrayList<>();

        for (String category : categories) {
            sales.add((int)(Math.random() * 1000) + 200);
        }

        data.put("categories", categories);
        data.put("sales", sales);

        return data;
    }

    private Map<String, Object> generateRevenueTrendsData(Integer days) {
        Map<String, Object> data = new HashMap<>();
        List<String> dates = new ArrayList<>();
        List<Double> cumulativeRevenue = new ArrayList<>();

        Calendar calendar = Calendar.getInstance();
        double cumulative = 0;

        for (int i = days - 1; i >= 0; i--) {
            calendar.add(Calendar.DAY_OF_MONTH, -i);
            dates.add(String.format("%04d-%02d-%02d",
                calendar.get(Calendar.YEAR),
                calendar.get(Calendar.MONTH) + 1,
                calendar.get(Calendar.DAY_OF_MONTH)));

            cumulative += Math.random() * 3000 + 500;
            cumulativeRevenue.add(cumulative);
        }

        data.put("dates", dates);
        data.put("cumulativeRevenue", cumulativeRevenue);
        data.put("totalRevenue", String.format("%.2f", cumulative));

        return data;
    }
}

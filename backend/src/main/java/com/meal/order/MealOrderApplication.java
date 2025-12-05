package com.meal.order;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 外卖订餐系统启动类
 */
@SpringBootApplication
@MapperScan("com.meal.order.mapper")
public class MealOrderApplication {

    public static void main(String[] args) {
        SpringApplication.run(MealOrderApplication.class, args);
        System.out.println("==============================================");
        System.out.println("外卖订餐系统启动成功");
        System.out.println("API 文档地址: http://localhost:8080/api/doc.html");
        System.out.println("==============================================");
    }
}

package com.meal.order.config;

import com.meal.order.common.JwtInterceptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Web MVC 配置
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${file.upload.path:D:/uploads}")
    private String uploadPath;

    @Autowired
    private JwtInterceptor jwtInterceptor;

    /**
     * 配置跨域
     */
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOriginPatterns("*") // 允许所有域名跨域
                .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true) // 允许携带Cookie
                .maxAge(3600);
    }

    /**
     * 配置静态资源映射
     * 将 /uploads/** 映射到实际的文件存储路径
     */
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + uploadPath + "/");
    }

    /**
     * 配置JWT拦截器
     */
    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(jwtInterceptor)
                .addPathPatterns("/**")
                // 排除不需要Token验证的路径
                .excludePathPatterns(
                        "/user/register",        // 注册接口
                        "/user/login",           // 登录接口
                        "/admin/register",       // 管理员注册
                        "/admin/login",          // 管理员登录
                        "/user/reset-password",  // 重置密码
                        "/uploads/**",           // 静态资源
                        "/swagger-ui.html",      // Swagger UI
                        "/swagger-resources/**", // Swagger资源
                        "/v2/api-docs",          // API文档
                        "/knife4j/**"            // Knife4j文档
                );
    }
}

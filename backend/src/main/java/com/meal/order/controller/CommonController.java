package com.meal.order.controller;

import com.meal.order.common.Result;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

/**
 * 通用Controller（文件上传等）
 */
@Slf4j
@RestController
@RequestMapping("/admin/common")
@Api(tags = "通用接口")
public class CommonController {

    @Value("${file.upload.path:D:/uploads}")
    private String uploadPath;

    /**
     * 文件上传
     */
    @PostMapping("/upload")
    @ApiOperation("文件上传")
    public Result<String> upload(@RequestParam("file") MultipartFile file) {
        log.info("文件上传，原始文件名：{}", file.getOriginalFilename());

        try {
            // 1. 检查文件是否为空
            if (file.isEmpty()) {
                return Result.error("上传文件不能为空");
            }

            // 2. 检查文件大小（100MB - 已取消5MB限制）
            long maxSize = 100 * 1024 * 1024;
            if (file.getSize() > maxSize) {
                return Result.error("文件大小不能超过100MB");
            }

            // 3. 检查文件类型（只允许图片）
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return Result.error("只能上传图片文件");
            }

            // 4. 获取原始文件名和扩展名
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            // 5. 生成新文件名（使用日期+UUID避免重复）
            String dateStr = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String uuid = UUID.randomUUID().toString().replace("-", "");
            String newFilename = dateStr + "_" + uuid + extension;

            // 6. 创建上传目录（按日期分组）
            String datePath = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
            File uploadDir = new File(uploadPath, datePath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // 7. 保存文件
            File destFile = new File(uploadDir, newFilename);
            file.transferTo(destFile);

            // 8. 返回文件访问路径（相对路径）
            String fileUrl = "/uploads/" + datePath + "/" + newFilename;
            log.info("文件上传成功，访问路径：{}", fileUrl);

            return Result.success(fileUrl);

        } catch (IOException e) {
            log.error("文件上传失败", e);
            return Result.error("文件上传失败：" + e.getMessage());
        }
    }
}

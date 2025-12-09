-- ============================================================
-- 餐饮订单系统数据库初始化脚本（与当前代码对齐）
-- ============================================================

-- 创建数据库（如已存在则复用）
CREATE DATABASE IF NOT EXISTS `meal_order_system`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `meal_order_system`;

-- 1. 用户表（User）
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
  `password` VARCHAR(255) NOT NULL COMMENT '密码（明文/MVP）',
  `security_question` VARCHAR(255) COMMENT '密保问题',
  `security_answer` VARCHAR(255) COMMENT '密保答案',
  `phone` VARCHAR(20) COMMENT '手机号',
  `email` VARCHAR(100) COMMENT '邮箱',
  `avatar` VARCHAR(500) COMMENT '头像URL',
  `balance` DECIMAL(10,2) DEFAULT 0.00 COMMENT '账户余额',
  `status` INT DEFAULT 1 COMMENT '状态（1-正常，0-禁用）',
  `user_type` INT DEFAULT 1 COMMENT '用户类型（1-普通用户，2-管理员）',
  `create_time` DATETIME COMMENT '创建时间',
  `update_time` DATETIME COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 2. 分类表（Category）
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` VARCHAR(100) NOT NULL COMMENT '分类名称',
  `type` INT NOT NULL COMMENT '类型（1-菜品分类，2-套餐分类）',
  `sort` INT DEFAULT 0 COMMENT '排序号',
  `status` INT DEFAULT 1 COMMENT '状态（1-启用，0-禁用）',
  `create_time` DATETIME COMMENT '创建时间',
  `update_time` DATETIME COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分类表';

-- 3. 菜品表（Dish）
DROP TABLE IF EXISTS `dish`;
CREATE TABLE `dish` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `category_id` BIGINT(20) NOT NULL COMMENT '分类ID',
  `name` VARCHAR(100) NOT NULL COMMENT '菜品名称',
  `price` DECIMAL(10,2) NOT NULL COMMENT '价格',
  `image` VARCHAR(500) COMMENT '图片URL',
  `description` VARCHAR(500) COMMENT '描述',
  `stock` INT DEFAULT 100 COMMENT '库存数量',
  `status` INT DEFAULT 1 COMMENT '状态（1-在售，0-停售）',
  `is_deleted` INT DEFAULT 0 COMMENT '逻辑删除（1-已删除，0-未删除）',
  `create_time` DATETIME COMMENT '创建时间',
  `update_time` DATETIME COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_dish_category` FOREIGN KEY (`category_id`) REFERENCES `category`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品表';

-- 4. 套餐表（Setmeal）
DROP TABLE IF EXISTS `setmeal`;
CREATE TABLE `setmeal` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `category_id` BIGINT(20) NOT NULL COMMENT '分类ID',
  `name` VARCHAR(100) NOT NULL COMMENT '套餐名称',
  `price` DECIMAL(10,2) NOT NULL COMMENT '套餐价格',
  `image` VARCHAR(500) COMMENT '图片URL',
  `description` VARCHAR(500) COMMENT '描述',
  `status` INT DEFAULT 1 COMMENT '状态（1-在售，0-停售）',
  `is_deleted` INT DEFAULT 0 COMMENT '逻辑删除（1-已删除，0-未删除）',
  `create_time` DATETIME COMMENT '创建时间',
  `update_time` DATETIME COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_setmeal_category` FOREIGN KEY (`category_id`) REFERENCES `category`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='套餐表';

-- 5. 套餐菜品关系表（SetmealDish）
DROP TABLE IF EXISTS `setmeal_dish`;
CREATE TABLE `setmeal_dish` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `setmeal_id` BIGINT(20) NOT NULL COMMENT '套餐ID',
  `dish_id` BIGINT(20) NOT NULL COMMENT '菜品ID',
  `copies` INT DEFAULT 1 COMMENT '份数',
  `create_time` DATETIME COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_setmeal_id` (`setmeal_id`),
  KEY `idx_dish_id` (`dish_id`),
  CONSTRAINT `fk_setmealdish_setmeal` FOREIGN KEY (`setmeal_id`) REFERENCES `setmeal`(`id`),
  CONSTRAINT `fk_setmealdish_dish` FOREIGN KEY (`dish_id`) REFERENCES `dish`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='套餐菜品关系表';

-- 6. 地址表（Address）
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
  `consignee` VARCHAR(50) NOT NULL COMMENT '收货人',
  `phone` VARCHAR(20) NOT NULL COMMENT '联系电话',
  `province_code` VARCHAR(12) COMMENT '省份编码',
  `province_name` VARCHAR(32) COMMENT '省份名称',
  `city_code` VARCHAR(12) COMMENT '城市编码',
  `city_name` VARCHAR(32) COMMENT '城市名称',
  `district_code` VARCHAR(12) COMMENT '区县编码',
  `district_name` VARCHAR(32) COMMENT '区县名称',
  `detail` VARCHAR(200) COMMENT '详细地址',
  `tag` VARCHAR(100) COMMENT '标签',
  `is_default` INT DEFAULT 0 COMMENT '是否默认（1-是，0-否）',
  `create_time` DATETIME COMMENT '创建时间',
  `update_time` DATETIME COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_address_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='地址表';

-- 7. 订单表（Orders）
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_number` VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号',
  `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
  `address_id` BIGINT(20) COMMENT '地址ID',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '订单金额',
  `status` INT DEFAULT 1 COMMENT '订单状态（1-待确认，2-已确认，3-配送中，4-已完成，5-已取消）',
  `pay_status` INT DEFAULT 0 COMMENT '支付状态（0-未支付，1-已支付）',
  `remark` VARCHAR(500) COMMENT '备注',
  `consignee` VARCHAR(50) COMMENT '收货人',
  `phone` VARCHAR(20) COMMENT '联系电话',
  `address` VARCHAR(200) COMMENT '收货地址',
  `order_time` DATETIME COMMENT '下单时间',
  `pay_time` DATETIME COMMENT '支付时间',
  `complete_time` DATETIME COMMENT '完成时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_number` (`order_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_order_time` (`order_time`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- 8. 订单详情表（OrderDetail）
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `order_id` BIGINT(20) NOT NULL COMMENT '订单ID',
  `dish_id` BIGINT(20) COMMENT '菜品ID',
  `setmeal_id` BIGINT(20) COMMENT '套餐ID',
  `dish_name` VARCHAR(100) NOT NULL COMMENT '菜品/套餐名称',
  `quantity` INT DEFAULT 1 COMMENT '数量',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `amount` DECIMAL(10,2) NOT NULL COMMENT '小计金额',
  `create_time` DATETIME COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  CONSTRAINT `fk_order_detail_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单详情表';

-- 9. 购物车表（ShoppingCart）——与当前后端/前端契约一致
DROP TABLE IF EXISTS `shopping_cart`;
CREATE TABLE `shopping_cart` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
  `item_type` INT NOT NULL DEFAULT 1 COMMENT '商品类型（1-菜品，2-套餐）',
  `item_id` BIGINT(20) NOT NULL COMMENT '商品ID（菜品/套餐）',
  `item_name` VARCHAR(100) COMMENT '商品名称',
  `image` VARCHAR(500) COMMENT '商品图片URL',
  `price` DECIMAL(10,2) NOT NULL COMMENT '单价',
  `quantity` INT NOT NULL DEFAULT 1 COMMENT '数量',
  `create_time` DATETIME COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  UNIQUE KEY `uk_user_item` (`user_id`,`item_type`,`item_id`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车表';

-- 索引补充
CREATE INDEX idx_orders_user_id ON `orders`(`user_id`);
CREATE INDEX idx_orders_status ON `orders`(`status`);
CREATE INDEX idx_orders_create_time ON `orders`(`order_time`);

COMMIT;

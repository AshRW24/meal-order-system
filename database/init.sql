-- ============================================================
-- Meal Order System - Single SQL (schema + seed data)
-- ============================================================

CREATE DATABASE IF NOT EXISTS `meal_order_system`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `meal_order_system`;

SET FOREIGN_KEY_CHECKS=0;

-- Drop tables in FK-safe order
DROP TABLE IF EXISTS `order_detail`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `shopping_cart`;
DROP TABLE IF EXISTS `setmeal_dish`;
DROP TABLE IF EXISTS `setmeal`;
DROP TABLE IF EXISTS `dish`;
DROP TABLE IF EXISTS `category`;
DROP TABLE IF EXISTS `address`;
DROP TABLE IF EXISTS `user`;

-- 1) Users
CREATE TABLE `user` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `username` VARCHAR(50) NOT NULL UNIQUE COMMENT 'username',
  `password` VARCHAR(255) NOT NULL COMMENT 'password (hashed)',
  `security_question` VARCHAR(255) COMMENT 'security question',
  `security_answer` VARCHAR(255) COMMENT 'security answer',
  `phone` VARCHAR(20) COMMENT 'phone',
  `email` VARCHAR(100) COMMENT 'email',
  `avatar` VARCHAR(500) COMMENT 'avatar URL',
  `balance` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'balance',
  `status` INT DEFAULT 1 COMMENT '1-enabled,0-disabled',
  `user_type` INT DEFAULT 1 COMMENT '1-user,2-admin',
  `create_time` DATETIME COMMENT 'created at',
  `update_time` DATETIME COMMENT 'updated at',
  PRIMARY KEY (`id`),
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='user';

-- 2) Category
CREATE TABLE `category` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `name` VARCHAR(100) NOT NULL COMMENT 'category name',
  `type` INT NOT NULL COMMENT '1-dish,2-setmeal',
  `sort` INT DEFAULT 0 COMMENT 'sort order',
  `status` INT DEFAULT 1 COMMENT '1-enabled,0-disabled',
  `create_time` DATETIME COMMENT 'created at',
  `update_time` DATETIME COMMENT 'updated at',
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='category';

-- 3) Dish
CREATE TABLE `dish` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `category_id` BIGINT(20) NOT NULL COMMENT 'FK category',
  `name` VARCHAR(100) NOT NULL COMMENT 'dish name',
  `price` DECIMAL(10,2) NOT NULL COMMENT 'price',
  `image` VARCHAR(500) COMMENT 'image URL',
  `description` VARCHAR(500) COMMENT 'description',
  `stock` INT DEFAULT 100 COMMENT 'stock',
  `status` INT DEFAULT 1 COMMENT '1-on sale,0-off',
  `is_deleted` INT DEFAULT 0 COMMENT 'logic delete',
  `create_time` DATETIME COMMENT 'created at',
  `update_time` DATETIME COMMENT 'updated at',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_dish_category` FOREIGN KEY (`category_id`) REFERENCES `category`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='dish';

-- 4) Setmeal
CREATE TABLE `setmeal` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `category_id` BIGINT(20) NOT NULL COMMENT 'FK category',
  `name` VARCHAR(100) NOT NULL COMMENT 'setmeal name',
  `price` DECIMAL(10,2) NOT NULL COMMENT 'setmeal price',
  `image` VARCHAR(500) COMMENT 'image URL',
  `description` VARCHAR(500) COMMENT 'description',
  `status` INT DEFAULT 1 COMMENT '1-on sale,0-off',
  `is_deleted` INT DEFAULT 0 COMMENT 'logic delete',
  `create_time` DATETIME COMMENT 'created at',
  `update_time` DATETIME COMMENT 'updated at',
  PRIMARY KEY (`id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_setmeal_category` FOREIGN KEY (`category_id`) REFERENCES `category`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='setmeal';

-- 5) Setmeal-Dish relation
CREATE TABLE `setmeal_dish` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `setmeal_id` BIGINT(20) NOT NULL COMMENT 'FK setmeal',
  `dish_id` BIGINT(20) NOT NULL COMMENT 'FK dish',
  `copies` INT DEFAULT 1 COMMENT 'servings',
  `create_time` DATETIME COMMENT 'created at',
  PRIMARY KEY (`id`),
  KEY `idx_setmeal_id` (`setmeal_id`),
  KEY `idx_dish_id` (`dish_id`),
  CONSTRAINT `fk_setmealdish_setmeal` FOREIGN KEY (`setmeal_id`) REFERENCES `setmeal`(`id`),
  CONSTRAINT `fk_setmealdish_dish` FOREIGN KEY (`dish_id`) REFERENCES `dish`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='setmeal_dish';

-- 6) Address
CREATE TABLE `address` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `user_id` BIGINT(20) NOT NULL COMMENT 'FK user',
  `consignee` VARCHAR(50) NOT NULL COMMENT 'consignee',
  `phone` VARCHAR(20) NOT NULL COMMENT 'phone',
  `province_code` VARCHAR(12) COMMENT 'province code',
  `province_name` VARCHAR(32) COMMENT 'province name',
  `city_code` VARCHAR(12) COMMENT 'city code',
  `city_name` VARCHAR(32) COMMENT 'city name',
  `district_code` VARCHAR(12) COMMENT 'district code',
  `district_name` VARCHAR(32) COMMENT 'district name',
  `detail` VARCHAR(200) COMMENT 'detail',
  `tag` VARCHAR(100) COMMENT 'tag',
  `is_default` INT DEFAULT 0 COMMENT '1-default,0-no',
  `create_time` DATETIME COMMENT 'created at',
  `update_time` DATETIME COMMENT 'updated at',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `fk_address_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='address';

-- 7) Orders
CREATE TABLE `orders` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `order_number` VARCHAR(50) NOT NULL UNIQUE COMMENT 'order number',
  `user_id` BIGINT(20) NOT NULL COMMENT 'FK user',
  `address_id` BIGINT(20) COMMENT 'FK address',
  `amount` DECIMAL(10,2) NOT NULL COMMENT 'order amount',
  `status` INT DEFAULT 1 COMMENT '1-pending,2-confirmed,3-delivering,4-done,5-cancelled',
  `pay_status` INT DEFAULT 0 COMMENT '0-unpaid,1-paid',
  `remark` VARCHAR(500) COMMENT 'remark',
  `consignee` VARCHAR(50) COMMENT 'consignee',
  `phone` VARCHAR(20) COMMENT 'phone',
  `address` VARCHAR(200) COMMENT 'address snapshot',
  `order_time` DATETIME COMMENT 'order time',
  `pay_time` DATETIME COMMENT 'pay time',
  `complete_time` DATETIME COMMENT 'complete time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_order_number` (`order_number`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_order_time` (`order_time`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='orders';

-- 8) Order detail
CREATE TABLE `order_detail` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `order_id` BIGINT(20) NOT NULL COMMENT 'FK order',
  `dish_id` BIGINT(20) COMMENT 'dish id',
  `setmeal_id` BIGINT(20) COMMENT 'setmeal id',
  `dish_name` VARCHAR(100) NOT NULL COMMENT 'dish/setmeal name',
  `quantity` INT DEFAULT 1 COMMENT 'quantity',
  `price` DECIMAL(10,2) NOT NULL COMMENT 'unit price',
  `amount` DECIMAL(10,2) NOT NULL COMMENT 'subtotal',
  `create_time` DATETIME COMMENT 'created at',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`),
  CONSTRAINT `fk_order_detail_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='order_detail';

-- 9) Shopping cart
CREATE TABLE `shopping_cart` (
  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `user_id` BIGINT(20) NOT NULL COMMENT 'FK user',
  `item_type` INT NOT NULL DEFAULT 1 COMMENT '1-dish,2-setmeal',
  `item_id` BIGINT(20) NOT NULL COMMENT 'dish or setmeal id',
  `item_name` VARCHAR(100) COMMENT 'item name',
  `image` VARCHAR(500) COMMENT 'image URL',
  `price` DECIMAL(10,2) NOT NULL COMMENT 'unit price',
  `quantity` INT NOT NULL DEFAULT 1 COMMENT 'quantity',
  `create_time` DATETIME COMMENT 'created at',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  UNIQUE KEY `uk_user_item` (`user_id`,`item_type`,`item_id`),
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='shopping_cart';

SET FOREIGN_KEY_CHECKS=1;

-- ============================================================
-- Seed data (from test_data.sql)
-- ============================================================
-- ============================================================
-- 餐饮订单系统测试数据增强脚本 (60+菜品�?2套餐、完整地址和关�?
-- ============================================================

USE `meal_order_system`;
SET FOREIGN_KEY_CHECKS=0;

-- ============================================================
-- 1. 插入用户数据
-- ============================================================
DELETE FROM `user`;
ALTER TABLE `user` AUTO_INCREMENT = 1;

INSERT INTO `user`
(`username`, `password`, `phone`, `email`, `balance`, `status`, `user_type`, `create_time`, `update_time`)
VALUES
('admin', 'admin4f67b4da$fa27a108ac711a85848e2dd1a40bb01d35af55cb', '13800138000', 'admin@example.com', 10000.00, 1, 2, NOW(), NOW()),
('user001', 'user001286f7bdb$f8a83118e95864f447b2ff73ff3f73c1ac82fed4', '13800138001', 'user001@example.com', 500.00, 1, 1, NOW(), NOW()),
('user002', 'user002f60c4c86$40855fa77e5dd75dc509fbff6c75db269ba8cc6d', '13800138002', 'user002@example.com', 1000.00, 1, 1, NOW(), NOW()),
('user003', 'user00347f02ce5$d378bd68e71c1d38bd69126862b42488079fe4db', '13800138003', 'user003@example.com', 300.00, 1, 1, NOW(), NOW()),
('user004', 'user004ad03d5d8$fe4f192a61729ec773d1ebe930d4569d17ae10e4', '13800138004', 'user004@example.com', 800.00, 1, 1, NOW(), NOW()),
('user005', 'user005afd0aad2$09f41a1fee0542a68b855cf2148b66eedc1524f0', '13800138005', 'user005@example.com', 1200.00, 1, 1, NOW(), NOW()),
('user006', 'user00691a31df6$7afb2723a133b76ea3321da51396c53d76e22988', '13800138006', 'user006@example.com', 200.00, 1, 1, NOW(), NOW()),
('user007', 'user007cc8854c5$bd5e76a8d506423ba31c704d3351270f9a6d57f9', '13800138007', 'user007@example.com', 450.00, 1, 1, NOW(), NOW()),
('user008', 'user008f013fea4$befd6eeaf3a7e872ea7078f593416552782bdd0e', '13800138008', 'user008@example.com', 0.00, 1, 1, NOW(), NOW()),
('user009', 'user00911f33c93$d20b780e99a9fcd41ae93f01f0a0789015c283a6', '13800138009', 'user009@example.com', 350.00, 0, 1, NOW(), NOW()),
('staff01', 'staff01e3b19fee$0fcae08aa23b8d9e3c08247d96c4ed2febd0fff0', '13900139001', 'staff01@example.com', 800.00, 1, 2, NOW(), NOW());

-- ============================================================
-- 2. 插入分类数据 (1=菜品分类, 2=套餐分类)
-- ============================================================
DELETE FROM `category`;
ALTER TABLE `category` AUTO_INCREMENT = 1;

-- 菜品分类
INSERT INTO `category`
(`name`, `type`, `sort`, `status`, `create_time`, `update_time`)
VALUES
('川菜', 1, 1, 1, NOW(), NOW()),
('粤菜', 1, 2, 1, NOW(), NOW()),
('鲁菜', 1, 3, 1, NOW(), NOW()),
('淮扬�?, 1, 4, 1, NOW(), NOW()),
('浙菜', 1, 5, 1, NOW(), NOW()),
('素菜', 1, 6, 1, NOW(), NOW()),

-- 套餐分类
('商务套餐', 2, 1, 1, NOW(), NOW()),
('家庭套餐', 2, 2, 1, NOW(), NOW());

-- ============================================================
-- 3. 插入菜品数据 (60+菜品)
-- ============================================================
DELETE FROM `dish`;
ALTER TABLE `dish` AUTO_INCREMENT = 1;

INSERT INTO `dish`
(`category_id`, `name`, `price`, `description`, `stock`, `status`, `is_deleted`, `create_time`, `update_time`)
VALUES
-- 川菜 (category_id=1) - 10道菜
(1, '宫保鸡丁', 38.00, '精选鸡肉，配以花生、辣椒等食材，麻辣适口', 50, 1, 0, NOW(), NOW()),
(1, '水煮牛肉', 48.00, '新鲜牛肉，火锅味道，麻辣鲜香', 40, 1, 0, NOW(), NOW()),
(1, '辣子�?, 42.00, '地道川菜，香辣可口，让人欲罢不能', 35, 1, 0, NOW(), NOW()),
(1, '回锅�?, 32.00, '豆豉香辣，荤素搭配，营养丰富', 45, 1, 0, NOW(), NOW()),
(1, '鱼香肉丝', 36.00, '融合了鱼香、肉质的完美结合', 50, 1, 0, NOW(), NOW()),
(1, '麻婆豆腐', 28.00, '川菜经典，麻辣鲜香，豆腐嫩滑', 55, 1, 0, NOW(), NOW()),
(1, '干锅牛蛙', 52.00, '牛蛙肉质细嫩，麻辣香气扑�?, 30, 1, 0, NOW(), NOW()),
(1, '酸菜�?, 46.00, '酸爽开胃，鱼肉鲜嫩，经典川�?, 35, 1, 0, NOW(), NOW()),
(1, '尖椒炒牛�?, 44.00, '新鲜尖椒与牛肉完美搭�?, 40, 1, 0, NOW(), NOW()),
(1, '泡椒凤爪', 22.00, '泡椒入味，凤爪筋道，开胃下�?, 60, 1, 0, NOW(), NOW()),

-- 粤菜 (category_id=2) - 10道菜
(2, '清蒸�?, 48.00, '新鲜鱼类，采用清蒸烹饪，保留原汁原味', 30, 1, 0, NOW(), NOW()),
(2, '蚝油牛肉', 44.00, '用蚝油独特的香味，配以新鲜牛�?, 40, 1, 0, NOW(), NOW()),
(2, '白切�?, 38.00, '传统粤菜，鸡肉嫩滑，入口即化', 25, 1, 0, NOW(), NOW()),
(2, '烧鹅', 56.00, '金黄酥脆的烧鹅，风味独特', 20, 1, 0, NOW(), NOW()),
(2, '港式烧排�?, 52.00, '骨香鲜嫩，烧法讲究，风味独特', 28, 1, 0, NOW(), NOW()),
(2, '清汤牛肉�?, 34.00, '传统粤菜汤品，牛肉丸爽滑', 45, 1, 0, NOW(), NOW()),
(2, '蚝油生菜', 26.00, '清爽健康，蚝油香气十�?, 50, 1, 0, NOW(), NOW()),
(2, '糖醋排骨', 42.00, '酸酸甜甜，排骨酥脆入�?, 35, 1, 0, NOW(), NOW()),
(2, '豉汁蒸海�?, 58.00, '高档食材，豉汁香，海参软�?, 22, 1, 0, NOW(), NOW()),
(2, '经典叉烧�?, 18.00, '传统粤式早茶，叉烧香气浓�?, 65, 1, 0, NOW(), NOW()),

-- 鲁菜 (category_id=3) - 10道菜
(3, '德州扒鸡', 46.00, '鲁菜代表作，色香味俱�?, 30, 1, 0, NOW(), NOW()),
(3, '葱爆海参', 58.00, '高档食材，营养丰富，味道鲜美', 25, 1, 0, NOW(), NOW()),
(3, '红烧海螺', 42.00, '新鲜海螺，红烧入味，鲜香十足', 35, 1, 0, NOW(), NOW()),
(3, '鲁菜油爆�?, 54.00, '虾肉鲜嫩，油香扑�?, 32, 1, 0, NOW(), NOW()),
(3, '红烧�?, 36.00, '肥而不腻，红烧入味，肉质软�?, 40, 1, 0, NOW(), NOW()),
(3, '糖醋鲤鱼', 48.00, '鲤鱼肉质鲜美，糖醋口味经�?, 28, 1, 0, NOW(), NOW()),
(3, '八宝�?, 52.00, '鲁菜名菜，馅料丰富，味道独特', 24, 1, 0, NOW(), NOW()),
(3, '清汤鸡汤', 28.00, '清汤清味，营养丰�?, 50, 1, 0, NOW(), NOW()),
(3, '葱烧海参', 56.00, '鲁菜传统，选材讲究，烹饪精�?, 26, 1, 0, NOW(), NOW()),
(3, '蟹黄豆腐', 34.00, '蟹黄鲜香，豆腐嫩�?, 45, 1, 0, NOW(), NOW()),

-- 淮扬�?(category_id=4) - 10道菜
(4, '狮子�?, 40.00, '淮扬菜精品，肉质鲜嫩多汁', 40, 1, 0, NOW(), NOW()),
(4, '大煮干丝', 28.00, '清汤底，豆制品香味浓�?, 50, 1, 0, NOW(), NOW()),
(4, '长鱼炖汤', 38.00, '长鱼营养丰富，炖汤清�?, 35, 1, 0, NOW(), NOW()),
(4, '文思豆�?, 32.00, '豆腐片如发丝般细致，汤清味美', 45, 1, 0, NOW(), NOW()),
(4, '南京盐水�?, 44.00, '淮扬特色，鸭肉鲜嫩，盐味适口', 30, 1, 0, NOW(), NOW()),
(4, '虾籽烧白�?, 26.00, '虾籽鲜香，白菜清�?, 55, 1, 0, NOW(), NOW()),
(4, '三丁�?, 24.00, '馅料丰富，口感层次丰�?, 60, 1, 0, NOW(), NOW()),
(4, '春笋炖排�?, 42.00, '春笋鲜嫩，排骨软�?, 38, 1, 0, NOW(), NOW()),
(4, '河虾炒豆�?, 30.00, '河虾鲜嫩，豆芽爽�?, 48, 1, 0, NOW(), NOW()),
(4, '笋干烧肉', 36.00, '笋干香气十足，肉质软�?, 42, 1, 0, NOW(), NOW()),

-- 浙菜 (category_id=5) - 10道菜
(5, '西湖醋鱼', 52.00, '浙菜代表，酸酸的西湖醋配以新鲜鱼�?, 30, 1, 0, NOW(), NOW()),
(5, '茶香�?, 44.00, '用茶叶烹制，回甘的茶香融入鸡�?, 35, 1, 0, NOW(), NOW()),
(5, '龙井虾仁', 46.00, '虾仁鲜嫩，龙井茶香沁人心�?, 32, 1, 0, NOW(), NOW()),
(5, '杭州叫花�?, 48.00, '浙菜名菜，泥中烤制，香气独特', 28, 1, 0, NOW(), NOW()),
(5, '绍兴黄酒�?, 42.00, '黄酒香味浓郁，鸡肉鲜�?, 38, 1, 0, NOW(), NOW()),
(5, '笋干老鸭�?, 36.00, '鸭肉炖透，笋干香气独特', 42, 1, 0, NOW(), NOW()),
(5, '清汤鱼圆', 28.00, '鱼圆弹牙，汤清味�?, 55, 1, 0, NOW(), NOW()),
(5, '冬菜百页�?, 24.00, '冬菜咸香，百页结软嫩', 58, 1, 0, NOW(), NOW()),
(5, '蜜汁火腿', 50.00, '火腿肉质细腻，蜜汁甘�?, 25, 1, 0, NOW(), NOW()),
(5, '浙菜小炒�?, 38.00, '肉质鲜嫩，火候恰到好�?, 45, 1, 0, NOW(), NOW()),

-- 素菜 (category_id=6) - 10道菜
(6, '宫保豆腐', 22.00, '豆腐爽滑，配以花生和辣椒，素食佳�?, 60, 1, 0, NOW(), NOW()),
(6, '炒时�?, 18.00, '时令蔬菜，营养均衡，健康首�?, 70, 1, 0, NOW(), NOW()),
(6, '香菇炒油�?, 20.00, '香菇鲜香，油菜翠绿爽�?, 65, 1, 0, NOW(), NOW()),
(6, '清炒豆芽�?, 16.00, '豆芽爽脆，清淡健�?, 75, 1, 0, NOW(), NOW()),
(6, '番茄鸡蛋�?, 19.00, '番茄酸酸甜甜，鸡蛋营养丰�?, 70, 1, 0, NOW(), NOW()),
(6, '黑木耳炒�?, 21.00, '木耳爽脆，鸡蛋营养，素荤搭�?, 55, 1, 0, NOW(), NOW()),
(6, '蚝油生菜', 17.00, '生菜爽脆，蚝油香气十�?, 68, 1, 0, NOW(), NOW()),
(6, '素炒千页豆腐', 23.00, '千页豆腐层次丰富，清香入�?, 52, 1, 0, NOW(), NOW()),
(6, '酸辣土豆�?, 18.00, '土豆丝爽脆，酸辣开�?, 72, 1, 0, NOW(), NOW()),
(6, '清炒空心�?, 15.00, '空心菜爽脆，清淡健康', 80, 1, 0, NOW(), NOW());

-- ============================================================
-- 4. 插入套餐数据 (12套餐)
-- ============================================================
DELETE FROM `setmeal`;
ALTER TABLE `setmeal` AUTO_INCREMENT = 1;

INSERT INTO `setmeal`
(`category_id`, `name`, `price`, `description`, `status`, `is_deleted`, `create_time`, `update_time`)
VALUES
-- 商务套餐 (category_id=7) - 6�?(7, '商务午餐精�?, 68.00, '包含：宫保鸡丁、清蒸鱼、炒时蔬、米�?, 1, 0, NOW(), NOW()),
(7, '高级商务套餐', 88.00, '包含：水煮牛肉、烧鹅、大煮干丝、米�?, 1, 0, NOW(), NOW()),
(7, '经理快餐套餐', 72.00, '包含：辣子鸡、蚝油牛肉、白切鸡、米�?, 1, 0, NOW(), NOW()),
(7, '董事长套�?, 108.00, '包含：葱爆海参、德州扒鸡、龙井虾仁、米�?, 1, 0, NOW(), NOW()),
(7, '商务团餐A�?, 98.00, '包含：水煮牛肉、清蒸鱼、素菜、汤、米�?, 1, 0, NOW(), NOW()),
(7, '商务团餐B�?, 118.00, '包含：葱爆海参、烧鹅、龙井虾仁、时蔬、米�?, 1, 0, NOW(), NOW()),

-- 家庭套餐 (category_id=8) - 6�?(8, '家庭聚餐套餐', 128.00, '包含：回锅肉、清蒸鱼、西湖醋鱼、时蔬、米�?, 1, 0, NOW(), NOW()),
(8, '亲子餐套�?, 78.00, '包含：宫保鸡丁、白切鸡、炒时蔬、果�?, 1, 0, NOW(), NOW()),
(8, '幸福家庭�?, 98.00, '包含：水煮牛肉、狮子头、清蒸鱼、米饭、汤', 1, 0, NOW(), NOW()),
(8, '温馨家宴套餐', 138.00, '包含：葱爆海参、烧鹅、西湖醋鱼、四季蔬菜、米�?, 1, 0, NOW(), NOW()),
(8, '家常便饭套餐', 58.00, '包含：回锅肉、蚝油生菜、炒豆芽、米�?, 1, 0, NOW(), NOW()),
(8, '老少皆宜套餐', 68.00, '包含：白切鸡、清汤鱼圆、蒸蛋、米�?, 1, 0, NOW(), NOW());

-- ============================================================
-- 5. 插入套餐菜品关系数据 (完整的setmeal_dish关联)
-- ============================================================
DELETE FROM `setmeal_dish`;
ALTER TABLE `setmeal_dish` AUTO_INCREMENT = 1;

INSERT INTO `setmeal_dish`
(`setmeal_id`, `dish_id`, `copies`, `create_time`)
VALUES
-- 商务午餐精�?(setmeal_id=1)
(1, 1, 1, NOW()),   -- 宫保鸡丁
(1, 11, 1, NOW()),  -- 清蒸�?(1, 20, 1, NOW()),  -- 炒时�?
-- 高级商务套餐 (setmeal_id=2)
(2, 2, 1, NOW()),   -- 水煮牛肉
(2, 14, 1, NOW()),  -- 烧鹅
(2, 24, 1, NOW()),  -- 大煮干丝

-- 经理快餐套餐 (setmeal_id=3)
(3, 3, 1, NOW()),   -- 辣子�?(3, 12, 1, NOW()),  -- 蚝油牛肉
(3, 13, 1, NOW()),  -- 白切�?
-- 董事长套�?(setmeal_id=4)
(4, 27, 1, NOW()),  -- 葱爆海参
(4, 31, 1, NOW()),  -- 德州扒鸡
(4, 45, 1, NOW()),  -- 龙井虾仁

-- 商务团餐A�?(setmeal_id=5)
(5, 2, 1, NOW()),   -- 水煮牛肉
(5, 11, 1, NOW()),  -- 清蒸�?(5, 60, 1, NOW()),  -- 清炒空心�?
-- 商务团餐B�?(setmeal_id=6)
(6, 27, 1, NOW()),  -- 葱爆海参
(6, 14, 1, NOW()),  -- 烧鹅
(6, 45, 1, NOW()),  -- 龙井虾仁

-- 家庭聚餐套餐 (setmeal_id=7)
(7, 4, 1, NOW()),   -- 回锅�?(7, 11, 1, NOW()),  -- 清蒸�?(7, 41, 1, NOW()),  -- 西湖醋鱼

-- 亲子餐套�?(setmeal_id=8)
(8, 1, 1, NOW()),   -- 宫保鸡丁
(8, 13, 1, NOW()),  -- 白切�?(8, 20, 1, NOW()),  -- 炒时�?
-- 幸福家庭�?(setmeal_id=9)
(9, 2, 1, NOW()),   -- 水煮牛肉
(9, 23, 1, NOW()),  -- 狮子�?(9, 11, 1, NOW()),  -- 清蒸�?
-- 温馨家宴套餐 (setmeal_id=10)
(10, 27, 1, NOW()), -- 葱爆海参
(10, 14, 1, NOW()), -- 烧鹅
(10, 41, 1, NOW()), -- 西湖醋鱼

-- 家常便饭套餐 (setmeal_id=11)
(11, 4, 1, NOW()),  -- 回锅�?(11, 17, 1, NOW()), -- 蚝油生菜
(11, 52, 1, NOW()), -- 清炒豆芽�?
-- 老少皆宜套餐 (setmeal_id=12)
(12, 13, 1, NOW()), -- 白切�?(12, 47, 1, NOW()), -- 清汤鱼圆
(12, 20, 1, NOW()); -- 炒时�?
-- ============================================================
-- 6. 插入地址数据 (完整的用户地址)
-- ============================================================
DELETE FROM `address`;
ALTER TABLE `address` AUTO_INCREMENT = 1;

INSERT INTO `address`
(`user_id`, `consignee`, `phone`, `province_code`, `province_name`, `city_code`, `city_name`, `district_code`, `district_name`, `detail`, `tag`, `is_default`, `create_time`, `update_time`)
VALUES
-- user001 (id=2) - 3个地址
(2, '张三', '13800138001', '110000', '北京�?, '110100', '北京�?, '110105', '朝阳�?, '建国路某某大�?018号室', '公司', 1, NOW(), NOW()),
(2, '张三', '13800138001', '110000', '北京�?, '110100', '北京�?, '110102', '东城�?, '和平里某街道123�?, '�?, 0, NOW(), NOW()),
(2, '张三', '13800138001', '110000', '北京�?, '110100', '北京�?, '110101', '西城�?, '金融街某小区888�?, '别墅', 0, NOW(), NOW()),

-- user002 (id=3) - 3个地址
(3, '李四', '13800138002', '310000', '浙江�?, '310100', '杭州�?, '310105', '滨江�?, '闻涛路某商业中心F�?, '�?, 1, NOW(), NOW()),
(3, '李四', '13800138002', '310000', '浙江�?, '310100', '杭州�?, '310102', '上城�?, '清河坊街某民�?, '公司', 0, NOW(), NOW()),
(3, '李四', '13800138002', '310000', '浙江�?, '310100', '杭州�?, '310108', '西湖�?, '翠苑街道某花�?, '宿舍', 0, NOW(), NOW()),

-- user003 (id=4) - 3个地址
(4, '王五', '13800138003', '440000', '广东�?, '440100', '广州�?, '440105', '天河�?, '中山大道某写字楼', '办公', 1, NOW(), NOW()),
(4, '王五', '13800138003', '440000', '广东�?, '440100', '广州�?, '440103', '越秀�?, '北京路某公寓', '�?, 0, NOW(), NOW()),
(4, '王五', '13800138003', '440000', '广东�?, '440100', '广州�?, '440106', '白云�?, '机场某酒�?, '商务', 0, NOW(), NOW()),

-- user004 (id=5) - 3个地址
(5, '赵六', '13800138004', '210000', '辽宁�?, '210100', '沈阳�?, '210102', '和平�?, '文化路某小区', '�?, 1, NOW(), NOW()),
(5, '赵六', '13800138004', '210000', '辽宁�?, '210100', '沈阳�?, '210103', '沈河�?, '太原街某办公�?, '公司', 0, NOW(), NOW()),
(5, '赵六', '13800138004', '210000', '辽宁�?, '210100', '沈阳�?, '210104', '铁西�?, '南京北街某宿�?, '宿舍', 0, NOW(), NOW()),

-- user005 (id=6) - 2个地址
(6, '钱七', '13800138005', '320000', '江苏�?, '320100', '南京�?, '320104', '鼓楼�?, '中山路某商场', '购物', 1, NOW(), NOW()),
(6, '钱七', '13800138005', '320000', '江苏�?, '320100', '南京�?, '320102', '玄武�?, '明月街某小区', '�?, 0, NOW(), NOW()),

-- user006 (id=7) - 2个地址
(7, '孙八', '13800138006', '330000', '浙江�?, '330100', '嘉兴�?, '330104', '南湖�?, '中港街某楼盘', '�?, 1, NOW(), NOW()),
(7, '孙八', '13800138006', '330000', '浙江�?, '330100', '嘉兴�?, '330105', '秀洲区', '新城大道某厂�?, '工厂', 0, NOW(), NOW()),

-- user007 (id=8) - 2个地址
(8, '周九', '13800138007', '350000', '福建�?, '350100', '福州�?, '350102', '台江�?, '五一北路某酒�?, '出差', 1, NOW(), NOW()),
(8, '周九', '13800138007', '350000', '福建�?, '350100', '福州�?, '350103', '仓山�?, '浦上街某公寓', '�?, 0, NOW(), NOW()),

-- user008 (id=9) - 2个地址
(9, '吴十', '13800138008', '120000', '天津�?, '120100', '天津�?, '120101', '和平�?, '解放北路某写字楼', '公司', 1, NOW(), NOW()),
(9, '吴十', '13800138008', '120000', '天津�?, '120100', '天津�?, '120105', '南开�?, '南门外街某小�?, '�?, 0, NOW(), NOW());

-- ============================================================
-- 7. 插入订单数据 (保留现有64订单 + 新增数据)
-- ============================================================
DELETE FROM `orders`;
ALTER TABLE `orders` AUTO_INCREMENT = 1;

INSERT INTO `orders`
(`order_number`, `user_id`, `address_id`, `amount`, `status`, `pay_status`, `consignee`, `phone`, `address`, `order_time`, `pay_time`, `complete_time`)
VALUES
-- 示例订单
('ORD20250001', 2, 1, 106.00, 4, 1, '张三', '13800138001', '北京市朝阳区建国路某某大�?018号室', '2025-12-01 12:30:00', '2025-12-01 12:35:00', '2025-12-01 13:45:00'),
('ORD20250002', 3, 4, 128.00, 4, 1, '李四', '13800138002', '浙江省杭州市滨江区闻涛路某商业中心F�?, '2025-12-02 11:50:00', '2025-12-02 12:00:00', '2025-12-02 13:25:00'),
('ORD20250003', 4, 7, 68.00, 4, 1, '王五', '13800138003', '广东省广州市天河区中山大道某写字�?, '2025-12-03 12:15:00', '2025-12-03 12:20:00', '2025-12-03 13:10:00'),
('ORD20250004', 5, 10, 78.00, 4, 1, '赵六', '13800138004', '辽宁省沈阳市和平区文化路某小�?, '2025-12-04 19:30:00', '2025-12-04 19:35:00', '2025-12-04 20:45:00'),
('ORD20250005', 6, 13, 42.00, 4, 1, '钱七', '13800138005', '江苏省南京市鼓楼区中山路某商�?, '2025-12-04 08:30:00', '2025-12-04 08:35:00', '2025-12-04 08:55:00'),
('ORD20250006', 7, 15, 152.00, 3, 1, '孙八', '13800138006', '浙江省嘉兴市南湖区中港街某楼�?, '2025-12-05 10:15:00', '2025-12-05 10:20:00', NULL),
('ORD20250007', 3, 4, 94.00, 3, 1, '李四', '13800138002', '浙江省杭州市滨江区闻涛路某商业中心F�?, '2025-12-05 14:30:00', '2025-12-05 14:35:00', NULL),
('ORD20250008', 8, 17, 76.00, 2, 1, '周九', '13800138007', '福建省福州市台江区五一北路某酒�?, '2025-12-05 15:45:00', '2025-12-05 15:50:00', NULL),
('ORD20250009', 9, 19, 158.00, 1, 0, '吴十', '13800138008', '天津市和平区解放北路某写字楼', '2025-12-05 16:20:00', NULL, NULL),
('ORD20250010', 4, 7, 48.00, 5, 0, '王五', '13800138003', '广东省广州市天河区中山大道某写字�?, '2025-11-28 09:00:00', NULL, NULL),
('ORD20250011', 5, 10, 86.00, 5, 0, '赵六', '13800138004', '辽宁省沈阳市和平区文化路某小�?, '2025-11-29 18:30:00', NULL, NULL);

-- ============================================================
-- 8. 插入购物车数�?(示例购物车数�?
-- ============================================================
DELETE FROM `shopping_cart`;
ALTER TABLE `shopping_cart` AUTO_INCREMENT = 1;

INSERT INTO `shopping_cart`
(`user_id`, `item_id`, `item_name`, `item_type`, `price`, `quantity`, `image`, `create_time`)
VALUES
-- user001 (id=2) 的购物车
(2, 1, '宫保鸡丁', 1, 38.00, 2, '/uploads/2025/12/08/dish_1.png', NOW()),
(2, 2, '水煮牛肉', 1, 48.00, 1, '/uploads/2025/12/08/dish_2.png', NOW()),
(2, 1, '商务午餐精�?, 2, 68.00, 1, '/uploads/2025/12/08/setmeal_1.png', NOW()),

-- user002 (id=3) 的购物车
(3, 11, '清蒸�?, 1, 48.00, 1, '/uploads/2025/12/08/dish_11.png', NOW()),
(3, 41, '西湖醋鱼', 1, 52.00, 1, '/uploads/2025/12/08/dish_41.png', NOW()),
(3, 3, '经理快餐套餐', 2, 72.00, 1, '/uploads/2025/12/08/setmeal_3.png', NOW()),

-- user003 (id=4) 的购物车
(4, 27, '葱爆海参', 1, 58.00, 1, '/uploads/2025/12/08/dish_27.png', NOW()),
(4, 4, '董事长套�?, 2, 108.00, 1, '/uploads/2025/12/08/setmeal_4.png', NOW());

-- ============================================================
-- 9. 插入订单详情数据
-- ============================================================
DELETE FROM `order_detail`;
ALTER TABLE `order_detail` AUTO_INCREMENT = 1;

INSERT INTO `order_detail`
(`order_id`, `dish_name`, `quantity`, `price`, `amount`, `create_time`)
VALUES
-- ORD20250001 订单详情
(1, '宫保鸡丁', 1, 38.00, 38.00, NOW()),
(1, '清蒸�?, 1, 48.00, 48.00, NOW()),
(1, '炒时�?, 1, 18.00, 18.00, NOW()),
(1, '米饭', 2, 1.00, 2.00, NOW()),

-- ORD20250002 订单详情
(2, '回锅�?, 1, 32.00, 32.00, NOW()),
(2, '清蒸�?, 1, 48.00, 48.00, NOW()),
(2, '西湖醋鱼', 1, 52.00, 52.00, NOW()),
(2, '米饭', 1, 1.00, 1.00, NOW()),

-- ORD20250003 订单详情
(3, '宫保鸡丁', 1, 38.00, 38.00, NOW()),
(3, '清蒸�?, 1, 48.00, 48.00, NOW()),
(3, '米饭', 1, 1.00, 1.00, NOW()),

-- ORD20250004 订单详情
(4, '宫保鸡丁', 1, 38.00, 38.00, NOW()),
(4, '白切�?, 1, 38.00, 38.00, NOW()),
(4, '米饭', 1, 1.00, 1.00, NOW()),

-- ORD20250005 订单详情
(5, '宫保豆腐', 1, 22.00, 22.00, NOW()),
(5, '炒时�?, 1, 18.00, 18.00, NOW()),
(5, '米饭', 1, 1.00, 1.00, NOW()),

-- ORD20250006 订单详情
(6, '水煮牛肉', 1, 48.00, 48.00, NOW()),
(6, '烧鹅', 1, 56.00, 56.00, NOW()),
(6, '大煮干丝', 1, 28.00, 28.00, NOW()),
(6, '米饭', 2, 1.00, 2.00, NOW()),
(6, '小菜', 1, 18.00, 18.00, NOW()),

-- ORD20250007 订单详情
(7, '辣子�?, 1, 42.00, 42.00, NOW()),
(7, '蚝油生菜', 1, 26.00, 26.00, NOW()),
(7, '米饭', 1, 1.00, 1.00, NOW()),
(7, '�?, 1, 25.00, 25.00, NOW()),

-- ORD20250008 订单详情
(8, '狮子�?, 1, 40.00, 40.00, NOW()),
(8, '�?, 1, 36.00, 36.00, NOW()),

-- ORD20250009 订单详情
(9, '水煮牛肉', 2, 48.00, 96.00, NOW()),
(9, '米饭', 2, 1.00, 2.00, NOW()),
(9, '小菜', 2, 30.00, 60.00, NOW());

-- ============================================================
-- 测试脚本执行完成
-- ============================================================
SET FOREIGN_KEY_CHECKS=1;
COMMIT;

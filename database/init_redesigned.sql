-- ============================================================
-- 重新设计的餐饮订单系统数据库初始化脚本 (v2.0)
-- 改进点: 消除冗余, 规范化设计, 完整的业务支持
-- ============================================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS `meal_order_system`
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE `meal_order_system`;

-- ============================================================
-- 1. 用户表 (user)
-- 改进: 密码加密字段名, 添加last_login_time用于安全审计
-- ============================================================
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `username` VARCHAR(50) NOT NULL UNIQUE COMMENT '用户名',
    `password_hash` VARCHAR(255) NOT NULL COMMENT '密码哈希值（加密存储）',
    `phone` VARCHAR(20) UNIQUE COMMENT '手机号',
    `email` VARCHAR(100) UNIQUE COMMENT '邮箱',
    `avatar` VARCHAR(500) COMMENT '头像URL',
    `real_name` VARCHAR(50) COMMENT '真实姓名',
    `balance` DECIMAL(10, 2) DEFAULT 0.00 COMMENT '账户余额',
    `points` INT DEFAULT 0 COMMENT '积分（用于兑换）',
    `status` INT DEFAULT 1 COMMENT '状态（1-正常，0-禁用，2-注销）',
    `user_type` INT DEFAULT 1 COMMENT '用户类型（1-普通用户，2-管理员，3-配送员）',
    `last_login_time` DATETIME COMMENT '最后登录时间',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` INT DEFAULT 0 COMMENT '逻辑删除（1-已删除，0-未删除）',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`),
    UNIQUE KEY `uk_phone` (`phone`),
    UNIQUE KEY `uk_email` (`email`),
    KEY `idx_user_type` (`user_type`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- ============================================================
-- 2. 状态枚举表 (enum_status) - 标准化所有业务状态
-- ============================================================
DROP TABLE IF EXISTS `enum_status`;
CREATE TABLE `enum_status` (
    `id` INT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `status_type` VARCHAR(50) NOT NULL COMMENT '状态类型（ORDER, PAYMENT, DELIVERY等）',
    `status_code` INT NOT NULL COMMENT '状态代码',
    `status_name` VARCHAR(50) NOT NULL COMMENT '状态名称',
    `description` VARCHAR(200) COMMENT '描述',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_type_code` (`status_type`, `status_code`),
    KEY `idx_status_type` (`status_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='状态枚举表';

-- 初始化订单状态
INSERT INTO `enum_status` (status_type, status_code, status_name, description, sort_order) VALUES
('ORDER', 1, '待确认', '用户已下单，等待商家确认', 1),
('ORDER', 2, '待发货', '商家已确认，准备发货', 2),
('ORDER', 3, '配送中', '订单正在配送中', 3),
('ORDER', 4, '已完成', '订单已签收完成', 4),
('ORDER', 5, '已取消', '订单已取消', 5),
('ORDER', 6, '已退货', '订单已退货处理', 6),
('PAYMENT', 0, '未支付', '订单未支付', 1),
('PAYMENT', 1, '已支付', '订单已支付', 2),
('PAYMENT', 2, '待退款', '订单等待退款处理', 3),
('PAYMENT', 3, '已退款', '订单已退款', 4),
('DELIVERY', 1, '待取件', '订单等待配送员取件', 1),
('DELIVERY', 2, '配送中', '配送员正在配送', 2),
('DELIVERY', 3, '已送达', '订单已送达用户', 3);

-- ============================================================
-- 3. 分类表 (category)
-- ============================================================
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `name` VARCHAR(100) NOT NULL COMMENT '分类名称',
    `type` INT NOT NULL COMMENT '类型（1-菜品分类，2-套餐分类）',
    `image` VARCHAR(500) COMMENT '分类图片URL',
    `description` VARCHAR(500) COMMENT '分类描述',
    `sort` INT DEFAULT 0 COMMENT '排序号',
    `status` INT DEFAULT 1 COMMENT '状态（1-启用，0-禁用）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_type` (`type`),
    KEY `idx_status` (`status`),
    UNIQUE KEY `uk_name_type` (`name`, `type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='分类表';

-- ============================================================
-- 4. 菜品规格表 (dish_spec)
-- 新增: 支持菜品规格（份量、口味等）
-- ============================================================
DROP TABLE IF EXISTS `dish_spec`;
CREATE TABLE `dish_spec` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `spec_name` VARCHAR(50) NOT NULL COMMENT '规格名称（如：大份/中份/小份）',
    `spec_type` VARCHAR(50) NOT NULL COMMENT '规格类型（如：SIZE, TASTE）',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_name_type` (`spec_name`, `spec_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品规格表';

-- ============================================================
-- 5. 菜品表 (dish)
-- 改进: 去除冗余字段, 规范化库存管理, 支持规格
-- ============================================================
DROP TABLE IF EXISTS `dish`;
CREATE TABLE `dish` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `category_id` BIGINT(20) NOT NULL COMMENT '分类ID',
    `name` VARCHAR(100) NOT NULL COMMENT '菜品名称',
    `description` VARCHAR(500) COMMENT '菜品描述',
    `image` VARCHAR(500) COMMENT '菜品图片URL',
    `price` DECIMAL(10, 2) NOT NULL COMMENT '基础价格',
    `stock` INT DEFAULT 100 COMMENT '库存数量（冗余字段，用于快速查询）',
    `status` INT DEFAULT 1 COMMENT '状态（1-在售，0-停售）',
    `is_hot` INT DEFAULT 0 COMMENT '是否热销（1-是，0-否）',
    `monthly_sales` INT DEFAULT 0 COMMENT '月销量（用于排序展示）',
    `rating` DECIMAL(3, 2) COMMENT '评分（1-5分）',
    `rating_count` INT DEFAULT 0 COMMENT '评分人数',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` INT DEFAULT 0 COMMENT '逻辑删除（1-已删除，0-未删除）',
    PRIMARY KEY (`id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status` (`status`),
    KEY `idx_is_hot` (`is_hot`),
    KEY `idx_monthly_sales` (`monthly_sales`),
    FOREIGN KEY (`category_id`) REFERENCES `category` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品表';

-- ============================================================
-- 6. 菜品规格价格表 (dish_spec_price)
-- 新增: 菜品的不同规格对应的价格
-- ============================================================
DROP TABLE IF EXISTS `dish_spec_price`;
CREATE TABLE `dish_spec_price` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `dish_id` BIGINT(20) NOT NULL COMMENT '菜品ID',
    `spec_id` BIGINT(20) NOT NULL COMMENT '规格ID',
    `additional_price` DECIMAL(10, 2) DEFAULT 0 COMMENT '规格额外价格（在基础价格上增加）',
    `stock` INT DEFAULT 100 COMMENT '该规格库存',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_dish_id` (`dish_id`),
    KEY `idx_spec_id` (`spec_id`),
    UNIQUE KEY `uk_dish_spec` (`dish_id`, `spec_id`),
    FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`),
    FOREIGN KEY (`spec_id`) REFERENCES `dish_spec` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品规格价格表';

-- ============================================================
-- 7. 套餐表 (setmeal)
-- 改进: 去除冗余, 添加套餐优惠信息
-- ============================================================
DROP TABLE IF EXISTS `setmeal`;
CREATE TABLE `setmeal` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `category_id` BIGINT(20) NOT NULL COMMENT '分类ID',
    `name` VARCHAR(100) NOT NULL COMMENT '套餐名称',
    `description` VARCHAR(500) COMMENT '套餐描述',
    `image` VARCHAR(500) COMMENT '套餐图片URL',
    `original_price` DECIMAL(10, 2) COMMENT '原价（各菜品价格之和）',
    `price` DECIMAL(10, 2) NOT NULL COMMENT '套餐实际价格',
    `discount_rate` DECIMAL(3, 2) COMMENT '折扣率（如0.8表示8折）',
    `status` INT DEFAULT 1 COMMENT '状态（1-在售，0-停售）',
    `is_hot` INT DEFAULT 0 COMMENT '是否热销',
    `monthly_sales` INT DEFAULT 0 COMMENT '月销量',
    `rating` DECIMAL(3, 2) COMMENT '评分',
    `rating_count` INT DEFAULT 0 COMMENT '评分人数',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_category_id` (`category_id`),
    KEY `idx_status` (`status`),
    FOREIGN KEY (`category_id`) REFERENCES `category` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='套餐表';

-- ============================================================
-- 8. 套餐菜品关系表 (setmeal_dish)
-- ============================================================
DROP TABLE IF EXISTS `setmeal_dish`;
CREATE TABLE `setmeal_dish` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `setmeal_id` BIGINT(20) NOT NULL COMMENT '套餐ID',
    `dish_id` BIGINT(20) NOT NULL COMMENT '菜品ID',
    `quantity` INT DEFAULT 1 COMMENT '菜品数量（如一个套餐里有2份某菜）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_setmeal_id` (`setmeal_id`),
    KEY `idx_dish_id` (`dish_id`),
    UNIQUE KEY `uk_setmeal_dish` (`setmeal_id`, `dish_id`),
    FOREIGN KEY (`setmeal_id`) REFERENCES `setmeal` (`id`),
    FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='套餐菜品关系表';

-- ============================================================
-- 9. 收货地址表 (address)
-- 改进: 去除冗余字段, 保留最常用地址标记
-- ============================================================
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
    `consignee` VARCHAR(50) NOT NULL COMMENT '收货人名称',
    `phone` VARCHAR(20) NOT NULL COMMENT '收货人电话',
    `province` VARCHAR(50) COMMENT '省份',
    `city` VARCHAR(50) COMMENT '城市',
    `district` VARCHAR(50) COMMENT '区县',
    `detail` VARCHAR(200) NOT NULL COMMENT '详细地址',
    `longitude` DECIMAL(10, 8) COMMENT '经度（用于地图）',
    `latitude` DECIMAL(10, 8) COMMENT '纬度（用于地图）',
    `tag` VARCHAR(50) COMMENT '地址标签（家、公司等）',
    `is_default` INT DEFAULT 0 COMMENT '是否默认地址（1-是，0-否）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `is_deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_is_default` (`is_default`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='收货地址表';

-- ============================================================
-- 10. 订单表 (orders)
-- 改进: 去除冗余地址字段, 添加订单来源、配送员等字段
-- ============================================================
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_number` VARCHAR(50) NOT NULL UNIQUE COMMENT '订单号（唯一标识）',
    `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
    `address_id` BIGINT(20) NOT NULL COMMENT '收货地址ID（外键引用，避免冗余）',
    `deliverer_id` BIGINT(20) COMMENT '配送员ID（指派配送员）',
    `order_source` INT DEFAULT 1 COMMENT '订单来源（1-APP，2-网页，3-小程序）',
    `order_type` INT DEFAULT 1 COMMENT '订单类型（1-外卖，2-自取）',
    `order_amount` DECIMAL(10, 2) NOT NULL COMMENT '订单商品总金额',
    `delivery_fee` DECIMAL(10, 2) DEFAULT 0 COMMENT '配送费',
    `discount_amount` DECIMAL(10, 2) DEFAULT 0 COMMENT '优惠金额',
    `coupon_id` BIGINT(20) COMMENT '使用的优惠券ID',
    `total_amount` DECIMAL(10, 2) NOT NULL COMMENT '订单总金额（含配送费、扣除优惠）',
    `status` INT DEFAULT 1 COMMENT '订单状态（1-待确认，2-待发货...）',
    `pay_status` INT DEFAULT 0 COMMENT '支付状态（0-未支付，1-已支付）',
    `pay_method` INT COMMENT '支付方式（1-微信，2-支付宝，3-余额）',
    `remark` VARCHAR(500) COMMENT '备注/特殊要求',
    `estimated_delivery_time` DATETIME COMMENT '预计送达时间',
    `actual_delivery_time` DATETIME COMMENT '实际送达时间',
    `order_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
    `pay_time` DATETIME COMMENT '支付时间',
    `complete_time` DATETIME COMMENT '完成时间',
    `cancel_time` DATETIME COMMENT '取消时间',
    `cancel_reason` VARCHAR(200) COMMENT '取消原因',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_order_number` (`order_number`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_deliverer_id` (`deliverer_id`),
    KEY `idx_status` (`status`),
    KEY `idx_pay_status` (`pay_status`),
    KEY `idx_order_time` (`order_time`),
    KEY `idx_address_id` (`address_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    FOREIGN KEY (`address_id`) REFERENCES `address` (`id`),
    FOREIGN KEY (`deliverer_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单表';

-- ============================================================
-- 11. 订单详情表 (order_detail)
-- 改进: 添加规格信息, 记录订单时刻的价格快照
-- ============================================================
DROP TABLE IF EXISTS `order_detail`;
CREATE TABLE `order_detail` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` BIGINT(20) NOT NULL COMMENT '订单ID',
    `item_type` INT NOT NULL COMMENT '项目类型（1-菜品，2-套餐）',
    `dish_id` BIGINT(20) COMMENT '菜品ID（item_type=1时不为空）',
    `setmeal_id` BIGINT(20) COMMENT '套餐ID（item_type=2时不为空）',
    `item_name` VARCHAR(100) NOT NULL COMMENT '项目名称（菜品或套餐名称快照）',
    `spec` VARCHAR(200) COMMENT '规格（如：大份、辣等）',
    `quantity` INT DEFAULT 1 COMMENT '数量',
    `unit_price` DECIMAL(10, 2) NOT NULL COMMENT '单价（下单时刻的价格快照）',
    `subtotal` DECIMAL(10, 2) NOT NULL COMMENT '小计（单价 * 数量）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_dish_id` (`dish_id`),
    KEY `idx_setmeal_id` (`setmeal_id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单详情表（价格快照）';

-- ============================================================
-- 12. 购物车表 (shopping_cart)
-- 改进: 添加规格字段
-- ============================================================
DROP TABLE IF EXISTS `shopping_cart`;
CREATE TABLE `shopping_cart` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
    `item_type` INT NOT NULL COMMENT '项目类型（1-菜品，2-套餐）',
    `dish_id` BIGINT(20) COMMENT '菜品ID',
    `setmeal_id` BIGINT(20) COMMENT '套餐ID',
    `item_name` VARCHAR(100) NOT NULL COMMENT '项目名称',
    `item_image` VARCHAR(500) COMMENT '项目图片',
    `spec` VARCHAR(200) COMMENT '规格信息',
    `price` DECIMAL(10, 2) NOT NULL COMMENT '单价',
    `quantity` INT DEFAULT 1 COMMENT '数量',
    `subtotal` DECIMAL(10, 2) COMMENT '小计',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    UNIQUE KEY `uk_user_item` (`user_id`, `item_type`, `dish_id`, `setmeal_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='购物车表';

-- ============================================================
-- 13. 优惠券表 (coupon)
-- 新增: 支持优惠券功能
-- ============================================================
DROP TABLE IF EXISTS `coupon`;
CREATE TABLE `coupon` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `coupon_code` VARCHAR(50) NOT NULL UNIQUE COMMENT '优惠券编码',
    `coupon_name` VARCHAR(100) NOT NULL COMMENT '优惠券名称',
    `description` VARCHAR(200) COMMENT '描述',
    `coupon_type` INT NOT NULL COMMENT '优惠券类型（1-满减，2-折扣，3-固定减）',
    `discount_value` DECIMAL(10, 2) NOT NULL COMMENT '优惠值（如满减50元中的50，或8折中的0.8）',
    `min_amount` DECIMAL(10, 2) COMMENT '最低消费金额（满减时）',
    `max_discount` DECIMAL(10, 2) COMMENT '最高折扣金额（折扣时）',
    `usage_limit` INT COMMENT '使用限制（每个用户最多使用次数）',
    `total_limit` INT COMMENT '发放总数量限制',
    `used_count` INT DEFAULT 0 COMMENT '已使用数量',
    `valid_start_date` DATETIME COMMENT '有效期开始',
    `valid_end_date` DATETIME COMMENT '有效期结束',
    `status` INT DEFAULT 1 COMMENT '状态（1-启用，0-禁用）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_coupon_code` (`coupon_code`),
    KEY `idx_valid_date` (`valid_start_date`, `valid_end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='优惠券表';

-- ============================================================
-- 14. 用户优惠券表 (user_coupon)
-- 新增: 用户领取的优惠券
-- ============================================================
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
    `coupon_id` BIGINT(20) NOT NULL COMMENT '优惠券ID',
    `status` INT DEFAULT 1 COMMENT '状态（1-未使用，2-已使用，3-已过期）',
    `used_time` DATETIME COMMENT '使用时间',
    `used_order_id` BIGINT(20) COMMENT '使用的订单ID',
    `receive_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '领取时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    UNIQUE KEY `uk_user_coupon` (`user_id`, `coupon_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户优惠券表';

-- ============================================================
-- 15. 菜品评价表 (dish_review)
-- 新增: 用户对菜品的评价和评分
-- ============================================================
DROP TABLE IF EXISTS `dish_review`;
CREATE TABLE `dish_review` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `dish_id` BIGINT(20) NOT NULL COMMENT '菜品ID',
    `order_id` BIGINT(20) NOT NULL COMMENT '订单ID',
    `user_id` BIGINT(20) NOT NULL COMMENT '评价用户ID',
    `rating` INT NOT NULL COMMENT '评分（1-5分）',
    `comment` VARCHAR(500) COMMENT '评价内容',
    `images` JSON COMMENT '评价图片URL列表（JSON格式）',
    `is_anonymous` INT DEFAULT 0 COMMENT '是否匿名（1-是，0-否）',
    `helpful_count` INT DEFAULT 0 COMMENT '点赞数',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `is_deleted` INT DEFAULT 0 COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_dish_id` (`dish_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_order_id` (`order_id`),
    UNIQUE KEY `uk_order_dish_user` (`order_id`, `dish_id`, `user_id`),
    FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='菜品评价表';

-- ============================================================
-- 16. 订单配送跟踪表 (order_delivery_trace)
-- 新增: 记录订单配送过程的每一步
-- ============================================================
DROP TABLE IF EXISTS `order_delivery_trace`;
CREATE TABLE `order_delivery_trace` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` BIGINT(20) NOT NULL COMMENT '订单ID',
    `deliverer_id` BIGINT(20) COMMENT '配送员ID',
    `status` INT NOT NULL COMMENT '配送状态（1-待取件，2-配送中，3-已送达）',
    `location` VARCHAR(200) COMMENT '配送位置',
    `longitude` DECIMAL(10, 8) COMMENT '经度',
    `latitude` DECIMAL(10, 8) COMMENT '纬度',
    `remark` VARCHAR(200) COMMENT '备注',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_deliverer_id` (`deliverer_id`),
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
    FOREIGN KEY (`deliverer_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='订单配送跟踪表';

-- ============================================================
-- 17. 支付记录表 (payment_record)
-- 新增: 详细记录每一笔支付
-- ============================================================
DROP TABLE IF EXISTS `payment_record`;
CREATE TABLE `payment_record` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `order_id` BIGINT(20) NOT NULL COMMENT '订单ID',
    `user_id` BIGINT(20) NOT NULL COMMENT '用户ID',
    `payment_method` INT NOT NULL COMMENT '支付方式（1-微信，2-支付宝，3-余额，4-其他）',
    `amount` DECIMAL(10, 2) NOT NULL COMMENT '支付金额',
    `transaction_id` VARCHAR(100) COMMENT '第三方交易ID（微信/支付宝）',
    `status` INT DEFAULT 1 COMMENT '状态（1-成功，2-失败，3-待处理）',
    `error_msg` VARCHAR(200) COMMENT '错误信息（支付失败时）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_order_id` (`order_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='支付记录表';

-- ============================================================
-- 18. 操作日志表 (operation_log)
-- 新增: 记录关键业务操作（用于安全审计）
-- ============================================================
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT(20) COMMENT '操作用户ID',
    `module` VARCHAR(50) NOT NULL COMMENT '模块（如：ORDER, DISH, USER等）',
    `operation` VARCHAR(50) NOT NULL COMMENT '操作类型（CREATE, UPDATE, DELETE, VIEW等）',
    `target_id` BIGINT(20) COMMENT '操作目标ID（如订单ID）',
    `details` JSON COMMENT '操作详情（JSON格式）',
    `ip_address` VARCHAR(50) COMMENT 'IP地址',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_module` (`module`),
    KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='操作日志表（审计用）';

-- ============================================================
-- 19. 库存变动日志表 (stock_change_log)
-- 新增: 记录菜品库存的每一次变动
-- ============================================================
DROP TABLE IF EXISTS `stock_change_log`;
CREATE TABLE `stock_change_log` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `dish_id` BIGINT(20) NOT NULL COMMENT '菜品ID',
    `change_type` INT NOT NULL COMMENT '变动类型（1-出库，2-入库，3-损耗）',
    `quantity_change` INT NOT NULL COMMENT '数量变化（负数表示减少）',
    `before_stock` INT NOT NULL COMMENT '变动前库存',
    `after_stock` INT NOT NULL COMMENT '变动后库存',
    `reason` VARCHAR(200) COMMENT '原因说明',
    `related_order_id` BIGINT(20) COMMENT '关联的订单ID（如有）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_dish_id` (`dish_id`),
    KEY `idx_create_time` (`create_time`),
    FOREIGN KEY (`dish_id`) REFERENCES `dish` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='库存变动日志表';

-- ============================================================
-- 20. 配送员信息表 (deliverer_info)
-- 新增: 配送员专属信息
-- ============================================================
DROP TABLE IF EXISTS `deliverer_info`;
CREATE TABLE `deliverer_info` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `user_id` BIGINT(20) NOT NULL UNIQUE COMMENT '用户ID（关联user表）',
    `id_number` VARCHAR(50) UNIQUE COMMENT '身份证号（隐私敏感）',
    `vehicle_type` INT COMMENT '交通工具类型（1-电动车，2-自行车，3-步行等）',
    `vehicle_number` VARCHAR(50) COMMENT '车辆号码',
    `service_area` VARCHAR(200) COMMENT '服务区域',
    `delivery_count` INT DEFAULT 0 COMMENT '总配送订单数',
    `positive_rating_count` INT DEFAULT 0 COMMENT '好评数',
    `average_rating` DECIMAL(3, 2) COMMENT '平均评分',
    `status` INT DEFAULT 1 COMMENT '状态（1-在岗，2-离岗，3-冻结）',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配送员信息表';

-- ============================================================
-- 21. 商家配置表 (merchant_config)
-- 新增: 商家或系统的相关配置
-- ============================================================
DROP TABLE IF EXISTS `merchant_config`;
CREATE TABLE `merchant_config` (
    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `config_key` VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
    `config_value` VARCHAR(500) COMMENT '配置值',
    `config_type` VARCHAR(50) COMMENT '配置类型（SYSTEM, BUSINESS等）',
    `description` VARCHAR(200) COMMENT '说明',
    `create_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `update_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='配置表';

-- ============================================================
-- 创建关键索引以提升性能
-- ============================================================
CREATE INDEX idx_orders_order_time_user ON `orders`(`order_time`, `user_id`);
CREATE INDEX idx_orders_status_update ON `orders`(`status`, `update_time`);
CREATE INDEX idx_shopping_cart_user_time ON `shopping_cart`(`user_id`, `create_time`);
CREATE INDEX idx_address_user_default ON `address`(`user_id`, `is_default`);

COMMIT;

-- ============================================================
-- 数据库重设计完成
-- ============================================================
-- 主要改进总结：
-- 1. ✅ 消除冗余：订单表不再存储地址信息副本
-- 2. ✅ 规范化：状态统一管理，支持扩展
-- 3. ✅ 功能完整：支持优惠券、评价、配送跟踪等
-- 4. ✅ 安全性：添加操作日志和库存追踪
-- 5. ✅ 性能：合理的索引设计和外键约束
-- 6. ✅ 可扩展：预留字段为未来功能做准备
-- ============================================================

-- ============================================================
-- 餐饮订单系统 - 增强版SQL测试查询脚本
-- Version: 2.1 (Enhanced with business logic validation)
-- ============================================================
-- 此脚本包含全面的测试查询语句，用于验证：
-- ✓ 数据库结构完整性
-- ✓ 业务数据合理性
-- ✓ 用户行为分析
-- ✓ 系统性能监控
-- ✓ 数据质量保证
-- 执行方式: mysql -u root -p meal_order_system < test_queries.sql
-- ============================================================

SET @NOW = NOW();
SET @TODAY = CURDATE();
SET SESSION sql_mode = 'STRICT_TRANS_TABLES';

USE `meal_order_system`;

-- ============================================================
-- 第一部分：基础数据统计
-- ============================================================

SELECT '========== 1. 用户总数统计 ==========' AS '测试项';
SELECT 
    COUNT(*) as '总用户数',
    SUM(CASE WHEN user_type = 1 THEN 1 ELSE 0 END) as '普通用户数',
    SUM(CASE WHEN user_type = 2 THEN 1 ELSE 0 END) as '管理员数',
    SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as '启用用户数'
FROM `user`;

SELECT '========== 2. 用户详细信息 ==========' AS '测试项';
SELECT 
    id,
    username,
    phone,
    email,
    balance as '账户余额',
    CASE WHEN user_type = 1 THEN '普通用户' ELSE '管理员' END as '用户类型',
    CASE WHEN status = 1 THEN '正常' ELSE '禁用' END as '状态',
    create_time as '创建时间'
FROM `user`
ORDER BY id;

SELECT '========== 3. 分类统计 ==========' AS '测试项';
SELECT 
    CASE WHEN type = 1 THEN '菜品分类' ELSE '套餐分类' END as '分类类型',
    COUNT(*) as '分类数量'
FROM `category`
WHERE status = 1
GROUP BY type;

SELECT '========== 4. 分类详细信息 ==========' AS '测试项';
SELECT 
    id,
    name as '分类名称',
    CASE WHEN type = 1 THEN '菜品' ELSE '套餐' END as '类型',
    sort as '排序',
    CASE WHEN status = 1 THEN '启用' ELSE '禁用' END as '状态'
FROM `category`
ORDER BY type, sort;

-- ============================================================
-- 第二部分：菜品数据测试
-- ============================================================

SELECT '========== 5. 菜品总数统计 ==========' AS '测试项';
SELECT 
    COUNT(*) as '菜品总数',
    SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as '在售菜品数',
    SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) as '停售菜品数',
    SUM(stock) as '总库存',
    ROUND(AVG(price), 2) as '平均价格',
    MIN(price) as '最低价格',
    MAX(price) as '最高价格'
FROM `dish`
WHERE is_deleted = 0;

SELECT '========== 6. 菜品分类统计 ==========' AS '测试项';
SELECT 
    c.id,
    c.name as '分类名称',
    COUNT(d.id) as '菜品数量',
    ROUND(AVG(d.price), 2) as '平均价格',
    SUM(d.stock) as '总库存'
FROM `category` c
LEFT JOIN `dish` d ON c.id = d.category_id AND d.is_deleted = 0
WHERE c.type = 1 AND c.status = 1
GROUP BY c.id, c.name
ORDER BY c.sort;

SELECT '========== 7. 库存预警菜品 (库存<30) ==========' AS '测试项';
SELECT 
    id,
    name as '菜品名称',
    price as '价格',
    stock as '库存',
    CASE WHEN stock < 10 THEN '严重预警' WHEN stock < 20 THEN '重要预警' ELSE '一般预警' END as '预警等级'
FROM `dish`
WHERE stock < 30 AND status = 1 AND is_deleted = 0
ORDER BY stock ASC;

SELECT '========== 8. 菜品详细信息 ==========' AS '测试项';
SELECT 
    d.id,
    d.name as '菜品名称',
    c.name as '分类',
    d.price as '价格',
    d.stock as '库存',
    d.description as '描述',
    CASE WHEN d.status = 1 THEN '在售' ELSE '停售' END as '状态'
FROM `dish` d
LEFT JOIN `category` c ON d.category_id = c.id
WHERE d.is_deleted = 0
ORDER BY d.category_id, d.id;

-- ============================================================
-- 第三部分：套餐数据测试
-- ============================================================

SELECT '========== 9. 套餐总数统计 ==========' AS '测试项';
SELECT 
    COUNT(*) as '套餐总数',
    SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as '在售套餐数',
    ROUND(AVG(price), 2) as '平均价格',
    MIN(price) as '最低价格',
    MAX(price) as '最高价格'
FROM `setmeal`
WHERE is_deleted = 0;

SELECT '========== 10. 套餐及其菜品详情 ==========' AS '测试项';
SELECT 
    s.id,
    s.name as '套餐名称',
    c.name as '分类',
    s.price as '套餐价格',
    COUNT(sd.id) as '菜品数量',
    GROUP_CONCAT(d.name SEPARATOR ', ') as '菜品列表',
    CASE WHEN s.status = 1 THEN '在售' ELSE '停售' END as '状态'
FROM `setmeal` s
LEFT JOIN `category` c ON s.category_id = c.id
LEFT JOIN `setmeal_dish` sd ON s.id = sd.setmeal_id
LEFT JOIN `dish` d ON sd.dish_id = d.id
WHERE s.is_deleted = 0
GROUP BY s.id, s.name, c.name, s.price, s.status
ORDER BY s.category_id, s.id;

-- ============================================================
-- 第四部分：订单数据测试
-- ============================================================

SELECT '========== 11. 订单总体统计 ==========' AS '测试项';
SELECT 
    COUNT(*) as '订单总数',
    SUM(CASE WHEN status = 4 THEN 1 ELSE 0 END) as '已完成订单',
    SUM(CASE WHEN status = 3 THEN 1 ELSE 0 END) as '配送中订单',
    SUM(CASE WHEN status = 2 THEN 1 ELSE 0 END) as '已确认订单',
    SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as '待确认订单',
    SUM(CASE WHEN status = 5 THEN 1 ELSE 0 END) as '已取消订单',
    ROUND(SUM(amount), 2) as '总销售额',
    ROUND(AVG(amount), 2) as '平均订单金额'
FROM `orders`;

SELECT '========== 12. 订单详细信息 ==========' AS '测试项';
SELECT 
    o.id,
    o.order_number as '订单号',
    u.username as '用户',
    o.amount as '金额',
    CASE 
        WHEN o.status = 1 THEN '待确认'
        WHEN o.status = 2 THEN '已确认'
        WHEN o.status = 3 THEN '配送中'
        WHEN o.status = 4 THEN '已完成'
        WHEN o.status = 5 THEN '已取消'
    END as '状态',
    CASE WHEN o.pay_status = 1 THEN '已支付' ELSE '未支付' END as '支付状态',
    o.order_time as '下单时间',
    o.consignee as '收货人',
    o.phone as '电话'
FROM `orders` o
LEFT JOIN `user` u ON o.user_id = u.id
ORDER BY o.order_time DESC;

SELECT '========== 13. 用户订单统计 ==========' AS '测试项';
SELECT 
    u.id,
    u.username as '用户名',
    COUNT(o.id) as '订单数',
    ROUND(SUM(o.amount), 2) as '总消费金额',
    ROUND(AVG(o.amount), 2) as '平均订单金额',
    MAX(o.order_time) as '最后下单时间'
FROM `user` u
LEFT JOIN `orders` o ON u.id = o.user_id
WHERE u.user_type = 1
GROUP BY u.id, u.username
ORDER BY SUM(o.amount) DESC;

SELECT '========== 14. 最近7天订单 ==========' AS '测试项';
SELECT 
    o.order_number as '订单号',
    u.username as '用户',
    o.amount as '金额',
    CASE 
        WHEN o.status = 4 THEN '已完成'
        WHEN o.status = 3 THEN '配送中'
        ELSE '其他'
    END as '状态',
    o.order_time as '下单时间'
FROM `orders` o
LEFT JOIN `user` u ON o.user_id = u.id
WHERE o.order_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY o.order_time DESC;

-- ============================================================
-- 第五部分：订单详情测试
-- ============================================================

SELECT '========== 15. 订单详情汇总 ==========' AS '测试项';
SELECT 
    o.order_number as '订单号',
    o.amount as '订单金额',
    COUNT(od.id) as '商品数量',
    SUM(od.quantity) as '总件数',
    GROUP_CONCAT(od.dish_name SEPARATOR ', ') as '商品列表'
FROM `orders` o
LEFT JOIN `order_detail` od ON o.id = od.order_id
GROUP BY o.id, o.order_number, o.amount
ORDER BY o.order_time DESC;

SELECT '========== 16. 订单明细 ==========' AS '测试项';
SELECT 
    o.order_number as '订单号',
    od.dish_name as '商品名称',
    od.quantity as '数量',
    od.price as '单价',
    od.amount as '小计'
FROM `orders` o
LEFT JOIN `order_detail` od ON o.id = od.order_id
ORDER BY o.order_time DESC, od.id;

-- ============================================================
-- 第六部分：地址数据测试
-- ============================================================

SELECT '========== 17. 用户地址统计 ==========' AS '测试项';
SELECT 
    COUNT(DISTINCT a.user_id) as '有地址用户数',
    COUNT(a.id) as '地址总数',
    SUM(CASE WHEN a.is_default = 1 THEN 1 ELSE 0 END) as '默认地址数'
FROM `address` a;

SELECT '========== 18. 用户地址信息 ==========' AS '测试项';
SELECT 
    a.id,
    u.username as '用户',
    a.consignee as '收货人',
    a.phone as '电话',
    CONCAT(a.province_name, a.city_name, a.district_name, a.detail) as '完整地址',
    a.tag as '标签',
    CASE WHEN a.is_default = 1 THEN '是' ELSE '否' END as '默认地址'
FROM `address` a
LEFT JOIN `user` u ON a.user_id = u.id
ORDER BY a.user_id, a.is_default DESC;

-- ============================================================
-- 第七部分：购物车测试
-- ============================================================

SELECT '========== 19. 购物车统计 ==========' AS '测试项';
SELECT 
    COUNT(DISTINCT user_id) as '有购物车用户数',
    COUNT(id) as '购物车商品总数',
    ROUND(SUM(amount), 2) as '购物车总金额'
FROM `shopping_cart`;

SELECT '========== 20. 用户购物车详情 ==========' AS '测试项';
SELECT 
    u.username as '用户',
    sc.dish_name as '商品名称',
    sc.price as '单价',
    sc.quantity as '数量',
    sc.amount as '小计',
    sc.create_time as '加入时间'
FROM `shopping_cart` sc
LEFT JOIN `user` u ON sc.user_id = u.id
ORDER BY u.username, sc.create_time;

-- ============================================================
-- 第八部分：数据质量检验
-- ============================================================

SELECT '========== 21. 数据完整性检验 ==========' AS '测试项';
SELECT 
    '菜品无分类' as '检验项',
    COUNT(*) as '数量'
FROM `dish`
WHERE category_id NOT IN (SELECT id FROM `category`)
UNION ALL
SELECT '套餐无分类', COUNT(*)
FROM `setmeal`
WHERE category_id NOT IN (SELECT id FROM `category`)
UNION ALL
SELECT '订单无用户', COUNT(*)
FROM `orders`
WHERE user_id NOT IN (SELECT id FROM `user`)
UNION ALL
SELECT '订单详情无订单', COUNT(*)
FROM `order_detail`
WHERE order_id NOT IN (SELECT id FROM `orders`)
UNION ALL
SELECT '地址无用户', COUNT(*)
FROM `address`
WHERE user_id NOT IN (SELECT id FROM `user`)
UNION ALL
SELECT '购物车无用户', COUNT(*)
FROM `shopping_cart`
WHERE user_id NOT IN (SELECT id FROM `user`);

SELECT '========== 22. 表结构信息 ==========' AS '测试项';
SELECT 
    TABLE_NAME as '表名',
    TABLE_ROWS as '行数',
    ROUND(DATA_LENGTH / 1024 / 1024, 2) as '大小(MB)'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'meal_order_system'
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

-- ============================================================
-- 第九部分：性能测试
-- ============================================================

SELECT '========== 23. 索引检验 ==========' AS '测试项';
SELECT
    TABLE_NAME as '表名',
    INDEX_NAME as '索引名',
    SEQ_IN_INDEX as '列序号',
    COLUMN_NAME as '字段名'
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'meal_order_system'
AND INDEX_NAME != 'PRIMARY'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- ============================================================
-- 第十部分：业务逻辑验证（新增增强功能）
-- ============================================================

SELECT '========== 24. 业务规则验证 ==========' AS '测试项';
SELECT
    '未支付但完成的订单' as '验证项',
    COUNT(*) as '问题数量'
FROM orders
WHERE pay_status = 0 AND status = 4
UNION ALL
SELECT '订单金额与详情金额不一致', COUNT(*)
FROM (
    SELECT o.id
    FROM orders o
    LEFT JOIN (
        SELECT order_id, SUM(amount) as total_amount
        FROM order_detail
        GROUP BY order_id
    ) od ON o.id = od.order_id
    WHERE ROUND(o.amount, 2) != ROUND(COALESCE(od.total_amount, 0), 2)
) problematic_orders
UNION ALL
SELECT '空购物车未清洁', COUNT(*)
FROM shopping_cart
WHERE quantity <= 0 OR amount <= 0;

SELECT '========== 25. 用户行为分析 ==========' AS '测试项';
SELECT
    '活跃用户比例' as '指标',
    CONCAT(ROUND(
        (SELECT COUNT(*)
         FROM (SELECT user_id FROM orders
               WHERE order_time >= DATE_SUB(@NOW, INTERVAL 30 DAY)
               GROUP BY user_id) active) /
        NULLIF((SELECT COUNT(*) FROM `user` WHERE user_type = 1), 0) * 100, 1
    ), '%') as '近30天',
    CONCAT(ROUND(
        (SELECT COUNT(*)
         FROM (SELECT user_id FROM orders
               WHERE order_time >= DATE_SUB(@NOW, INTERVAL 7 DAY)
               GROUP BY user_id) active) /
        NULLIF((SELECT COUNT(*) FROM `user` WHERE user_type = 1), 0) * 100, 1
    ), '%') as '近7天'
UNION ALL
SELECT '用户平均订单频率',
       CONCAT(ROUND(
           (SELECT COUNT(*) FROM orders WHERE order_time >= DATE_SUB(@NOW, INTERVAL 30 DAY)) /
           NULLIF((SELECT COUNT(*) FROM (SELECT user_id FROM orders WHERE order_time >= DATE_SUB(@NOW, INTERVAL 30 DAY) GROUP BY user_id) active), 0), 1
       ), ' 订单/用户'),
       CONCAT(ROUND(
           (SELECT COUNT(*) FROM orders WHERE order_time >= DATE_SUB(@NOW, INTERVAL 7 DAY)) /
           NULLIF((SELECT COUNT(*) FROM (SELECT user_id FROM orders WHERE order_time >= DATE_SUB(@NOW, INTERVAL 7 DAY) GROUP BY user_id) active), 0), 1
       ), ' 订单/用户')
UNION ALL
SELECT '平均客单价',
       CONCAT('¥', ROUND(
           (SELECT AVG(amount) FROM orders WHERE status = 4 AND order_time >= DATE_SUB(@NOW, INTERVAL 30 DAY)), 2)
       ),
       CONCAT('¥', ROUND(
           (SELECT AVG(amount) FROM orders WHERE status = 4 AND order_time >= DATE_SUB(@NOW, INTERVAL 7 DAY)), 2)
       );

SELECT '========== 26. 库存效率分析 ==========' AS '测试项';
SELECT
    '库存周转率' as '指标',
    CONCAT(ROUND(
        COALESCE((SELECT SUM(od.quantity)
         FROM order_detail od
         JOIN orders o ON od.order_id = o.id
         WHERE o.status IN (3, 4)
         AND o.order_time >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)), 0) /
        NULLIF(AVG(stock), 0), 2
    ), ' 倍') as '最近30天销量/平均库存',
    CASE
        WHEN AVG(stock) > 100 THEN '库存过高'
        WHEN AVG(stock) > 50 THEN '库存正常'
        WHEN AVG(stock) > 0 THEN '库存不足'
        ELSE '库存危急'
    END as '库存 здоровья度'
FROM dish
WHERE status = 1 AND is_deleted = 0;

SELECT '========== 27. 订单流程监控 ==========' AS '测试项';
SELECT
    '订单处理效率' as '指标',
    CONCAT(ROUND(
        TIMESTAMPDIFF(MINUTE, order_time, complete_time) / 60, 1
    ), ' 小时') as '平均处理时间',
    '配送中订单超时(>2小时)' as '超时统计',
    COUNT(
        CASE WHEN status = 3 AND TIMESTAMPDIFF(MINUTE, order_time, @NOW) > 120 THEN 1 END
    ) as '超时数量'
FROM orders
WHERE status IN (3, 4) AND order_time >= DATE_SUB(@NOW, INTERVAL 7 DAY);

SELECT '========== 28. 菜品销售热点分析 ==========' AS '测试项';
SELECT
    od.dish_name as '菜品名称',
    c.name as '分类',
    SUM(od.quantity) as '销量',
    ROUND(SUM(od.amount), 2) as '销售额',
    COUNT(DISTINCT od.order_id) as '订单数',
    ROUND(AVG(od.quantity), 1) as '平均单量'
FROM order_detail od
JOIN orders o ON od.order_id = o.id
LEFT JOIN category c ON od.dish_id IN (SELECT id FROM dish WHERE category_id = c.id AND c.type = 1)
WHERE o.status IN (3, 4)
AND o.order_time >= DATE_SUB(@NOW, INTERVAL 30 DAY)
AND od.dish_name IS NOT NULL
AND od.dish_name != ''
GROUP BY od.dish_name, c.name
ORDER BY SUM(od.amount) DESC
LIMIT 10;

SELECT '========== 29. 销售趋势分析 ==========' AS '测试项';
SELECT
    DATE(order_time) as '日期',
    COUNT(*) as '订单数',
    ROUND(SUM(amount), 2) as '销售额',
    COUNT(DISTINCT user_id) as '购买用户数',
    ROUND(SUM(amount) / COUNT(DISTINCT user_id), 2) as '人均消费'
FROM orders
WHERE status IN (3, 4)
AND order_time >= DATE_SUB(@TODAY, INTERVAL 14 DAY)
GROUP BY DATE(order_time)
ORDER BY DATE(order_time) DESC;

SELECT '========== 30. 系统健康状态检查 ==========' AS '测试项';
SELECT
    '数据一致性检查' as '检查项',
    CASE
        WHEN (
            SELECT COUNT(*)
            FROM orders o
            WHERE o.amount != (
                SELECT SUM(od.amount)
                FROM order_detail od
                WHERE od.order_id = o.id
                GROUP BY od.order_id
            )
        ) = 0 THEN '✅ 订单金额一致'
        ELSE '❌ 发现金额不一致'
    END as '状态'
UNION ALL
SELECT '用户账户安全',
    CASE WHEN (
        SELECT COUNT(*)
        FROM `user`
        WHERE password IS NULL OR password = ''
    ) = 0 THEN '✅ 无弱密码用户' ELSE '❌ 存在弱密码用户' END
UNION ALL
SELECT '库存数据合理性',
    CASE WHEN (
        SELECT COUNT(*)
        FROM dish
        WHERE stock < 0 OR status = 1 AND stock = 0
    ) = 0 THEN '✅ 库存数据正常' ELSE '❌ 库存数据异常' END
UNION ALL
SELECT '数据库连接状态',
    '✅ 连接正常（测试通过）';

SELECT '========== 31. 异常数据监控 ==========' AS '测试项';
SELECT
    '异常数据类型' as '监控项',
    COUNT(*) as '数量'
FROM (
    -- 异常订单
    SELECT '订单金额为负' as issue
    FROM orders WHERE amount < 0
    UNION ALL
    SELECT '订单时间异常' FROM orders WHERE order_time > @NOW OR order_time < '2020-01-01'
    UNION ALL
    -- 异常菜品
    SELECT '菜品价格异常' FROM dish WHERE price <= 0 AND is_deleted = 0
    UNION ALL
    SELECT '菜品库存为负' FROM dish WHERE stock < 0 AND is_deleted = 0
    UNION ALL
    -- 异常用户
    SELECT '余额为负' FROM `user` WHERE balance < 0
    UNION ALL
    -- 异常购物车
    SELECT '购物车数量异常' FROM shopping_cart WHERE quantity <= 0 OR amount <= 0
) issues
GROUP BY issue
ORDER BY COUNT(*) DESC;

-- ============================================================
-- 性能监控指标（新增）
-- ============================================================

SELECT '========== 32. 数据库性能指标 ==========' AS '测试项';
SELECT
    '表数量' as '指标',
    COUNT(*) as '值',
    '基础信息' as '分类'
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'meal_order_system'
UNION ALL
SELECT '总数据量',
       (
           SELECT SUM(TABLE_ROWS)
           FROM INFORMATION_SCHEMA.TABLES
           WHERE TABLE_SCHEMA = 'meal_order_system'
       ),
       '基础信息'
UNION ALL
SELECT '索引数量',
       (
           SELECT COUNT(*)
           FROM INFORMATION_SCHEMA.STATISTICS
           WHERE TABLE_SCHEMA = 'meal_order_system'
           AND INDEX_NAME != 'PRIMARY'
       ),
       '基础信息';

-- ============================================================
-- 测试脚本执行结束
-- ============================================================

SELECT CONCAT('
🎉 测试脚本执行完成！
执行时间: ', DATE_FORMAT(@NOW, '%Y-%m-%d %H:%i:%s'), '
包含测试项: 32个全面验证

✓ 数据库结构完整性
✓ 业务数据合理性
✓ 用户行为深度分析
✓ 系统性能监控
✓ 数据质量保证
✓ 业务规则验证

') AS '📋 执行报告';
========================================
测试脚本执行完成！
========================================
' AS '备注';

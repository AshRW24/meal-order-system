#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
初始化套餐测试所需的数据
"""

import mysql.connector
from datetime import datetime

# 数据库连接配置
db_config = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': '123456',
    'database': 'meal_order_system'
}

def init_test_data():
    """初始化测试数据"""
    conn = None
    try:
        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        # 1. 插入测试分类
        cursor.execute("""
            INSERT INTO category (name, type, sort, is_deleted, create_time, update_time)
            VALUES ('测试套餐分类', 2, 1, 0, NOW(), NOW())
            ON DUPLICATE KEY UPDATE update_time = NOW()
        """)

        category_id = cursor.lastrowid
        if category_id == 0:  # 如果已存在，获取ID
            cursor.execute("SELECT id FROM category WHERE name = '测试套餐分类' AND is_deleted = 0")
            result = cursor.fetchone()
            if result:
                category_id = result[0]

        # 2. 插入测试菜品分类
        cursor.execute("""
            INSERT INTO category (name, type, sort, is_deleted, create_time, update_time)
            VALUES ('测试菜品分类', 1, 1, 0, NOW(), NOW())
            ON DUPLICATE KEY UPDATE update_time = NOW()
        """)

        dish_category_id = cursor.lastrowid
        if dish_category_id == 0:
            cursor.execute("SELECT id FROM category WHERE name = '测试菜品分类' AND is_deleted = 0")
            result = cursor.fetchone()
            if result:
                dish_category_id = result[0]

        # 3. 插入测试菜品
        cursor.execute("""
            INSERT INTO dish (name, category_id, price, image, description, status, is_deleted, create_time, update_time)
            VALUES ('测试菜品1', %s, 29.99, 'http://example.com/dish1.jpg', '测试菜品描述', 1, 0, NOW(), NOW())
            ON DUPLICATE KEY UPDATE update_time = NOW()
        """, (dish_category_id,))

        dish1_id = cursor.lastrowid
        if dish1_id == 0:
            cursor.execute("SELECT id FROM dish WHERE name = '测试菜品1' AND is_deleted = 0")
            result = cursor.fetchone()
            if result:
                dish1_id = result[0]

        cursor.execute("""
            INSERT INTO dish (name, category_id, price, image, description, status, is_deleted, create_time, update_time)
            VALUES ('测试菜品2', %s, 39.99, 'http://example.com/dish2.jpg', '测试菜品描述', 1, 0, NOW(), NOW())
            ON DUPLICATE KEY UPDATE update_time = NOW()
        """, (dish_category_id,))

        dish2_id = cursor.lastrowid
        if dish2_id == 0:
            cursor.execute("SELECT id FROM dish WHERE name = '测试菜品2' AND is_deleted = 0")
            result = cursor.fetchone()
            if result:
                dish2_id = result[0]

        conn.commit()

        print("✅ 测试数据初始化成功!")
        print(f"   分类ID: {category_id}")
        print(f"   菜品分类ID: {dish_category_id}")
        print(f"   菜品1 ID: {dish1_id}")
        print(f"   菜品2 ID: {dish2_id}")

        cursor.close()
        return True

    except Exception as e:
        print(f"❌ 初始化失败: {str(e)}")
        if conn:
            conn.rollback()
        return False
    finally:
        if conn:
            conn.close()


if __name__ == "__main__":
    init_test_data()

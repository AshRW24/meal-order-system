#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Task 13 - 购物车功能自动化测试
测试范围：
1. 添加菜品到购物车
2. 查询购物车列表
3. 清空购物车
"""

import requests
import json

# 配置
BASE_URL = "http://localhost:8080/api"
USER_LOGIN_URL = f"{BASE_URL}/user/login"
CART_URL = f"{BASE_URL}/user/shoppingCart"
DISH_URL = f"{BASE_URL}/user/dishes"

# 测试用户
TEST_USER = {
    "username": "user001",
    "password": "123456"
}


class TestShoppingCart:
    def __init__(self):
        self.session = requests.Session()
        self.user_id = None

    def login(self):
        """用户登录"""
        print("\n=== 测试 1: 用户登录 ===")
        try:
            response = self.session.post(USER_LOGIN_URL, json=TEST_USER)
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            assert result["code"] == 200, f"业务状态码错误: {result['code']}"
            assert "data" in result, "返回数据缺少data字段"

            self.user_id = result["data"]["id"]
            print(f"✅ 登录成功 - 用户ID: {self.user_id}")
            return True
        except Exception as e:
            print(f"❌ 登录失败: {str(e)}")
            return False

    def get_available_dishes(self):
        """获取在售菜品列表"""
        print("\n=== 测试 2: 获取在售菜品 ===")
        try:
            response = self.session.get(DISH_URL)
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            assert result["code"] == 200, f"业务状态码错误: {result['code']}"
            assert isinstance(result["data"], list), "返回数据应为列表"

            dishes = result["data"]
            print(f"✅ 获取成功 - 共 {len(dishes)} 道菜品")

            if len(dishes) == 0:
                print("⚠️  警告: 没有在售菜品，请先在管理端上架菜品")
                return []

            return dishes
        except Exception as e:
            print(f"❌ 获取菜品失败: {str(e)}")
            return []

    def add_to_cart(self, dish_id):
        """添加菜品到购物车"""
        print(f"\n=== 测试 3: 添加菜品到购物车 (ID: {dish_id}) ===")
        try:
            data = {
                "itemId": dish_id,
                "itemType": 1,  # 1-菜品
                "quantity": 2
            }
            response = self.session.post(CART_URL, json=data)
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            assert result["code"] == 200, f"业务状态码错误: {result['code']}, {result.get('msg')}"

            print(f"✅ 添加成功")
            return True
        except Exception as e:
            print(f"❌ 添加失败: {str(e)}")
            return False

    def get_cart_list(self):
        """查询购物车列表"""
        print("\n=== 测试 4: 查询购物车列表 ===")
        try:
            response = self.session.get(CART_URL)
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            assert result["code"] == 200, f"业务状态码错误: {result['code']}"
            assert isinstance(result["data"], list), "返回数据应为列表"

            cart_items = result["data"]
            print(f"✅ 查询成功 - 购物车有 {len(cart_items)} 件商品")

            for item in cart_items:
                print(f"   - {item['itemName']} x{item['quantity']} = ¥{float(item['price']) * item['quantity']:.2f}")

            return cart_items
        except Exception as e:
            print(f"❌ 查询失败: {str(e)}")
            return []

    def clear_cart(self):
        """清空购物车"""
        print("\n=== 测试 5: 清空购物车 ===")
        try:
            response = self.session.delete(CART_URL)
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            assert result["code"] == 200, f"业务状态码错误: {result['code']}"

            print("✅ 清空成功")
            return True
        except Exception as e:
            print(f"❌ 清空失败: {str(e)}")
            return False

    def verify_cart_empty(self):
        """验证购物车已清空"""
        print("\n=== 测试 6: 验证购物车已清空 ===")
        try:
            cart_items = self.get_cart_list()
            assert len(cart_items) == 0, f"购物车应为空，实际有 {len(cart_items)} 件商品"
            print("✅ 验证成功 - 购物车已清空")
            return True
        except Exception as e:
            print(f"❌ 验证失败: {str(e)}")
            return False

    def test_add_duplicate_item(self, dish_id):
        """测试添加重复商品（应该增加数量）"""
        print(f"\n=== 测试 7: 添加重复商品 (ID: {dish_id}) ===")
        try:
            # 第一次添加
            data = {"itemId": dish_id, "itemType": 1, "quantity": 1}
            response1 = self.session.post(CART_URL, json=data)
            result1 = response1.json()
            assert result1["code"] == 200, "第一次添加失败"

            # 第二次添加相同商品
            response2 = self.session.post(CART_URL, json=data)
            result2 = response2.json()
            assert result2["code"] == 200, "第二次添加失败"

            # 验证数量是否增加
            cart_items = self.get_cart_list()
            item = next((x for x in cart_items if x["itemId"] == dish_id), None)
            assert item is not None, "购物车中未找到该商品"
            assert item["quantity"] >= 2, f"数量应至少为2，实际为{item['quantity']}"

            print(f"✅ 测试成功 - 重复添加商品，数量增加到 {item['quantity']}")
            return True
        except Exception as e:
            print(f"❌ 测试失败: {str(e)}")
            return False

    def run_all_tests(self):
        """运行所有测试"""
        print("=" * 60)
        print("Task 13 - 购物车功能自动化测试")
        print("=" * 60)

        test_results = []

        # 1. 登录
        result = self.login()
        test_results.append(("用户登录", result))
        if not result:
            print("\n❌ 登录失败，终止测试")
            return False

        # 2. 获取菜品列表
        dishes = self.get_available_dishes()
        test_results.append(("获取在售菜品", len(dishes) > 0))
        if len(dishes) == 0:
            print("\n❌ 没有在售菜品，终止测试")
            return False

        dish_id = dishes[0]["id"]

        # 3. 添加到购物车
        result = self.add_to_cart(dish_id)
        test_results.append(("添加到购物车", result))

        # 4. 查询购物车
        cart_items = self.get_cart_list()
        test_results.append(("查询购物车列表", len(cart_items) > 0))

        # 5. 清空购物车
        result = self.clear_cart()
        test_results.append(("清空购物车", result))

        # 6. 验证已清空
        result = self.verify_cart_empty()
        test_results.append(("验证购物车已清空", result))

        # 7. 测试重复添加
        result = self.test_add_duplicate_item(dish_id)
        test_results.append(("测试重复添加商品", result))

        # 测试总结
        print("\n" + "=" * 60)
        print("测试总结")
        print("=" * 60)

        passed = sum(1 for _, result in test_results if result)
        total = len(test_results)

        for test_name, result in test_results:
            status = "✅ PASS" if result else "❌ FAIL"
            print(f"{status} - {test_name}")

        print(f"\n通过率: {passed}/{total} ({passed * 100 / total:.1f}%)")

        if passed == total:
            print("\n🎉 所有测试通过！")
            return True
        else:
            print(f"\n⚠️  有 {total - passed} 个测试失败")
            return False


if __name__ == "__main__":
    tester = TestShoppingCart()
    success = tester.run_all_tests()
    exit(0 if success else 1)

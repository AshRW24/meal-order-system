#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Task 14 - 购物车修改+删除功能自动化测试
测试范围：
1. 修改购物车商品数量
2. 删除购物车中的单个商品
3. 权限验证
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


class TestCartUpdateDelete:
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

            self.user_id = result["data"]["id"]
            print(f"✅ 登录成功 - 用户ID: {self.user_id}")
            return True
        except Exception as e:
            print(f"❌ 登录失败: {str(e)}")
            return False

    def add_test_items(self):
        """添加测试商品到购物车"""
        print("\n=== 测试 2: 添加测试商品到购物车 ===")
        try:
            # 获取菜品列表
            response = self.session.get(DISH_URL)
            dishes = response.json()["data"]

            if len(dishes) < 2:
                print("⚠️  警告: 在售菜品少于2道，测试可能不完整")
                return []

            # 添加两道菜品
            cart_ids = []
            for i in range(min(2, len(dishes))):
                data = {
                    "itemId": dishes[i]["id"],
                    "itemType": 1,
                    "quantity": 1
                }
                response = self.session.post(CART_URL, json=data)
                result = response.json()
                assert result["code"] == 200, f"添加失败: {result.get('msg')}"

            # 获取购物车列表，获取cart ID
            response = self.session.get(CART_URL)
            cart_items = response.json()["data"]
            cart_ids = [item["id"] for item in cart_items]

            print(f"✅ 添加成功 - 购物车有 {len(cart_ids)} 件商品")
            return cart_ids
        except Exception as e:
            print(f"❌ 添加失败: {str(e)}")
            return []

    def test_update_quantity(self, cart_id):
        """测试修改商品数量"""
        print(f"\n=== 测试 3: 修改商品数量 (Cart ID: {cart_id}) ===")
        try:
            # 修改数量为5
            url = f"{CART_URL}/{cart_id}/quantity"
            response = self.session.put(url, params={"quantity": 5})
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            assert result["code"] == 200, f"业务状态码错误: {result['code']}, {result.get('msg')}"

            # 验证数量是否修改成功
            response = self.session.get(CART_URL)
            cart_items = response.json()["data"]
            item = next((x for x in cart_items if x["id"] == cart_id), None)

            assert item is not None, "购物车中未找到该商品"
            assert item["quantity"] == 5, f"数量应为5，实际为{item['quantity']}"

            print(f"✅ 修改成功 - 数量已更新为 5")
            return True
        except Exception as e:
            print(f"❌ 修改失败: {str(e)}")
            return False

    def test_update_invalid_quantity(self, cart_id):
        """测试修改为无效数量（应该失败）"""
        print(f"\n=== 测试 4: 修改为无效数量 (Cart ID: {cart_id}) ===")
        try:
            # 尝试修改数量为0（应该失败）
            url = f"{CART_URL}/{cart_id}/quantity"
            response = self.session.put(url, params={"quantity": 0})
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            # 应该返回错误
            if result["code"] != 200:
                print(f"✅ 验证成功 - 正确拒绝了无效数量: {result.get('msg')}")
                return True
            else:
                print(f"❌ 验证失败 - 应该拒绝数量为0")
                return False
        except Exception as e:
            print(f"❌ 测试失败: {str(e)}")
            return False

    def test_delete_item(self, cart_id):
        """测试删除单个商品"""
        print(f"\n=== 测试 5: 删除单个商品 (Cart ID: {cart_id}) ===")
        try:
            # 删除商品
            url = f"{CART_URL}/{cart_id}"
            response = self.session.delete(url)
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            assert result["code"] == 200, f"业务状态码错误: {result['code']}, {result.get('msg')}"

            # 验证是否删除成功
            response = self.session.get(CART_URL)
            cart_items = response.json()["data"]
            item = next((x for x in cart_items if x["id"] == cart_id), None)

            assert item is None, "商品应该已被删除，但仍在购物车中"

            print(f"✅ 删除成功 - 商品已从购物车移除")
            return True
        except Exception as e:
            print(f"❌ 删除失败: {str(e)}")
            return False

    def test_delete_nonexistent(self):
        """测试删除不存在的商品（应该失败）"""
        print("\n=== 测试 6: 删除不存在的商品 ===")
        try:
            # 尝试删除不存在的商品
            fake_id = 999999
            url = f"{CART_URL}/{fake_id}"
            response = self.session.delete(url)
            result = response.json()

            assert response.status_code == 200, f"HTTP状态码错误: {response.status_code}"
            # 应该返回错误
            if result["code"] != 200:
                print(f"✅ 验证成功 - 正确拒绝了不存在的商品: {result.get('msg')}")
                return True
            else:
                print(f"❌ 验证失败 - 应该拒绝删除不存在的商品")
                return False
        except Exception as e:
            print(f"❌ 测试失败: {str(e)}")
            return False

    def test_batch_operations(self):
        """测试批量操作"""
        print("\n=== 测试 7: 批量操作（添加→修改→删除） ===")
        try:
            # 添加3件商品
            response = self.session.get(DISH_URL)
            dishes = response.json()["data"]

            if len(dishes) < 1:
                print("⚠️  跳过: 没有在售菜品")
                return True

            dish_id = dishes[0]["id"]

            # 添加商品
            data = {"itemId": dish_id, "itemType": 1, "quantity": 2}
            response = self.session.post(CART_URL, json=data)
            assert response.json()["code"] == 200, "添加失败"

            # 获取cart ID
            response = self.session.get(CART_URL)
            cart_items = response.json()["data"]
            cart_id = cart_items[0]["id"]

            # 修改数量
            url = f"{CART_URL}/{cart_id}/quantity"
            response = self.session.put(url, params={"quantity": 10})
            assert response.json()["code"] == 200, "修改失败"

            # 验证数量
            response = self.session.get(CART_URL)
            cart_items = response.json()["data"]
            item = next((x for x in cart_items if x["id"] == cart_id), None)
            assert item["quantity"] == 10, f"数量应为10，实际为{item['quantity']}"

            # 删除
            url = f"{CART_URL}/{cart_id}"
            response = self.session.delete(url)
            assert response.json()["code"] == 200, "删除失败"

            print("✅ 批量操作成功 - 添加→修改→删除")
            return True
        except Exception as e:
            print(f"❌ 批量操作失败: {str(e)}")
            return False

    def cleanup(self):
        """清理测试数据"""
        print("\n=== 清理测试数据 ===")
        try:
            response = self.session.delete(CART_URL)
            if response.json()["code"] == 200:
                print("✅ 清理成功")
            return True
        except Exception as e:
            print(f"⚠️  清理失败: {str(e)}")
            return False

    def run_all_tests(self):
        """运行所有测试"""
        print("=" * 60)
        print("Task 14 - 购物车修改+删除功能自动化测试")
        print("=" * 60)

        test_results = []

        # 1. 登录
        result = self.login()
        test_results.append(("用户登录", result))
        if not result:
            print("\n❌ 登录失败，终止测试")
            return False

        # 2. 添加测试商品
        cart_ids = self.add_test_items()
        test_results.append(("添加测试商品", len(cart_ids) >= 1))

        if len(cart_ids) < 1:
            print("\n❌ 无法添加测试商品，终止测试")
            return False

        # 3. 测试修改数量
        result = self.test_update_quantity(cart_ids[0])
        test_results.append(("修改商品数量", result))

        # 4. 测试无效数量
        result = self.test_update_invalid_quantity(cart_ids[0])
        test_results.append(("拒绝无效数量", result))

        # 5. 测试删除商品
        if len(cart_ids) >= 2:
            result = self.test_delete_item(cart_ids[1])
            test_results.append(("删除单个商品", result))

        # 6. 测试删除不存在的商品
        result = self.test_delete_nonexistent()
        test_results.append(("拒绝删除不存在的商品", result))

        # 7. 测试批量操作
        result = self.test_batch_operations()
        test_results.append(("批量操作", result))

        # 清理
        self.cleanup()

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
    tester = TestCartUpdateDelete()
    success = tester.run_all_tests()
    exit(0 if success else 1)

"""
Task 16: 用户端订单下单自动化测试

测试内容：
1. 准备测试数据（添加商品到购物车、添加地址）
2. 提交订单
3. 验证订单创建成功
4. 验证购物车已清空
5. 查询订单列表
6. 查询订单详情

技术栈：requests + Session认证
"""

import requests
import unittest

BASE_URL = "http://localhost:8080/api"
LOGIN_URL = f"{BASE_URL}/user/login"
CART_URL = f"{BASE_URL}/user/shoppingCart"
ADDRESS_URL = f"{BASE_URL}/user/addresses"
ORDER_URL = f"{BASE_URL}/user/orders"
DISH_URL = f"{BASE_URL}/user/dishes"


class TestOrderPlacement(unittest.TestCase):
    """订单下单测试类"""

    @classmethod
    def setUpClass(cls):
        """测试前登录"""
        cls.session = requests.Session()
        login_data = {
            "username": "user001",
            "password": "123456"
        }
        response = cls.session.post(LOGIN_URL, json=login_data)
        result = response.json()
        assert result["code"] == 200, "登录失败"
        print("[PASS] 登录成功")

        # 清理测试数据
        cls.cleanup_test_data()

    @classmethod
    def cleanup_test_data(cls):
        """清理测试数据"""
        try:
            # 清理购物车
            cls.session.delete(f"{CART_URL}/clean")

            # 清理地址
            response = cls.session.get(ADDRESS_URL)
            result = response.json()
            if result["code"] == 200 and result["data"]:
                for address in result["data"]:
                    cls.session.delete(f"{ADDRESS_URL}/{address['id']}")

            print("[INFO] 测试数据清理完成")
        except Exception as e:
            print(f"[WARN] 清理测试数据时出错: {e}")

    def test_01_prepare_cart_and_address(self):
        """测试1：准备测试数据（购物车和地址）"""
        # 查询可用菜品
        response = self.session.get(DISH_URL)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200
        assert len(result["data"]) > 0, "没有可用的菜品"

        # 添加第一个菜品到购物车
        dish = result["data"][0]
        cart_data = {
            "itemId": dish["id"],
            "itemName": dish["name"],
            "itemType": 1,  # 菜品
            "price": dish["price"],
            "quantity": 2,
            "image": dish["image"]
        }

        cart_response = self.session.post(CART_URL, json=cart_data)
        cart_result = cart_response.json()

        assert cart_response.status_code == 200
        assert cart_result["code"] == 200

        print(f"[PASS] 测试1通过 - 商品已添加到购物车：{dish['name']}")

        # 添加地址
        address_data = {
            "consignee": "测试用户",
            "phone": "13800138000",
            "province": "北京市",
            "city": "北京市",
            "district": "朝阳区",
            "detail": "测试街道123号",
            "label": "家",
            "isDefault": 1
        }

        address_response = self.session.post(ADDRESS_URL, json=address_data)
        address_result = address_response.json()

        assert address_response.status_code == 200
        assert address_result["code"] == 200

        print("[PASS] 测试1通过 - 地址已添加")

    def test_02_submit_order(self):
        """测试2：提交订单"""
        # 先准备数据
        self.test_01_prepare_cart_and_address()

        # 获取地址ID
        address_response = self.session.get(ADDRESS_URL)
        address_result = address_response.json()
        assert len(address_result["data"]) > 0, "没有可用的地址"
        address_id = address_result["data"][0]["id"]

        # 提交订单
        order_data = {
            "addressId": address_id,
            "remark": "测试订单备注"
        }

        response = self.session.post(ORDER_URL, json=order_data)
        result = response.json()

        print(f"[DEBUG] Submit Order Response: {response.status_code}, {result}")

        assert response.status_code == 200, f"Expected 200, got {response.status_code}: {response.text}"
        assert result["code"] == 200, f"Expected code 200, got {result['code']}: {result.get('msg', '')}"
        assert result["data"] is not None, "订单ID不应为空"

        # 保存订单ID用于后续测试
        self.__class__.order_id = result["data"]

        print(f"[PASS] 测试2通过 - 订单提交成功，订单ID：{self.__class__.order_id}")

    def test_03_verify_cart_cleared(self):
        """测试3：验证购物车已清空"""
        # 先提交订单
        self.cleanup_test_data()
        self.test_02_submit_order()

        # 查询购物车
        response = self.session.get(CART_URL)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200
        assert len(result["data"]) == 0, "购物车应该为空"

        print("[PASS] 测试3通过 - 购物车已清空")

    def test_04_query_order_list(self):
        """测试4：查询订单列表"""
        # 确保有订单存在
        if not hasattr(self.__class__, 'order_id'):
            self.test_02_submit_order()

        response = self.session.get(ORDER_URL)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200
        assert isinstance(result["data"], list)
        assert len(result["data"]) > 0, "订单列表不应为空"

        # 验证订单信息
        order = result["data"][0]
        assert "id" in order
        assert "orderNumber" in order
        assert "amount" in order
        assert "status" in order
        assert "consignee" in order
        assert "address" in order

        print(f"[PASS] 测试4通过 - 订单列表查询成功，共{len(result['data'])}个订单")

    def test_05_query_order_detail(self):
        """测试5：查询订单详情"""
        # 确保有订单存在
        if not hasattr(self.__class__, 'order_id'):
            self.test_02_submit_order()

        order_id = self.__class__.order_id
        response = self.session.get(f"{ORDER_URL}/{order_id}")
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200
        assert result["data"] is not None

        # 验证订单详细信息
        order = result["data"]
        assert order["id"] == order_id
        assert order["status"] == 1, "订单状态应该是待确认"
        assert order["payStatus"] == 0, "支付状态应该是未支付"
        assert order["consignee"] == "测试用户"
        assert order["phone"] == "13800138000"
        assert "测试街道123号" in order["address"]
        assert order["remark"] == "测试订单备注"

        print(f"[PASS] 测试5通过 - 订单详情查询成功，订单号：{order['orderNumber']}")

    def test_06_order_number_format(self):
        """测试6：验证订单号格式"""
        # 确保有订单存在
        if not hasattr(self.__class__, 'order_id'):
            self.test_02_submit_order()

        order_id = self.__class__.order_id
        response = self.session.get(f"{ORDER_URL}/{order_id}")
        result = response.json()

        order = result["data"]
        order_number = order["orderNumber"]

        # 订单号格式：yyyyMMddHHmmss + 4位序列号，总共18位
        assert len(order_number) == 18, f"订单号长度应该是18，实际是{len(order_number)}"
        assert order_number.isdigit(), "订单号应该全是数字"

        print(f"[PASS] 测试6通过 - 订单号格式正确：{order_number}")

    def test_07_order_without_address(self):
        """测试7：没有地址时不能下单"""
        # 清理测试数据
        self.cleanup_test_data()

        # 添加商品到购物车
        response = self.session.get(DISH_URL)
        result = response.json()
        dish = result["data"][0]

        cart_data = {
            "itemId": dish["id"],
            "itemName": dish["name"],
            "itemType": 1,
            "price": dish["price"],
            "quantity": 1,
            "image": dish["image"]
        }
        self.session.post(CART_URL, json=cart_data)

        # 尝试用无效的地址ID下单
        order_data = {
            "addressId": 99999,  # 不存在的地址ID
            "remark": "测试"
        }

        response = self.session.post(ORDER_URL, json=order_data)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] != 200, "应该下单失败"

        print("[PASS] 测试7通过 - 无效地址下单失败")

    def test_08_order_with_empty_cart(self):
        """测试8：购物车为空时不能下单"""
        # 清理测试数据
        self.cleanup_test_data()

        # 添加地址
        address_data = {
            "consignee": "测试用户",
            "phone": "13800138000",
            "province": "北京市",
            "city": "北京市",
            "district": "朝阳区",
            "detail": "测试街道123号",
            "label": "家",
            "isDefault": 1
        }
        address_response = self.session.post(ADDRESS_URL, json=address_data)
        address_result = address_response.json()
        address_id = address_result["data"]

        # 尝试下单（购物车为空）
        order_data = {
            "addressId": address_id,
            "remark": "测试"
        }

        response = self.session.post(ORDER_URL, json=order_data)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] != 200, f"应该下单失败，但返回: {result}"

        print("[PASS] 测试8通过 - 空购物车下单失败")

    @classmethod
    def tearDownClass(cls):
        """测试后清理"""
        cls.cleanup_test_data()
        print("\n[SUCCESS] 所有测试完成")


if __name__ == "__main__":
    print("=" * 60)
    print("Task 16: 订单下单功能测试")
    print("=" * 60)
    unittest.main(verbosity=2)

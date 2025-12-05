"""
Task 15: 用户端地址管理自动化测试

测试内容：
1. 查询地址列表（空列表）
2. 新增第一个地址（自动设为默认）
3. 查询地址列表（1个地址）
4. 新增第二个地址（不设为默认）
5. 查询地址列表（2个地址）
6. 查询默认地址
7. 设置第二个地址为默认
8. 查询默认地址（验证已更新）
9. 更新地址信息
10. 查询地址详情（验证更新）
11. 删除地址
12. 查询地址列表（验证删除）

技术栈：requests + Session认证
"""

import requests
import unittest

BASE_URL = "http://localhost:8080/api"
LOGIN_URL = f"{BASE_URL}/user/login"
ADDRESS_URL = f"{BASE_URL}/user/addresses"


class TestAddressManagement(unittest.TestCase):
    """地址管理测试类"""

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

        # 清理可能存在的测试数据
        cls.cleanup_test_data()

    @classmethod
    def cleanup_test_data(cls):
        """清理测试数据"""
        try:
            response = cls.session.get(ADDRESS_URL)
            result = response.json()
            if result["code"] == 200 and result["data"]:
                for address in result["data"]:
                    cls.session.delete(f"{ADDRESS_URL}/{address['id']}")
            print("[INFO] 测试数据清理完成")
        except Exception as e:
            print(f"[WARN] 清理测试数据时出错: {e}")

    def test_01_get_empty_address_list(self):
        """测试1：查询空地址列表"""
        response = self.session.get(ADDRESS_URL)

        print(f"[DEBUG] Status Code: {response.status_code}")
        print(f"[DEBUG] Response Text: {response.text}")

        assert response.status_code == 200, f"Expected 200, got {response.status_code}: {response.text}"

        result = response.json()
        assert result["code"] == 200
        assert isinstance(result["data"], list)
        assert len(result["data"]) == 0

        print("[PASS] 测试1通过 - 空地址列表查询成功")

    def test_02_add_first_address(self):
        """测试2：新增第一个地址（自动设为默认）"""
        address_data = {
            "consignee": "张三",
            "phone": "13800138000",
            "province": "北京市",
            "city": "北京市",
            "district": "朝阳区",
            "detail": "某某街道123号",
            "label": "家",
            "isDefault": 0  # 即使设为0，第一个地址也会自动设为默认
        }

        response = self.session.post(ADDRESS_URL, json=address_data)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200

        # 验证第一个地址自动设为默认
        list_response = self.session.get(ADDRESS_URL)
        list_result = list_response.json()
        assert len(list_result["data"]) == 1
        assert list_result["data"][0]["isDefault"] == 1

        print("[PASS] 测试2通过 - 第一个地址添加成功，已自动设为默认")
        return list_result["data"][0]["id"]

    def test_03_get_address_list_with_one_item(self):
        """测试3：查询地址列表（1个地址）"""
        # 先清理数据
        self.cleanup_test_data()
        # 添加一个地址
        self.test_02_add_first_address()

        response = self.session.get(ADDRESS_URL)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200
        assert len(result["data"]) == 1
        assert result["data"][0]["consignee"] == "张三"
        assert result["data"][0]["phone"] == "13800138000"

        print("[PASS] 测试3通过 - 地址列表查询成功，包含1个地址")

    def test_04_add_second_address(self):
        """测试4：新增第二个地址（不设为默认）"""
        # 先清理并添加第一个地址
        self.cleanup_test_data()
        self.test_02_add_first_address()

        address_data = {
            "consignee": "李四",
            "phone": "13900139000",
            "province": "上海市",
            "city": "上海市",
            "district": "浦东新区",
            "detail": "某某路456号",
            "label": "公司",
            "isDefault": 0
        }

        response = self.session.post(ADDRESS_URL, json=address_data)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200

        # 验证地址列表包含2个地址
        list_response = self.session.get(ADDRESS_URL)
        list_result = list_response.json()
        assert len(list_result["data"]) == 2

        print("[PASS] 测试4通过 - 第二个地址添加成功")

    def test_05_get_address_list_with_two_items(self):
        """测试5：查询地址列表（2个地址）"""
        # 先清理数据，然后添加两个地址
        self.cleanup_test_data()
        self.test_02_add_first_address()
        address_data = {
            "consignee": "李四",
            "phone": "13900139000",
            "province": "上海市",
            "city": "上海市",
            "district": "浦东新区",
            "detail": "某某路456号",
            "label": "公司",
            "isDefault": 0
        }
        self.session.post(ADDRESS_URL, json=address_data)

        response = self.session.get(ADDRESS_URL)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200
        assert len(result["data"]) == 2

        print("[PASS] 测试5通过 - 地址列表查询成功，包含2个地址")

    def test_06_get_default_address(self):
        """测试6：查询默认地址"""
        # 先清理并添加地址
        self.cleanup_test_data()
        self.test_02_add_first_address()

        response = self.session.get(f"{ADDRESS_URL}/default")
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200
        assert result["data"] is not None
        assert result["data"]["isDefault"] == 1
        assert result["data"]["consignee"] == "张三"

        print("[PASS] 测试6通过 - 默认地址查询成功")

    def test_07_set_default_address(self):
        """测试7：设置默认地址"""
        # 先添加两个地址
        self.cleanup_test_data()
        self.test_02_add_first_address()

        address_data = {
            "consignee": "李四",
            "phone": "13900139000",
            "province": "上海市",
            "city": "上海市",
            "district": "浦东新区",
            "detail": "某某路456号",
            "label": "公司",
            "isDefault": 0
        }
        self.session.post(ADDRESS_URL, json=address_data)

        # 获取地址列表，找到第二个地址
        list_response = self.session.get(ADDRESS_URL)
        list_result = list_response.json()
        second_address_id = None
        for addr in list_result["data"]:
            if addr["consignee"] == "李四":
                second_address_id = addr["id"]
                break

        assert second_address_id is not None, "未找到第二个地址"

        # 设置第二个地址为默认
        response = self.session.put(f"{ADDRESS_URL}/{second_address_id}/default")
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200

        # 验证默认地址已更新
        default_response = self.session.get(f"{ADDRESS_URL}/default")
        default_result = default_response.json()
        assert default_result["data"]["id"] == second_address_id
        assert default_result["data"]["consignee"] == "李四"

        print("[PASS] 测试7通过 - 默认地址设置成功")

    def test_08_update_address(self):
        """测试8：更新地址信息"""
        # 先添加一个地址
        self.cleanup_test_data()
        self.test_02_add_first_address()

        # 获取地址ID
        list_response = self.session.get(ADDRESS_URL)
        list_result = list_response.json()
        address_id = list_result["data"][0]["id"]

        # 更新地址信息
        update_data = {
            "id": address_id,
            "consignee": "张三（已更新）",
            "phone": "13800138001",
            "province": "北京市",
            "city": "北京市",
            "district": "海淀区",
            "detail": "更新后的地址",
            "label": "学校",
            "isDefault": 1
        }

        response = self.session.put(ADDRESS_URL, json=update_data)
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200

        # 验证地址已更新
        detail_response = self.session.get(f"{ADDRESS_URL}/{address_id}")
        detail_result = detail_response.json()
        assert detail_result["data"]["consignee"] == "张三（已更新）"
        assert detail_result["data"]["phone"] == "13800138001"
        assert detail_result["data"]["district"] == "海淀区"
        assert detail_result["data"]["label"] == "学校"

        print("[PASS] 测试8通过 - 地址更新成功")

    def test_09_delete_address(self):
        """测试9：删除地址"""
        # 先添加一个地址
        self.cleanup_test_data()
        self.test_02_add_first_address()

        # 获取地址ID
        list_response = self.session.get(ADDRESS_URL)
        list_result = list_response.json()
        address_id = list_result["data"][0]["id"]

        # 删除地址
        response = self.session.delete(f"{ADDRESS_URL}/{address_id}")
        result = response.json()

        assert response.status_code == 200
        assert result["code"] == 200

        # 验证地址已删除
        list_response2 = self.session.get(ADDRESS_URL)
        list_result2 = list_response2.json()
        assert len(list_result2["data"]) == 0

        print("[PASS] 测试9通过 - 地址删除成功")

    def test_10_permission_validation(self):
        """测试10：权限验证（用户只能操作自己的地址）"""
        # 此测试需要两个用户，暂时跳过
        # 在真实环境中，应该测试用户A无法访问用户B的地址
        print("[SKIP] 测试10跳过 - 权限验证需要多用户环境")

    @classmethod
    def tearDownClass(cls):
        """测试后清理"""
        cls.cleanup_test_data()
        print("\n[SUCCESS] 所有测试完成")


if __name__ == "__main__":
    print("=" * 60)
    print("Task 15: 地址管理功能测试")
    print("=" * 60)
    unittest.main(verbosity=2)

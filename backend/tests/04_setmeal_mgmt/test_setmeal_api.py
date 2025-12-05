#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
套餐管理API测试脚本
"""

import requests
import json
from datetime import datetime

# 基础URL
BASE_URL = "http://localhost:8080/api"

# Session对象（保持Cookie）
session = requests.Session()

# 测试报告
test_results = []
test_setmeal_id = None


def log_test(test_name, passed, message=""):
    """记录测试结果"""
    test_results.append({
        "test": test_name,
        "passed": passed,
        "message": message
    })
    status = "✅ PASS" if passed else "❌ FAIL"
    print(f"{status} - {test_name}: {message}")


def test_admin_login():
    """测试管理员登录"""
    url = f"{BASE_URL}/admin/login"
    data = {"username": "admin", "password": "123456"}
    try:
        resp = session.post(url, json=data)
        result = resp.json()
        if result["code"] == 200:
            log_test("管理员登录", True, f"用户: {result['data']['username']}")
            return True
        else:
            log_test("管理员登录", False, result.get("msg", "登录失败"))
            return False
    except Exception as e:
        log_test("管理员登录", False, str(e))
        return False


def test_add_setmeal():
    """测试新增套餐"""
    global test_setmeal_id
    url = f"{BASE_URL}/admin/setmeals"

    # 使用数据库中已存在的测试数据
    # 注意: 需要提前在数据库中插入测试分类和菜品数据
    # 套餐分类ID: 16, 菜品ID: 4, 5
    data = {
        "name": f"测试套餐-{datetime.now().strftime('%H%M%S')}",
        "categoryId": 16,  # 测试套餐分类
        "price": 99.99,
        "image": "http://example.com/test.jpg",
        "description": "这是一个测试套餐",
        "dishes": [
            {"dishId": 4, "quantity": 2}  # 测试菜品1
        ]
    }

    try:
        resp = session.post(url, json=data)
        result = resp.json()
        if result["code"] == 200:
            # 再查询一次获取ID
            resp2 = session.get(url, params={"page": 1, "pageSize": 10})
            setmeals = resp2.json().get("data", {}).get("records", [])
            if setmeals:
                test_setmeal_id = setmeals[0]["id"]
                log_test("新增套餐", True, f"套餐ID: {test_setmeal_id}")
                return True
        log_test("新增套餐", False, result.get("msg", "新增失败"))
        return False
    except Exception as e:
        log_test("新增套餐", False, str(e))
        return False


def test_page_query():
    """测试分页查询"""
    url = f"{BASE_URL}/admin/setmeals"
    try:
        resp = session.get(url, params={"page": 1, "pageSize": 10})
        result = resp.json()
        if result["code"] == 200:
            total = result["data"]["total"]
            log_test("分页查询", True, f"总数: {total}")
            return True
        else:
            log_test("分页查询", False, result.get("msg", "查询失败"))
            return False
    except Exception as e:
        log_test("分页查询", False, str(e))
        return False


def test_get_by_id():
    """测试根据ID查询"""
    if not test_setmeal_id:
        log_test("根据ID查询", False, "没有测试套餐ID")
        return False

    url = f"{BASE_URL}/admin/setmeals/{test_setmeal_id}"
    try:
        resp = session.get(url)
        result = resp.json()
        if result["code"] == 200:
            log_test("根据ID查询", True, f"套餐名称: {result['data']['name']}")
            return True
        else:
            log_test("根据ID查询", False, result.get("msg", "查询失败"))
            return False
    except Exception as e:
        log_test("根据ID查询", False, str(e))
        return False


def test_update_setmeal():
    """测试修改套餐"""
    if not test_setmeal_id:
        log_test("修改套餐", False, "没有测试套餐ID")
        return False

    # 先查询套餐详情
    url = f"{BASE_URL}/admin/setmeals/{test_setmeal_id}"
    resp = session.get(url)
    setmeal = resp.json().get("data")

    if not setmeal:
        log_test("修改套餐", False, "无法获取套餐详情")
        return False

    # 修改价格
    setmeal["price"] = 88.88

    try:
        resp = session.put(f"{BASE_URL}/admin/setmeals", json=setmeal)
        result = resp.json()
        if result["code"] == 200:
            log_test("修改套餐", True, "价格已更新: 88.88")
            return True
        else:
            log_test("修改套餐", False, result.get("msg", "修改失败"))
            return False
    except Exception as e:
        log_test("修改套餐", False, str(e))
        return False


def test_update_status():
    """测试修改状态"""
    if not test_setmeal_id:
        log_test("状态切换", False, "没有测试套餐ID")
        return False

    url = f"{BASE_URL}/admin/setmeals/{test_setmeal_id}/status"
    try:
        # 下架
        resp = session.post(url, params={"status": 0})
        result = resp.json()
        if result["code"] == 200:
            log_test("状态切换-下架", True, "成功设置为停售")
        else:
            log_test("状态切换-下架", False, result.get("msg"))
            return False

        # 上架
        resp = session.post(url, params={"status": 1})
        result = resp.json()
        if result["code"] == 200:
            log_test("状态切换-上架", True, "成功设置为在售")
            return True
        else:
            log_test("状态切换-上架", False, result.get("msg"))
            return False
    except Exception as e:
        log_test("状态切换", False, str(e))
        return False


def test_delete_setmeal():
    """测试删除套餐"""
    if not test_setmeal_id:
        log_test("删除套餐", False, "没有测试套餐ID")
        return False

    url = f"{BASE_URL}/admin/setmeals/{test_setmeal_id}"
    try:
        resp = session.delete(url)
        result = resp.json()
        if result["code"] == 200:
            log_test("删除套餐", True, "逻辑删除成功")
            return True
        else:
            log_test("删除套餐", False, result.get("msg", "删除失败"))
            return False
    except Exception as e:
        log_test("删除套餐", False, str(e))
        return False


def main():
    """主测试流程"""
    print("\n" + "="*60)
    print("套餐管理API测试")
    print("="*60 + "\n")

    # 执行测试
    test_admin_login()
    test_page_query()
    test_add_setmeal()
    test_get_by_id()
    test_update_setmeal()
    test_update_status()
    test_delete_setmeal()

    # 统计结果
    total = len(test_results)
    passed = sum(1 for t in test_results if t["passed"])
    failed = total - passed
    pass_rate = (passed / total * 100) if total > 0 else 0

    print("\n" + "="*60)
    print(f"测试完成！")
    print(f"总测试数: {total}")
    print(f"✅ 通过: {passed}")
    print(f"❌ 失败: {failed}")
    print(f"通过率: {pass_rate:.1f}%")
    print("="*60 + "\n")

    # 保存测试报告
    report = {
        "test_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "total": total,
        "passed": passed,
        "failed": failed,
        "pass_rate": f"{pass_rate:.1f}%",
        "details": test_results
    }

    with open("backend/tests/04_setmeal_mgmt/test_report.json", "w", encoding="utf-8") as f:
        json.dump(report, f, ensure_ascii=False, indent=2)

    print("测试报告已保存: backend/tests/04_setmeal_mgmt/test_report.json")

    return passed == total


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)

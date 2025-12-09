import requests
import json

# 创建一个会话对象，用于管理cookies
session = requests.Session()

# 登录获取session
login_url = 'http://localhost:8080/api/user/login'
login_data = {
    "username": "user001",
    "password": "123456"
}

print("尝试登录...")
response = session.post(login_url, json=login_data)
print(f"登录响应: {response.status_code} - {response.text}")

if response.status_code != 200:
    print("登录失败，无法继续测试")
    exit(1)

# 获取用户ID
user_id = response.json().get('data')
if not user_id:
    print("无法获取用户ID")
    exit(1)

print(f"成功登录，用户ID: {user_id}")

# 添加到购物车
add_cart_url = 'http://localhost:8080/api/user/shoppingCart'
add_cart_data = {
    "itemId": 1,
    "itemType": 1,
    "quantity": 1
}

print("\n尝试添加商品到购物车...")
response = session.post(add_cart_url, json=add_cart_data)
print(f"添加购物车响应: {response.status_code} - {response.text}")

# 查询购物车
list_cart_url = 'http://localhost:8080/api/user/shoppingCart'
print("\n尝试查询购物车列表...")
response = session.get(list_cart_url)
print(f"查询购物车响应: {response.status_code} - {response.text}")
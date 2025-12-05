# 外卖订餐系统 - 后端

基于 Spring Boot + MyBatis Plus 的后端系统

## 技术栈

- Java: OpenJDK 17.0.16
- Maven: 3.9.11
- Spring Boot: 2.7.18
- MyBatis Plus: 3.5.3.1
- MySQL: 9.4.0（兼容 MySQL 8）
- **Session 认证**（不使用 JWT）
- Knife4j: 3.0.3 (API 文档)
- Lombok: 1.18.30

**详细环境配置**：参见 `docs/环境配置.md`

## MVP 版本说明

- ✅ 使用 **Session + Cookie** 认证
- ✅ 密码 **明文存储**（便于开发调试）
- ✅ 使用 **拦截器** 进行权限控制
- ❌ 不使用 JWT Token
- ❌ 不使用 Spring Security

## 项目结构

```
src/main/java/com/meal/order/
├── common/          # 通用类
├── config/          # 配置类
├── controller/      # 控制器
├── service/         # 服务层
├── mapper/          # 数据访问层
├── entity/          # 实体类
├── dto/             # 数据传输对象
├── vo/              # 视图对象
├── exception/       # 异常类
└── utils/           # 工具类
```

## 配置说明

请在 `application.yml` 中配置数据库连接信息：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/meal_order_system
    username: root
    password: root
```

## 数据库初始化

1. 创建数据库：
```sql
CREATE DATABASE meal_order_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 执行初始化脚本：
```bash
# 在 database 目录下执行
mysql -u root -p meal_order_system < init.sql
mysql -u root -p meal_order_system < test_data.sql
```

## 运行项目

### 方式1：使用 Maven 命令

```bash
# 编译
mvn clean compile

# 运行
mvn spring-boot:run
```

### 方式2：使用 IDE 运行

直接运行 `MealOrderApplication.java` 主类

## 访问地址

- 接口地址：http://localhost:8080/api
- API 文档：http://localhost:8080/api/doc.html

## 功能模块（按照规划图）

### 管理端接口
- [ ] 登录管理（Session 认证）
- [ ] 分类管理（CRUD）
- [ ] 菜单管理（菜品 CRUD）
- [ ] 菜品展示
- [ ] 套餐管理（CRUD + 关联菜品）
- [ ] 订单明细（订单列表、状态管理）

### 用户端接口
- [ ] 用户登录/注册
- [ ] 购物车（增删改查）
- [ ] 下单（创建订单）
- [ ] 地址管理（CRUD）

## 核心接口

### 认证相关
```
POST /api/admin/login       # 管理员登录
POST /api/user/login        # 用户登录
POST /api/user/register     # 用户注册
POST /api/logout            # 登出
```

### 管理端接口
```
GET/POST/PUT/DELETE /api/admin/category    # 分类管理
GET/POST/PUT/DELETE /api/admin/dish        # 菜品管理
GET/POST/PUT/DELETE /api/admin/setmeal     # 套餐管理
GET/PUT /api/admin/order                   # 订单管理
```

### 用户端接口
```
GET /api/user/dish                    # 浏览菜品
GET/POST/PUT/DELETE /api/user/cart    # 购物车
POST /api/user/order                  # 提交订单
GET /api/user/order                   # 查看订单
GET/POST/PUT/DELETE /api/user/address # 地址管理
```

## 说明

此为后端项目基础框架，**只实现图片规划中的功能**。

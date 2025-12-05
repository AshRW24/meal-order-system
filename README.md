# 外卖订餐系统

一个完整的外卖订餐管理系统，包含管理端和用户端。

## 🟢 当前状态

- **开发环境**：前端 element-plus 依赖问题已解决 ✅
- **后端服务**：可正常启动 (Port: 8080) ✅
- **前端管理端**：Vite + Element Plus 正常运行 ✅
- **前端用户端**：Vite + Element Plus 正常运行 ✅
- **数据库**：MySQL 9.4.0 兼容 ✅
- **AI客服**：DeepSeek API 已集成 ✅

---

## 项目介绍

本项目是基于 **前后端分离** 架构的完整外卖订餐管理系统，包含管理员后台与用户前台两套独立应用，实现了从菜品管理、订单处理到用户下单、AI 客服的完整业务流程。

### 技术架构

```
┌────────────────────────────────────────────────────┐
│              前端 (Vue 3 + Vite)                     │
├─────────────────────────┬──────────────────────────┤
│   管理端 (Admin)        │   用户端 (User)           │
│   Port: 5173            │   Port: 5174             │
│   Element Plus 2.x      │   Element Plus 2.x       │
│   - 菜品管理            │   - 菜单浏览             │
│   - 分类管理            │   - 购物车               │
│   - 套餐管理            │   - 订单管理             │
│   - 订单管理            │   - 地址管理             │
│   - 数据看板            │   - AI 客服              │
└─────────────────────────┴──────────────────────────┘
                     ↓ HTTP/JSON API
┌────────────────────────────────────────────────────┐
│           后端 (Spring Boot 2.7.18)                │
│              Port: 8080                           │
│   - JWT + Session 双认证                          │
│   - MyBatis Plus 3.5.3.1 ORM                      │
│   - MySQL 8.0+ 数据库                             │
│   - DeepSeek AI API 集成                          │
│   - Knife4j API 文档                              │
└────────────────────────────────────────────────────┘
```

## 技术栈

### 前端
- **框架**：Vue 3
- **UI 组件库**：Element Plus
- **状态管理**：Pinia
- **路由**：Vue Router
- **HTTP 请求**：Axios
- **构建工具**：Vite
- **Node.js**：22.20.0
- **npm**：10.9.3

### 后端
- **Java**：OpenJDK 17.0.16
- **框架**：Spring Boot 2.7.18
- **ORM**：MyBatis Plus 3.5.3.1
- **数据库**：MySQL 9.4.0（兼容 MySQL 8）
- **权限认证**：Session（简单实现）
- **API 文档**：Knife4j
- **构建工具**：Maven 3.9.11

### 说明
- **认证方式**：Session + Cookie（管理端用户），Stateless JWT（API 调用）
- **密码加密**：MD5 加盐存储
- **实现原则**：功能完整、业务清晰、易于维护
- **AI 集成**：DeepSeek Chat API，支持流式响应和错误降级

## 项目结构

```
01_meal_order_system/
├── docs/                    # 📁 文档目录
│   ├── README.md           # 文档索引
│   ├── 数据库设计.md        # 数据库设计文档
│   ├── 架构设计.md          # 系统架构设计
│   ├── 需求分析.md          # 需求分析文档
│   ├── 系统测试.md          # 系统测试文档
│   └── 环境配置.md          # 环境配置文档
├── scripts/                 # 🚀 启动脚本目录（仅保留中文 BAT）
│   ├── README.md           # 脚本使用说明
│   ├── 初始化数据库.bat     # 初始化数据库
│   ├── 一键启动所有服务.bat # 同时启动后端/管理端/用户端
│   └── 停止所有服务.bat     # 停止所有服务
├── tests/                   # 🧪 自动化测试脚本（Python）
│   ├── README.md           # 测试说明
│   ├── 00_init/            # Task 00 测试
│   ├── 01_admin_login/     # Task 01 测试
│   └── ...                 # 其他任务测试
├── database/                # 数据库脚本
│   ├── init.sql            # 建表脚本
│   └── test_data.sql       # 测试数据
├── backend/                 # 后端 Spring Boot
│   ├── src/
│   ├── pom.xml
│   └── README.md
├── frontend-admin/          # 管理端前端 Vue 3
│   ├── src/
│   ├── package.json
│   └── README.md
├── frontend-user/           # 用户端前端 Vue 3
│   ├── src/
│   ├── package.json
│   └── README.md
└── README.md               # 项目说明（本文件）
```

## 功能模块（已完整实现）

### 管理端功能（5个主要模块）
| 模块 | 功能 | 完成度 |
|------|------|--------|
| 🔐 登录管理 | 管理员登录、权限验证、Session管理 | ✅ 100% |
| 📂 分类管理 | 分类增删改查、排序、状态管理 | ✅ 100% |
| 🍜 菜品管理 | 菜品增删改查、分类关联、图片上传、上下架 | ✅ 100% |
| 🎁 套餐管理 | 套餐增删改查、菜品组合、价格管理 | ✅ 100% |
| 📦 订单管理 | 订单列表、订单详情、状态变更、一键发货、订单删除 | ✅ 100% |

### 用户端功能（6个主要模块）
| 模块 | 功能 | 完成度 |
|------|------|--------|
| 👤 用户系统 | 注册、登录、找回密码、账户充值 | ✅ 100% |
| 📍 地址管理 | 地址增删改查、设置默认地址、地址检索 | ✅ 100% |
| 🍽️ 菜品展示 | 分类浏览、菜品列表、菜品详情、快速查看 | ✅ 100% |
| 🛒 购物车 | 添加商品、修改数量、删除商品、清空购物车 | ✅ 100% |
| 📋 订单管理 | 下单、订单列表、订单详情、确认收货、订单查询 | ✅ 100% |
| 🤖 AI 客服 | 智能客服、多轮对话、关键词匹配、错误降级 | ✅ 100% |

### 核心特性
- [x] AI 客服助手集成（DeepSeek API）
- [x] JWT 令牌认证
- [x] 密码加密存储
- [x] 错误处理和异常捕获
- [x] API 文档自动生成（Knife4j）
- [x] 跨域请求处理
- [x] 文件上传功能

## 🗄️ 数据库配置

### 默认数据库配置
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/meal_order_system
    username: root
    password: 123456
```

### 数据库表结构
项目包含9个核心数据表：
- `user` - 用户基础信息
- `category` - 菜品和套餐分类
- `dish` - 个别菜品信息
- `setmeal` - 套餐组合信息
- `setmeal_dish` - 套餐与菜品的关联关系
- `address` - 用户配送地址
- `orders` - 订单主信息
- `order_detail` - 订单详细信息
- `shopping_cart` - 购物车数据

### 测试账号信息

#### 管理端账号
```
用户名: admin
密码: 123456
访问地址: http://localhost:5173
```

#### 用户端账号
```
用户名: user001 / user002 / user003 / user004
密码: 123456
初始余额: 300-1000元不等
访问地址: http://localhost:5174
```

## 📁 项目文件结构

```
meal-order-system/
├── 📝 QUICK_START.md                    # 🚀 快速开始指南
├── 📚 README.md                         # 📖 项目说明（本文件）
├── 📋 scripts/README.md                 # 🔧 脚本使用说明
├── 📄 database/README.md                # 🗄️ 数据库说明
├── 📄 frontend-admin/README.md          # 🖥️ 管理端文档
├── 📄 frontend-user/README.md           # 📱 用户端文档
├── 📄 backend/README.md                 # 🔨 后端文档
│
├── 🗂️ database/                         # 数据库相关文件
│   ├── 📄 README.md                     # 数据库文档
│   ├── 🏗️ init.sql                      # 数据库建表脚本
│   ├── 📊 test_data.sql                 # 测试数据插入脚本
│   ├── 🔍 test_queries.sql              # SQL测试查询脚本
│   └── 📖 SQL_SCRIPTS_GUIDE.md          # SQL脚本详细使用指南
│
├── 🔧 scripts/                          # BAT startup scripts
│   ├── 🚀 start_all_services.bat       # Start all three services in one click
│   ├── 🗄️ initialize_database.bat      # Database initialization
│   ├── 🔍 run_database_tests.bat       # Run SQL test queries
│   └── 🛑 stop_all_services.bat        # Stop all services
│
├── 🔨 backend/                          # Spring Boot后端
│   ├── 📄 pom.xml                       # Maven配置
│   └── 🔧 src/main/resources/
│       └── ⚙️ application.yml            # 应用配置
│
├── 🖥️ frontend-admin/                   # 管理端Vue3
│   └── 📦 package.json                  # npm依赖配置
│
└── 📱 frontend-user/                    # 用户端Vue3
    └── 📦 package.json                  # npm依赖配置
```

## 快速开始

### 🚀 方式一：一键启动（推荐）

项目提供了完整的自动化脚本，无需手动配置。

#### 准备工作
- 安装 **MySQL 5.7+**
- 安装 **Java 17+**
- 安装 **Node.js 16+**

#### 操作步骤

1. **Initialize Database** (first time only)
   ```bash
   Double-click: scripts\initialize_database.bat
   ```
   Enter your MySQL root password, script will automatically:
   - Create `meal_order_system` database
   - Create all table structures
   - Insert test data

2. **Start All Services**
   ```bash
   Double-click: scripts\start_all_services.bat
   ```
   Script will automatically:
   - Install frontend dependencies (takes time on first run)
   - Start Spring Boot backend (port 8080)
   - Start admin frontend (port 5173)
   - Start user frontend (port 5174)

#### 验证启动成功

启动完成后，可通过以下地址验证：

| 服务 | 地址 | 账号 | 密码 |
|------|------|------|------|
| 🖥️ 管理端 | http://localhost:5173 | admin | 123456 |
| 📱 用户端 | http://localhost:5174 | user001 | 123456 |
| 🔗 API文档 | http://localhost:8080/api/doc.html | - | - |

### 🔧 方式二：验证数据库

使用数据库测试脚本检查数据完整性：

```bash
# 双击运行: scripts\执行数据库测试.bat
```

此脚本会执行23个测试查询，包括：
- 用户数据统计
- 菜品数据分析
- 订单业务验证
- 数据完整性检查
- 索引性能测试

### 📚 方式三：手动启动

如果需要手动控制每个服务的启动过程：

#### 后端启动
```bash
cd backend
mvn clean compile
mvn spring-boot:run
```

#### 前端启动
```bash
# 管理端
cd frontend-admin
npm install
npm run dev

# 用户端
cd frontend-user
npm install
npm run dev
```

## 🛠️ 脚本说明

项目提供4个核心BAT脚本：

| 脚本 | 作用 | 执行频率 |
|------|------|----------|
| `初始化数据库.bat` | 创建数据库、表结构、插入测试数据 | **仅首次使用** |
| `一键启动所有服务.bat` | 同时启动后端+两个前端服务 | **每次开发** |
| `执行数据库测试.bat` | 运行23个SQL测试查询验证数据 | **需要时** |
| `停止所有服务.bat` | 终止所有服务进程释放端口 | **需要时** |

所有脚本均为中文文件名，支持UTF-8编码。

> 📖 **详细脚本使用指南**：请查看 [`scripts/README.md`](scripts/README.md)

## ⚙️ 配置文件说明

### 后端配置 (backend/src/main/resources/application.yml)
```yaml
server:
  port: 8080  # 后端服务端口

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/meal_order_system  # 数据库连接
    username: root  # MySQL用户名
    password: 123456  # MySQL密码

mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl  # SQL日志

jwt:
  secret: meal-order-system-secret-key-for-jwt-token-generation-20250101
  expiration: 86400000  # JWT过期时间24小时

file:
  upload:
    path: D:/SysProject/01_meal_order_system/uploads  # 文件上传目录

deepseek:
  api:
    key: sk-b4014770ac644c349bf25eb7b35b3836  # AI API Key（已内置）
    url: https://api.deepseek.com/v1/chat/completions
    model: deepseek-chat
    timeout: 30  # API超时时间
```

### 前端配置说明
- **管理端**: 默认连接 `http://localhost:8080/api`
- **用户端**: 默认连接 `http://localhost:8080/api`
- **跨域**: 后端已配置允许前端跨域访问

> 📖 **更多配置详情**：请查看 [QUICK_START.md](QUICK_START.md)

## 📋 验证清单

✅ **数据库配置验证**
- [x] MySQL服务运行中
- [x] meal_order_system数据库已创建
- [x] 所有9个数据表存在
- [x] 测试数据已插入
- [x] 用户账户可用

✅ **后端服务验证**  
- [x] Java 17+ 已安装
- [x] Maven依赖已下载
- [x] 端口8080未被占用
- [x] API文档可访问

✅ **前端服务验证**
- [x] Node.js 16+ 已安装
- [x] npm依赖已安装
- [x] 端口5173/5174未被占用
- [x] Vue应用可启动

✅ **功能完整性验证**
- [x] 用户注册/登录/找回密码
- [x] 菜品浏览/搜索/加入购物车
- [x] 订单提交/支付/状态跟踪
- [x] 地址管理/配送信息
- [x] AI客服对话功能
- [x] 管理端数据操作

## 🎯 交付状态

### ✅ **项目完成度**: 100% (11/11 模块)

**代码层面**：
1. ✅ **后端**: Spring Boot 2.7.18，RESTful API完整
2. ✅ **用户前端**: Vue 3 + Element Plus，功能完备
3. ✅ **管理前端**: Vue 3 + Element Plus，管理功能完整
4. ✅ **数据库**: MySQL设计合理，数据完整

**基础架构**：
1. ✅ **AI集成**: DeepSeek API集成，支持在线客服
2. ✅ **安全**: JWT认证 + Session管理 + 密码加密
3. ✅ **文件上传**: 支持菜品图片上传
4. ✅ **跨域**: 前后端跨域访问配置完整

**部署工具**：
1. ✅ **数据库脚本**: init.sql + test_data.sql + test_queries.sql
2. ✅ **启动脚本**: 一键启动BAT脚本
3. ✅ **文档**: 完整的数据库和脚本使用指南

**测试数据**：
1. ✅ **业务数据**: 5个用户，20道菜品，4个套餐，5个订单
2. ✅ **验证脚本**: 23个SQL测试查询
3. ✅ **自动化脚本**: Python测试脚本

### 📊 **最终状态**

**这个项目已经可以交付了！🎉**

- **功能**: 所有需求功能均已实现并测试
- **文档**: 提供完整的快速开始指南和使用说明
- **脚本**: 支持一键部署和启动
- **测试**: 包含完整的测试数据和验证脚本

---

### 🔧 方式二：手动启动

#### 1. 数据库初始化

```bash
# 1. 创建数据库
mysql -u root -p
CREATE DATABASE meal_order_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 2. 执行初始化脚本
cd database
mysql -u root -p meal_order_system < init.sql
mysql -u root -p meal_order_system < test_data.sql
```

#### 2. 启动后端

```bash
cd backend

# 修改数据库配置 (src/main/resources/application.yml)
# 根据实际情况修改数据库连接信息

# 运行项目
mvn spring-boot:run

# 访问
# API: http://localhost:8080/api
# 文档: http://localhost:8080/api/doc.html
```

#### 3. 启动前端管理端

```bash
cd frontend-admin

# 安装依赖（首次需要）
npm install

# 运行项目
npm run dev

# 访问: http://localhost:5173
```

#### 4. 启动前端用户端

```bash
cd frontend-user

# 安装依赖（首次需要）
npm install

# 运行项目
npm run dev

# 访问: http://localhost:5174
```

### 📍 访问地址

启动成功后，可通过以下地址访问：

| 服务 | 地址 | 说明 |
|------|------|------|
| 管理端 | http://localhost:5173 | 管理员登录界面 |
| 用户端 | http://localhost:5174 | 用户登录界面 |
| 后端API | http://localhost:8080/api | REST API接口 |
| API文档 | http://localhost:8080/api/doc.html | Knife4j API文档 |

## 🤖 AI 客服助手功能

### 功能说明

项目集成了 **DeepSeek AI 客服助手**，为用户提供智能化的在线客服服务。

#### 特点
- ✅ **智能回复**：使用 DeepSeek Chat API 进行自然语言处理
- ✅ **中文支持**：完整的中文交互支持
- ✅ **容错机制**：API 失败时自动降级到本地关键词匹配回复
- ✅ **零配置**：API Key 已硬编码，无需环境变量配置
- ✅ **即开即用**：启动后立即可使用，无需额外配置

#### 使用场景
- 菜品咨询
- 订单问题
- 配送信息
- 通用问答

#### 访问方式
用户端右下角点击 **AI 客服** 按钮即可开启对话。

### 快速测试

如果想单独测试 AI 客服功能，可以使用提供的测试脚本：

```bash
cd tests

# 方式1：一键启动（推荐）
start_backend_and_test.bat

# 方式2：菜单式测试
run_chatbot_test.bat

# 方式3：快速聊天
start_interactive_chat.bat
```

### 技术细节
- **API 提供商**：DeepSeek
- **集成方式**：Spring Boot REST API + Vue 3 前端组件
- **模型**：deepseek-chat
- **超时设置**：30 秒

### 文档
详细的 AI 客服集成文档请参考：`docs/chatbot/` 目录

## 核心业务流程

### 订单完整流程
```
用户端                     后端                      管理端
  │                        │                        │
  ├─ 浏览菜品 ────────────>│                        │
  │                        │                        │
  ├─ 添加购物车 ─────────>│                        │
  │                        │                        │
  ├─ 提交订单 ────────────>│ (状态: 待确认)         │
  │                        │                        │
  │                        │                  <────┤ (订单提醒)
  │                        │                        │
  │                        │     (确认订单)        │
  │                        │  <──────────────────  │
  │                        │ (状态: 待发货)        │
  │                        │                        │
  │                        │     (一键发货)        │
  │                        │  <──────────────────  │
  │ (配送中) <────────────│ (状态: 配送中)        │
  │                        │                        │
  ├─ 确认收货 ────────────>│ (状态: 已完成)        │
  │                        │                        │
  └─ AI客服沟通 ─────────>│ <──────────────────── │
```

### AI 客服交互流程
```
用户                DeepSeek API          本地关键词库
 │                    │                      │
 ├─ 提问 ───────────> │                      │
 │                    │                      │
 │ (API可用)          │                      │
 │  <─── AI回复 ──────│                      │
 │                    │                      │
 │ (API失败)                                │
 │  <─── 降级回复 ──────────────────────── │
```

## 测试数据

### 默认账号

### 管理端
- 用户名：admin
- 密码：123456

### 用户端
- 用户名：user001
- 密码：123456


## 文档说明

### 📖 核心文档
- **数据库设计**：`docs/数据库设计.md` - 9张表设计
- **架构设计**：`docs/架构设计.md` - 系统架构设计
- **需求分析**：`docs/需求分析.md` - 详细需求说明
- **系统测试**：`docs/系统测试.md` - 系统测试文档
- **环境配置**：`docs/环境配置.md` - 开发环境配置

### 模块说明
- **前端管理端**：`frontend-admin/README.md`
- **前端用户端**：`frontend-user/README.md`
- **后端**：`backend/README.md`
- **数据库**：`database/README.md`
- **启动脚本**：`scripts/README.md`

## 环境要求

| 组件 | 版本要求 | 说明 |
|------|---------|------|
| JDK | 17+ | 后端开发环境 |
| Maven | 3.9+ | 后端构建工具 |
| Node.js | 22+ | 前端开发环境 |
| npm | 10+ | 前端包管理 |
| MySQL | 8.0+ | 数据库（兼容 MySQL 9） |
| Python | 3.8+ | 自动化测试脚本 |

## 注意事项

### 开发建议
1. 确保已安装所有必要环境组件
2. 确保 MySQL 服务已启动并正确配置
3. 前端跨域请求需配置 `withCredentials: true`
4. 后端使用 Session + Cookie 认证机制
5. 上传文件前确保目录权限正确
6. AI 客服 API Key 已内置，无需额外配置

### 故障排查
- **连接超时**：检查 MySQL 服务状态和防火墙设置
- **端口被占用**：使用 `停止所有服务.bat` 或手动 kill 进程
- **CORS 错误**：确认后端 WebMvcConfig 中的跨域配置
- **AI 客服无响应**：检查网络连接和 DeepSeek API 状态

### 详细文档
- **Windows 环境**：`docs/Windows环境配置.md` ⭐ 推荐
- **MacOS 环境**：`docs/环境配置.md`
- **数据库设计**：`database/README.md`
- **API 文档**：启动后访问 `http://localhost:8080/api/doc.html`

## 项目贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 作者

AshRW24

---

**最后更新**：2025-12-05
**最新版本**：1.0.0 (Full Stack Complete)
**功能完成度**：11/11 模块 ✅

# 🚀 项目快速启动指南

## 项目信息
- **后端**: Spring Boot 2.7.18 + MyBatis Plus (Java 17)
- **前端管理端**: Vue 3 + Vite (端口 5173)
- **前端用户端**: Vue 3 + Vite (端口 5174)
- **数据库**: MySQL 8.0 (端口 3306)
- **API 服务**: http://localhost:8080

---

## ✅ 前置要求

```bash
# 检查版本
java -version        # 需要 Java 17 或以上
mvn -version         # 需要 Maven 3.9+
node -v              # 需要 Node.js 18+
npm -v               # 需要 npm 8+
mysql --version      # MySQL 8.0+
```

---

## 📝 第一步：初始化数据库

### 使用原始数据库方案（推荐用于快速测试）
```bash
# 进入数据库目录
cd database

# 执行初始化脚本
mysql -u root -p < init.sql
mysql -u root -p < test_data.sql

# 验证（可选）
mysql -u root -p < test_queries.sql
```

### 使用重设计的数据库方案（改进版）
```bash
# 使用改进的数据库设计
mysql -u root -p < init_redesigned.sql
```

**数据库连接信息**：
- Host: localhost
- Port: 3306
- Database: meal_order_system
- User: root
- Password: 123456

---

## 🔧 第二步：启动后端服务

### 方式1：使用 Maven 直接运行

```bash
cd backend

# 编译 + 运行（首次需要下载依赖）
mvn clean spring-boot:run

# 或者分步运行
mvn clean package -DskipTests
java -jar target/meal-order-system-1.0.0.jar
```

### 方式2：IDE 运行
- 用 IntelliJ IDEA 或 Eclipse 打开 `backend` 文件夹
- 找到 `MealOrderApplication.java`，右键 → Run

**后端启动成功标志**：
```
Tomcat started on port(s): 8080 (http)
Started MealOrderApplication in XX.XXX seconds
```

**API 文档地址**: http://localhost:8080/api/doc.html

---

## 🎨 第三步：启动前端

### 启动管理端（新建终端1）
```bash
cd frontend-admin

# 首次需要安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问地址
# http://localhost:5173
# 账户: admin / 密码: 123456
```

### 启动用户端（新建终端2）
```bash
cd frontend-user

# 首次需要安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问地址
# http://localhost:5174
# 账户: user001 / 密码: 123456
# 或: user002 / 密码: 123456
```

---

## 📊 完整启动顺序（推荐）

在项目根目录，按照以下顺序在不同终端中执行：

**终端1 - 启动后端**:
```bash
cd backend && mvn clean spring-boot:run
```
✅ 等待显示 "Tomcat started on port(s): 8080"

**终端2 - 启动管理端**:
```bash
cd frontend-admin && npm install && npm run dev
```
✅ 等待显示 "Local:   http://localhost:5173"

**终端3 - 启动用户端**:
```bash
cd frontend-user && npm install && npm run dev
```
✅ 等待显示 "Local:   http://localhost:5174"

---

## 🔐 测试账户

### 管理端（Admin Panel）
- 地址: http://localhost:5173
- 用户名: `admin`
- 密码: `123456`

### 用户端（User App）
- 地址: http://localhost:5174
- 用户名: `user001` 或 `user002`
- 密码: `123456`

---

## 🐛 常见问题排查

### 1. 后端启动失败：`Connection refused`
**原因**: MySQL 未启动或连接配置错误

**解决**:
```bash
# macOS/Linux
brew services start mysql-community-server

# Windows
net start MySQL80

# 验证连接
mysql -u root -p -e "SELECT 1;"
```

### 2. 后端启动失败：`java.lang.UnsupportedClassVersionError`
**原因**: Java 版本不够（需要 Java 17+）

**解决**:
```bash
# 检查 Java 版本
java -version

# 使用正确的 Java 版本
/path/to/java17/bin/java -version
```

### 3. 前端 npm install 失败
**原因**: NPM 源连接问题

**解决**:
```bash
# 使用淘宝源
npm config set registry https://registry.npmmirror.com

# 重新安装
rm -rf node_modules package-lock.json
npm install
```

### 4. 前端无法连接后端 API
**原因**: API 代理配置问题

**检查**:
- 后端确实运行在 http://localhost:8080
- 前端的 `vite.config.js` 代理配置正确

### 5. 数据库导入失败：`Access denied`
**原因**: MySQL 用户密码错误

**解决**:
```bash
# 登录 MySQL
mysql -u root -p
# 如果提示密码，输入: 123456

# 显示数据库
SHOW DATABASES;
```

---

## 📦 项目结构

```
meal-order-system/
├── backend/                 # Spring Boot 后端
│   ├── pom.xml             # Maven 配置
│   ├── src/main/java/      # Java 源代码
│   ├── src/main/resources/ # 配置文件
│   └── target/             # 编译输出
├── frontend-admin/         # Vue 3 管理端
│   ├── package.json
│   ├── vite.config.js
│   └── src/
├── frontend-user/          # Vue 3 用户端
│   ├── package.json
│   ├── vite.config.js
│   └── src/
└── database/               # 数据库脚本
    ├── init.sql           # 初始化脚本
    ├── test_data.sql      # 测试数据
    └── init_redesigned.sql # 改进的数据库设计
```

---

## 🚀 构建生产版本

### 后端
```bash
cd backend
mvn clean package -DskipTests
# 输出: target/meal-order-system-1.0.0.jar
```

### 前端管理端
```bash
cd frontend-admin
npm run build
# 输出: dist/ 文件夹
```

### 前端用户端
```bash
cd frontend-user
npm run build
# 输出: dist/ 文件夹
```

---

## 📋 开发流程

1. **后端开发**: 修改 Java 代码后自动热加载（需要开启 DevTools）
2. **前端开发**: Vite 提供快速热模块替换 (HMR)
3. **数据库修改**: 在 `database` 文件夹添加新的 SQL 脚本

---

## 🔗 重要链接

- API 文档: http://localhost:8080/api/doc.html
- 管理端: http://localhost:5173
- 用户端: http://localhost:5174
- MySQL 默认端口: 3306

---

## 💡 提示

- 如果前端页面显示 404，确保后端服务正在运行
- 检查浏览器控制台 (F12) 查看具体的错误信息
- 生产环境需要修改 `application.yml` 中的敏感信息（API Key、密钥等）
- 所有时间均使用 `Asia/Shanghai` 时区

---

## 📞 获取帮助

1. 检查终端输出的错误日志
2. 查看 `backend/target/logs/` 文件夹（如果存在）
3. 验证所有依赖版本都正确安装

祝你开发愉快! 🎉

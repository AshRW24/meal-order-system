# 启动脚本说明

本目录包含项目的启动脚本，所有脚本均使用**相对路径**，可在任意位置运行。

## 🚀 快速开始

1. **初始化数据库**（首次使用或结构不一致时）：双击运行 `初始化数据库.bat`，脚本会依次创建数据库、建表并导入测试数据。
2. **启动所有服务**（后端 + 管理端 + 用户端）：双击运行 `一键启动所有服务.bat`，脚本会自动安装前端依赖并依次打开三个窗口。
3. **停止所有服务**：测试结束或需要重启时，双击 `停止所有服务.bat`，会释放 8080/5173/5174 端口。

## 📋 脚本列表

仅保留三份中文 BAT 脚本（UTF-8 编码）：

| 脚本 | 说明 |
|------|------|
| `初始化数据库.bat` | 初始化数据库结构 + 测试数据（首次运行必做） |
| `一键启动所有服务.bat` | 启动后端、管理端、用户端并自动安装依赖 |
| `停止所有服务.bat` | 杀掉上述服务占用的端口，便于重新启动 |

## 🌐 默认端口

- **后端服务**: http://localhost:8080
- **后端 API 文档**: http://localhost:8080/api/doc.html
- **管理端**: http://localhost:5173
- **用户端**: http://localhost:5174

## ❓ 常见问题

### 1. 端口被占用
**错误**：`Port 8080 is already in use`

**解决方案**：

```batch
REM 双击运行停止脚本
.\\scripts\\停止所有服务.bat
```

### 2. 前端依赖未安装
**错误**：`'vite' 不是内部或外部命令`

**解决方案**：

直接运行 `一键启动所有服务.bat`，脚本会自动检查并安装依赖。

### 3. 脚本无法找到项目目录
所有脚本使用相对路径，确保：

- 脚本位于 `scripts/` 目录下
- 项目包含 `backend/`、`frontend-admin/`、`frontend-user/` 目录

## 🌐 默认端口

- **后端服务**: http://localhost:8080
- **后端 API 文档**: http://localhost:8080/api/doc.html
- **管理端**: http://localhost:5173
- **用户端**: http://localhost:5174

## ❓ 常见问题

### 1. 端口被占用
**错误**: `Port 8080 is already in use` 或 `端口 8080 已被占用`

**解决方案**:
```batch
REM 方法1: 双击运行停止脚本（最简单）
.\scripts\停止所有服务.bat

REM 方法2: 手动查找并关闭进程
netstat -ano | findstr :8080
taskkill /F /PID <进程ID>
```

### 2. JAR 文件找不到
**错误**: `Unable to access jarfile target\*.jar` 或 `未找到 JAR 文件`

**解决方案**:
```batch
REM 先编译项目
cd backend
mvn clean package

REM 然后双击运行 JAR 启动脚本
.\scripts\使用JAR启动后端.bat
```

### 3. 前端依赖未安装
**错误**: 启动前端时报错，提示 `'vite' 不是内部或外部命令`

**解决方案**（自动处理）:
最新的启动脚本已支持自动检查并安装依赖，直接运行即可：
```batch
.\scripts\一键启动所有服务.bat
REM 或
.\scripts\启动管理端.bat
.\scripts\启动用户端.bat
```

**手动安装**（如果需要）:
```bash
# 安装管理端依赖
cd frontend-admin
npm install

# 安装用户端依赖
cd frontend-user
npm install
```

### 4. 脚本无法找到项目目录
**解决方案**: 
所有脚本已更新为使用相对路径，无论项目放在哪个位置都能正常运行。如果遇到问题，请确保：
- 脚本文件位于 `scripts/` 目录下
- 项目结构完整（包含 `backend/`, `frontend-admin/`, `frontend-user/` 目录）

## 🔧 环境要求

确保已安装以下环境：
- **Java**: 8 或更高版本
- **Maven**: 3.6+
- **Node.js**: 16+ 和 npm
- **MySQL**: 5.7+ (数据库服务需要先启动)

## 💾 数据库配置

确保 MySQL 数据库已启动，并创建了数据库：
```sql
CREATE DATABASE meal_order_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

默认配置（可在 `backend/src/main/resources/application.yml` 修改）：
- 地址: localhost:3306
- 数据库: meal_order_system
- 用户名: root
- 密码: 123456

## 📝 脚本特性

- ✅ **相对路径支持**：所有脚本使用相对路径，项目可放在任意位置
- ✅ **自动依赖检查**：前端脚本自动检查并安装依赖
- ✅ **端口占用检测**：后端启动脚本自动检测端口占用
- ✅ **中文界面**：所有提示信息均为中文，易于理解

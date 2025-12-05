#!/bin/bash

# ============================================================
# 外卖订餐系统 - 一键启动脚本（macOS/Linux）
# ============================================================

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=========================================="
echo "🚀 外卖订餐系统启动脚本"
echo "=========================================="
echo ""

# 检查 Java 版本
echo "✓ 检查 Java 版本..."
if ! command -v java &> /dev/null; then
    echo "❌ 未找到 Java，请先安装 Java 17 或以上版本"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | grep -oE 'version "[0-9]' | grep -oE '[0-9]+')
if [ "$JAVA_VERSION" -lt 17 ]; then
    echo "❌ Java 版本过低，需要 Java 17 或以上，当前版本：$JAVA_VERSION"
    exit 1
fi
echo "✅ Java 版本正确 ($JAVA_VERSION)"

# 检查 Maven
echo "✓ 检查 Maven..."
if ! command -v mvn &> /dev/null; then
    echo "❌ 未找到 Maven，请先安装 Maven 3.9+"
    exit 1
fi
echo "✅ Maven 已安装"

# 检查 Node.js
echo "✓ 检查 Node.js..."
if ! command -v node &> /dev/null; then
    echo "❌ 未找到 Node.js，请先安装 Node.js 18+"
    exit 1
fi
echo "✅ Node.js 已安装"

# 检查 MySQL
echo "✓ 检查 MySQL..."
if ! command -v mysql &> /dev/null; then
    echo "❌ 未找到 MySQL，请先安装 MySQL 8.0+"
    exit 1
fi
echo "✅ MySQL 已安装"

echo ""
echo "=========================================="
echo "📦 启动步骤"
echo "=========================================="
echo ""

# 编译后端
echo "1️⃣  正在编译后端服务..."
cd "$PROJECT_ROOT/backend"
mvn clean package -DskipTests > /dev/null 2>&1 &
BACKEND_BUILD_PID=$!

# 等待后端编译完成
wait $BACKEND_BUILD_PID
if [ $? -eq 0 ]; then
    echo "✅ 后端编译完成"
else
    echo "❌ 后端编译失败"
    exit 1
fi

echo ""
echo "=========================================="
echo "🎯 在新的终端标签页中启动服务"
echo "=========================================="
echo ""
echo "请按照以下步骤操作："
echo ""
echo "【终端1 - 启动后端服务】"
echo "cd \"$PROJECT_ROOT/backend\""
echo "mvn spring-boot:run"
echo ""
echo "【终端2 - 启动管理端】"
echo "cd \"$PROJECT_ROOT/frontend-admin\""
echo "npm install && npm run dev"
echo ""
echo "【终端3 - 启动用户端】"
echo "cd \"$PROJECT_ROOT/frontend-user\""
echo "npm install && npm run dev"
echo ""
echo "=========================================="
echo "📱 访问地址"
echo "=========================================="
echo "🔧 API 文档:  http://localhost:8080/api/doc.html"
echo "👨‍💼 管理端:   http://localhost:5173 (admin/123456)"
echo "👤 用户端:   http://localhost:5174 (user001/123456)"
echo ""

# 提示用户选择启动方式
read -p "是否自动打开浏览器预览这些地址? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sleep 2
    open "http://localhost:8080/api/doc.html"
    sleep 1
    open "http://localhost:5173"
    sleep 1
    open "http://localhost:5174"
fi

echo ""
echo "✨ 启动准备完成！"
echo "请在新的终端标签页中运行上述命令来启动各个服务。"
echo ""

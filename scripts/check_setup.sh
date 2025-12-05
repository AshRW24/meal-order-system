#!/bin/bash

# ============================================================
# 项目环境检查脚本
# ============================================================

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  🔍 外卖订餐系统 - 环境检查                 ║"
echo "╚════════════════════════════════════════════╝"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_command() {
    if command -v "$1" &> /dev/null; then
        VERSION=$($1 --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓${NC} $1: $VERSION"
        return 0
    else
        echo -e "${RED}✗${NC} $1: 未安装"
        return 1
    fi
}

echo "【系统环境检查】"
echo ""

# 检查 Java
JAVA_OK=0
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | grep -oE 'version "[0-9]' | grep -oE '[0-9]+')
    if [ "$JAVA_VERSION" -ge 17 ]; then
        echo -e "${GREEN}✓${NC} Java: $(java -version 2>&1 | head -n 1)"
        JAVA_OK=1
    else
        echo -e "${RED}✗${NC} Java 版本过低 (当前: $JAVA_VERSION，需要: 17+)"
    fi
else
    echo -e "${RED}✗${NC} Java: 未安装 (需要 Java 17+)"
fi

echo ""

# 检查其他工具
check_command "mvn"
check_command "node"
check_command "npm"
check_command "mysql"
check_command "git"

echo ""
echo "【项目结构检查】"
echo ""

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2 (不存在)"
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2 (不存在)"
    fi
}

check_dir "$PROJECT_ROOT/backend" "后端源代码"
check_file "$PROJECT_ROOT/backend/pom.xml" "后端 pom.xml"
check_dir "$PROJECT_ROOT/frontend-admin" "前端管理端"
check_file "$PROJECT_ROOT/frontend-admin/package.json" "管理端 package.json"
check_dir "$PROJECT_ROOT/frontend-user" "前端用户端"
check_file "$PROJECT_ROOT/frontend-user/package.json" "用户端 package.json"
check_dir "$PROJECT_ROOT/database" "数据库脚本"
check_file "$PROJECT_ROOT/database/init.sql" "数据库初始化脚本"

echo ""
echo "【数据库连接检查】"
echo ""

if command -v mysql &> /dev/null; then
    if mysql -u root -p123456 -e "SELECT 1;" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} MySQL 可以连接 (localhost:3306)"

        # 检查数据库是否存在
        if mysql -u root -p123456 -e "USE meal_order_system;" > /dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} 数据库已初始化 (meal_order_system)"

            # 检查表数量
            TABLE_COUNT=$(mysql -u root -p123456 -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='meal_order_system';" 2>&1 | tail -n 1)
            echo -e "${GREEN}✓${NC} 数据库表数: $TABLE_COUNT"
        else
            echo -e "${YELLOW}⚠${NC} 数据库未初始化 (meal_order_system)"
            echo "   请运行: mysql -u root -p < database/init.sql"
        fi
    else
        echo -e "${RED}✗${NC} MySQL 连接失败"
        echo "   检查 MySQL 是否已启动："
        echo "   - macOS: brew services start mysql-community-server"
        echo "   - Linux: systemctl start mysql"
        echo "   - Windows: net start MySQL80"
    fi
else
    echo -e "${YELLOW}⚠${NC} MySQL 未安装"
fi

echo ""
echo "【编译检查】"
echo ""

if [ -d "$PROJECT_ROOT/backend/target" ]; then
    if [ -f "$PROJECT_ROOT/backend/target/meal-order-system-1.0.0.jar" ]; then
        echo -e "${GREEN}✓${NC} 后端 JAR 已编译"
    else
        echo -e "${YELLOW}⚠${NC} 后端未编译"
        echo "   请运行: cd backend && mvn clean package"
    fi
else
    echo -e "${YELLOW}⚠${NC} 后端未编译"
    echo "   请运行: cd backend && mvn clean package"
fi

echo ""
echo "【依赖检查】"
echo ""

if [ -d "$PROJECT_ROOT/frontend-admin/node_modules" ]; then
    echo -e "${GREEN}✓${NC} 管理端依赖已安装"
else
    echo -e "${YELLOW}⚠${NC} 管理端依赖未安装"
    echo "   请运行: cd frontend-admin && npm install"
fi

if [ -d "$PROJECT_ROOT/frontend-user/node_modules" ]; then
    echo -e "${GREEN}✓${NC} 用户端依赖已安装"
else
    echo -e "${YELLOW}⚠${NC} 用户端依赖未安装"
    echo "   请运行: cd frontend-user && npm install"
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║  检查完成                                    ║"
echo "╚════════════════════════════════════════════╝"
echo ""

if [ $JAVA_OK -eq 1 ]; then
    echo "下一步，请运行启动脚本:"
    echo "  bash scripts/start_all_services.sh"
else
    echo "❌ 请先安装或升级 Java 版本"
fi

echo ""

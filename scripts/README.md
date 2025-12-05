# Startup Scripts Guide

This directory contains the project's startup scripts, all using **relative paths** and can be run from any location.

## 🚀 Quick Start

1. **Initialize Database** (first time or structure inconsistency): Double-click run `initialize_database.bat`, script will create database, tables and import test data sequentially.
2. **Start All Services** (backend + admin frontend + user frontend): Double-click run `start_all_services.bat`, script will automatically install frontend dependencies and open three windows sequentially.
3. **Stop All Services**: When testing is complete or needs restart, double-click `stop_all_services.bat`, will release 8080/5173/5174 ports.

## 📋 Script List

Four BAT scripts that support UTF-8 encoding:

| Script | Description |
|--------|-------------|
| `initialize_database.bat` | Initialize database structure + test data (required for first run) |
| `start_all_services.bat` | Start backend, admin frontend, user frontend and automatically install dependencies |
| `stop_all_services.bat` | Kill processes using the above ports to allow restart |
| `run_database_tests.bat` | Execute database test queries to verify data integrity |

## 🌐 Default Ports

- **Backend Service**: http://localhost:8080
- **Backend API Docs**: http://localhost:8080/api/doc.html
- **Admin Frontend**: http://localhost:5173
- **User Frontend**: http://localhost:5174

## ❓ FAQ

### 1. Port Occupied
**Error**：`Port 8080 is already in use`

**Solution**：

```batch
REM Double-click to run stop script
.\scripts\stop_all_services.bat
```

### 2. Frontend Dependencies Not Installed
**Error**：`'vite' is not recognized as an internal or external command`

**Solution**：

Run `start_all_services.bat` directly, the script will automatically check and install dependencies.


## 🔧 Environment Requirements

Ensure the following environments are installed:
- **Java**: 8 or higher
- **Maven**: 3.6+
- **Node.js**: 16+ and npm
- **MySQL**: 5.7+ (database service needs to be started)

## 💾 Database Configuration

Ensure MySQL database is started and database is created:
```sql
CREATE DATABASE meal_order_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Default configuration (can be modified in `backend/src/main/resources/application.yml`):
- Host: localhost:3306
- Database: meal_order_system
- Username: root
- Password: 123456

## 📝 Script Features

- ✅ **Relative Path Support**: All scripts use relative paths, project can be placed anywhere
- ✅ **Automatic Dependency Check**: Frontend scripts automatically check and install dependencies
- ✅ **Port Occupation Detection**: Backend startup scripts detect port occupation
- ✅ **English Interface**: All prompt messages are in English for international use

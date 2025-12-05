# Database Initialization Guide

## Quick Start

### Option 1: Run BAT Script (Recommended)

Double-click the script:
```
..\scripts\init-database.bat
```

It will:
1. Create database `meal_order_system`
2. Create all tables
3. Insert test data

### Option 2: Manual Execution

```bash
# 1. Execute init script
mysql -u root -p < init.sql

# 2. Execute test data script
mysql -u root -p < test_data.sql
```

## Test Accounts

After initialization, you can login with:

### Admin Account (for Management Portal)
- Username: `admin`
- Password: `123456`
- URL: http://localhost:5173

### User Accounts (for User Portal)
- Username: `user001` or `user002`
- Password: `123456`
- URL: http://localhost:5174

## Database Configuration

Default settings (configured in `backend/src/main/resources/application.yml`):
- Host: `localhost:3306`
- Database: `meal_order_system`
- Username: `root`
- Password: `123456`

If your MySQL configuration is different, please update the `application.yml` file.

## Database Structure

### Tables

1. **user** - User accounts (both admin and regular users)
2. **category** - Food and setmeal categories
3. **dish** - Individual dishes
4. **setmeal** - Meal sets/combos
5. **setmeal_dish** - Relationship between setmeals and dishes
6. **orders** - Customer orders
7. **order_detail** - Order line items
8. **shopping_cart** - Shopping cart items
9. **address** - Delivery addresses

### Test Data Summary

- 3 Users (1 admin + 2 regular users)
- 8 Categories (6 dish categories + 2 setmeal categories)
- 17 Dishes
- 4 Setmeals
- 3 Sample orders
- 3 Delivery addresses

## Troubleshooting

### Error: Access denied for user 'root'
Your MySQL password is incorrect. Update the password in:
- `backend/src/main/resources/application.yml`
- When running `init-database.bat`, enter the correct password

### Error: Unknown database
The database hasn't been created. Run `init.sql` first.

### Error: Table already exists
The tables already exist. You can:
1. Drop the database: `DROP DATABASE meal_order_system;`
2. Re-run the init script

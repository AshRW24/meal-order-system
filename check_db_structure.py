import pymysql

# 数据库连接信息
config = {
    'host': 'localhost',
    'port': 3306,
    'user': 'root',
    'password': 'password',
    'database': 'meal_order_system',
    'charset': 'utf8mb4'
}

try:
    # 连接数据库
    connection = pymysql.connect(**config)
    cursor = connection.cursor()
    
    # 查询shopping_cart表的结构
    cursor.execute("DESCRIBE shopping_cart")
    
    print("shopping_cart表结构:")
    print("+---------------+------------------+------+-----+-------------------+-------------------+")
    print("| Field         | Type             | Null | Key | Default           | Extra             |")
    print("+---------------+------------------+------+-----+-------------------+-------------------+")
    
    for row in cursor.fetchall():
        field, type_, null, key, default, extra = row
        print(f"| {field:<13} | {type_:<16} | {null:<4} | {key:<3} | {default:<19} | {extra:<19} |")
    
    print("+---------------+------------------+------+-----+-------------------+-------------------+")
    
    # 查询当前数据库中的所有表
    cursor.execute("SHOW TABLES")
    print("\n数据库中的所有表:")
    for table in cursor.fetchall():
        print(f"- {table[0]}")
        
except pymysql.Error as e:
    print(f"数据库错误: {e}")
finally:
    if 'connection' in locals():
        connection.close()
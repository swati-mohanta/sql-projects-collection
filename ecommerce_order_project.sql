mysql> CREATE DATABASE ecommerce_db;
Query OK, 1 row affected (0.01 sec)

mysql> USE ecommerce_db;
Database changed
mysql> CREATE TABLE customers (
    -> customer_id INT PRIMARY KEY,
    -> name VARCHAR(50),
    -> email VARCHAR(100),
    -> join_date DATE
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> CREATE TABLE products (
    -> product_id INT PRIMARY KEY,
    -> name VARCHAR(50),
    -> category VARCHAR(30),
    -> price DECIMAL(10,2),
    -> stock INT
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> CREATE TABLE orders (
    -> order_id INT PRIMARY KEY,
    -> customer_id INT,
    -> order_date DATE,
    -> total_amount DECIMAL(10,2),
    -> FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    -> );
Query OK, 0 rows affected (0.04 sec)

mysql> CREATE TABLE order_items (
    -> order_item_id INT PRIMARY KEY,
    -> order_id INT ,
    -> product_id INT,
    -> quantity INT,
    -> price DECIMAL(10,2),
    -> FOREIGN KEY (order_id) REFERENCES orders(order_id),
    -> FOREIGN KEY (product_id) REFERENCES products(product_id)
    -> );
Query OK, 0 rows affected (0.05 sec)

mysql> INSERT INTO customers VALUES
    -> (1, 'Amit Sharma', 'amit@gmail.com', '2023-01-10'),
    -> (2, 'Neha Singh', 'neha@gmail.com', '2023-03-05');
Query OK, 2 rows affected (0.01 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> INSERT INTO products VALUES
    -> (101, 'Laptop', 'Electronics', 55000.00, 10),
    -> (102, 'Headphones', 'Electronics', 1500.00, 50),
    -> (103, 'Notebook', 'Stationery', 50.00, 100);
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> INSERT INTO orders VALUES
    -> (1001, 1, '2024-09-01', 56550.00),
    -> (1002, 2, '2024-09-03', 1600.00);
Query OK, 2 rows affected (0.01 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> INSERT INTO order_items VALUES
    -> (1, 1001, 101, 1, 55000.00),
    -> (2, 1001, 102, 1, 1500.00),
    -> (3, 1002, 102, 1, 1500.00),
    -> (4, 1002, 103, 2, 50.00);
Query OK, 4 rows affected (0.00 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> SELECT o.order_id, c.name, o.total_amount
    -> FROM  orders o
    -> JOIN customers c ON o.customer_id = c.customer_id;
+----------+-------------+--------------+
| order_id | name        | total_amount |
+----------+-------------+--------------+
|     1001 | Amit Sharma |     56550.00 |
|     1002 | Neha Singh  |      1600.00 |
+----------+-------------+--------------+
2 rows in set (0.00 sec)

mysql> SELECT p.name, oi.quantity, oi.price
    -> FROM order_items oi
    -> JOIN products p ON oi.product_id = p.product_id
    -> WHERE oi.order_id = 1001;
+------------+----------+----------+
| name       | quantity | price    |
+------------+----------+----------+
| Laptop     |        1 | 55000.00 |
| Headphones |        1 |  1500.00 |
+------------+----------+----------+
2 rows in set (0.00 sec)

mysql> SELECT p.name, SUM(oi.quantity * oi.price) AS total_revenue
    -> FROM order_items oi
    -> JOIN products p ON oi.product_id = p.product_id
    -> GROUP BY p.name;
+------------+---------------+
| name       | total_revenue |
+------------+---------------+
| Laptop     |      55000.00 |
| Headphones |       3000.00 |
| Notebook   |        100.00 |
+------------+---------------+
3 rows in set (0.01 sec)

mysql> SELECT c.name, COUNT(o.order_id) AS orders_count
    -> FROM customers c
    -> JOIN orders o ON c.customer_id = o.customer_id
    -> GROUP BY c.name
    -> HAVING COUNT(o.order_id) > 1;
Empty set (0.00 sec)

mysql> SELECT name, stock
    -> FROM products
    -> WHERE stock < 5;
Empty set (0.00 sec)
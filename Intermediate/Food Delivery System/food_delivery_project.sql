mysql> CREATE DATABASE food_delivery_db;
Query OK, 1 row affected (0.02 sec)

mysql> USE food_delivery_db;
Database changed

mysql> -- Users (customers)
mysql> CREATE TABLE users (
    -> user_id INT AUTO_INCREMENT PRIMARY KEY,
    -> first_name VARCHAR(50) NOT NULL,
    -> last_name VARCHAR(50) NOT NULL,
    -> phone VARCHAR(30),
    -> email VARCHAR(150) UNIQUE,
    -> address TEXT,
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.07 sec)

mysql> -- Restaurants
mysql> CREATE TABLE restaurants (
    -> restaurant_id INT AUTO_INCREMENT PRIMARY KEY,
    -> name VARCHAR(150) NOT NULL,
    -> cusine VARCHAR(100),
    -> rating DECIMAL(2,1) DEFAULT NULL, -- average rating
    -> phone VARCHAR(30),
    -> address TEXT,
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.02 sec)

mysql> ALTER TABLE restaurants
    -> RENAME COLUMN cusine TO cuisine;
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> -- Menu items (each belongs to a restaurant)
mysql> CREATE TABLE menu_items (
    -> menu_item_id INT AUTO_INCREMENT PRIMARY KEY,
    -> restaurant_id INT NOT NULL,
    -> name VARCHAR(150) NOT NULL,
    -> description TEXT,
    -> price DECIMAL(10,2) NOT NULL,
    -> is_veg BOOLEAN DEFAULT FALSE,
    -> is_available BOOLEAN DEFAULT TRUE,
    -> FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.06 sec)

mysql> -- Delivery partners
mysql> CREATE TABLE delivery_partners (
    -> partner_id INT AUTO_INCREMENT PRIMARY KEY,
    -> first_name VARCHAR(50),
    -> last_name VARCHAR(50),
    -> phone VARCHAR(30),
    -> vehicle_type VARCHAR(50),
    -> rating DECIMAL(2,1) DEFAULT NULL,
    -> active BOOLEAN DEFAULT TRUE,
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.02 sec)

mysql> -- Orders
mysql> CREATE TABLE orders (
    -> order_id INT AUTO_INCREMENT PRIMARY KEY,
    -> user_id INT NOT NULL,
    -> restaurant_id INT NOT NULL,
    -> partner_id INT DEFAULT NULL,
    -> order_status ENUM('placed', 'preparing', 'on_the_way', 'delivered', 'cancelled') DEFAULT 'placed',
    -> order_total DECIMAL(12,2) NOT NULL,
    -> placed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    -> delivered_at DATETIME DEFAULT NULL,
    -> payment_method ENUM('card', 'cash', 'wallet') DEFAULT 'card',
    -> rating TINYINT UNSIGNED DEFAULT NULL, -- customer rating for order
    -> CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_orders_rest FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_orders_partner FOREIGN KEY (partner_id) REFERENCES delivery_partners(partner_id) ON DELETE SET NULL
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.06 sec)

mysql> -- Order items (many-to-may: orders <-> menu items)
mysql> CREATE TABLE order_items (
    -> order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    -> order_id INT NOT NULL,
    -> menu_item_id INT NOT NULL,
    -> quantity INT NOT NULL DEFAULT 1,
    -> item_price DECIMAL(10,2) NOT NULL, -- price at time of order
    -> notes VARCHAR(255),
    -> CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_oi_menu FOREIGN KEY (menu_item_id) REFERENCES menu_items(menu_item_id) ON DELETE RESTRICT
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.06 sec)

mysql> -- Indexes
mysql> CREATE INDEX idx_menu_rest ON menu_items(restaurant_id);
Query OK, 0 rows affected (0.06 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_orders_user ON orders(user_id);
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_orders_rest ON orders(restaurant_id);
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_orders_status ON orders(order_status);
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> -- Sample data: users
mysql> INSERT INTO users (first_name, last_name, phone, email, address) VALUES
    -> ('Anita', 'Sharma', '9810011111', 'anita@example.com', '12 Rose St, Mumbai'),
    -> ('Rohit', 'Kumar', '9820022222', 'rohit@example.com', '45 Lake Rd, Pune'),
    -> ('Neha', 'Verma', '9830033333', 'neha@example.com', '9 Hill Lake, Kolkata'),
    -> ('Aman', 'Singh', '9840044444', 'aman@example.com', '77 MG Rd, Delhi');
Query OK, 4 rows affected (0.01 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> -- Sample data: restaurants
mysql> INSERT INTO restaurants (name, cuisine, rating, phone, address) VALUES
    -> ('Spice Villa', 'Indian', 4.4, '022-111222', '123 Food St, Mumbai'),
    -> ('Sushi World', 'Japanese', 4.8, '022-333444', '7 Ocean Ave, Mumbai'),
    -> ('Pizza Palace', 'Italian', 4.1, '022-555666', '88 Slice Rd, Pune');
Query OK, 3 rows affected (0.00 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> -- Sample data: menu_items
mysql> INSERT INTO menu_items (restaurant_id, name, description, price, is_veg, is_available) VALUES
    -> (1, 'Butter Chicken', 'Creamy tomato gravy', 320.00, FALSE, TRUE),
    -> (1, 'Paneer Tikka', 'Tandoori panner', 220.00, TRUE, TRUE),
    -> (2, 'California Roll', 'Crab & avocado roll', 450.00, FALSE, TRUE),
    -> (2, 'Veg Tempura', 'Mixed vegetable tempura', 350.00, TRUE, TRUE),
    -> (3, 'Margherita Pizza', 'Classic margherita 12"', 400.00, TRUE, TRUE),
    -> (3, 'Pepperoni Pizza', '12" pepperoni', 500.00, FALSE, TRUE);
Query OK, 6 rows affected (0.01 sec)
Records: 6  Duplicates: 0  Warnings: 0

mysql> -- Sample data: delivery_partners
mysql> INSERT INTO delivery_partners (first_name, last_name, phone, vehicle_type, rating) VALUES
    -> ('Suresh', 'Kumar', '9900011111', 'Bike', 4.6),
    -> ('Pooja', 'Devi', '9900022222', 'Scooter', 4.4);
Query OK, 2 rows affected (0.01 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> -- Sample data: order_items
mysql> INSERT INTO order_items (order_id, menu_item_id, quantity, item_price, notes) VALUES
    -> (1, 1, 1, 320.00, 'no onions'),
    -> (1, 2, 1, 320.00, NULL),
    -> (2, 5, 1, 400.00, NULL),
    -> (2, 6, 1, 500.00, NULL),
    -> (3, 3, 1, 450.00, NULL);
Query OK, 5 rows affected (0.01 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> -- View restaurant revenue summary (total revenue & orders)
mysql> CREATE VIEW restaurant_revenue AS
    -> SELECT r.restaurant_id, r.name,
    -> COUNT(o.order_id) AS total_orders,
    -> IFNULL(SUM(o.order_total),0) AS total_revenue,
    -> ROUND(IFNULL(AVG(o.rating),0),2) AS avg_order_rating
    -> FROM restaurants r
    -> LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id AND o.order_status = 'delivered'
    -> GROUP BY r.restaurant_id, r.name;
Query OK, 0 rows affected (0.02 sec)

mysql> -- Find all restaurants offering Indian cuisine:
mysql> SELECT * FROM restaurants WHERE cuisine = 'Indian';
+---------------+-------------+---------+--------+------------+---------------------+---------------------+
| restaurant_id | name        | cuisine | rating | phone      | address             | created_at          |
+---------------+-------------+---------+--------+------------+---------------------+---------------------+
|             1 | Spice Villa | Indian  |    4.4 | 022-111222 | 123 Food St, Mumbai | 2025-11-21 10:18:06 |
+---------------+-------------+---------+--------+------------+---------------------+---------------------+
1 row in set (0.01 sec)

mysql> -- Show orders placed by user_id=1:
mysql> SELECT o.*, r.name AS restaurant_name
    -> FROM orders o JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    -> WHERE o.user_id = 1 ORDER BY o.placed_at DESC;
+----------+---------+---------------+------------+--------------+-------------+---------------------+---------------------+----------------+--------+-----------------+
| order_id | user_id | restaurant_id | partner_id | order_status | order_total | placed_at           | delivered_at        | payment_method | rating | restaurant_name |
+----------+---------+---------------+------------+--------------+-------------+---------------------+---------------------+----------------+--------+-----------------+
|        1 |       1 |             1 |          1 | delivered    |      540.00 | 2025-11-10 12:00:00 | 2025-11-10 12:45:00 | card           |      5 | Spice Villa     |
+----------+---------+---------------+------------+--------------+-------------+---------------------+---------------------+----------------+--------+-----------------+
1 row in set (0.00 sec)

mysql> -- Order details(items) for order_id = 1:
mysql> SELECT oi.* , mi.name AS item_name, mi.description
    -> FROM order_items oi
    -> JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
    -> WHERE oi.order_id = 1;
+---------------+----------+--------------+----------+------------+-----------+----------------+---------------------+
| order_item_id | order_id | menu_item_id | quantity | item_price | notes     | item_name      | description         |
+---------------+----------+--------------+----------+------------+-----------+----------------+---------------------+
|             1 |        1 |            1 |        1 |     320.00 | no onions | Butter Chicken | Creamy tomato gravy |
|             2 |        1 |            2 |        1 |     320.00 | NULL      | Paneer Tikka   | Tandoori panner     |
+---------------+----------+--------------+----------+------------+-----------+----------------+---------------------+
2 rows in set (0.00 sec)

mysql> -- Top 5 restaurants by revenue:
mysql> SELECT * FROM restaurant_revenue ORDER BY total_revenue DESC LIMIT 5;
+---------------+--------------+--------------+---------------+------------------+
| restaurant_id | name         | total_orders | total_revenue | avg_order_rating |
+---------------+--------------+--------------+---------------+------------------+
|             3 | Pizza Palace |            1 |        900.00 |             4.00 |
|             1 | Spice Villa  |            1 |        540.00 |             5.00 |
|             2 | Sushi World  |            0 |          0.00 |             0.00 |
+---------------+--------------+--------------+---------------+------------------+
3 rows in set (0.01 sec)

mysql> -- Most ordered menu items (top 10):
mysql> SELECT mi.menu_item_id, mi.name, SUM(oi.quantity) AS total_qty
    -> FROM order_items oi
    -> JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
    -> GROUP BY mi.menu_item_id, mi.name
    -> ORDER BY total_qty DESC
    -> LIMIT 10;
+--------------+------------------+-----------+
| menu_item_id | name             | total_qty |
+--------------+------------------+-----------+
|            1 | Butter Chicken   |         1 |
|            2 | Paneer Tikka     |         1 |
|            5 | Margherita Pizza |         1 |
|            6 | Pepperoni Pizza  |         1 |
|            3 | California Roll  |         1 |
+--------------+------------------+-----------+
5 rows in set (0.00 sec)

mysql> -- Average delivery time per partner (delivered_at - placed_at):
mysql> SELECT partner_id,
    -> AVG(TIMESTAMPDIFF(MINUTE, placed_at, delivered_at)) AS avg_delivery_mins
    -> FROM orders
    -> WHERE delivered_at IS NOT NULL
    -> GROUP BY partner_id;
+------------+-------------------+
| partner_id | avg_delivery_mins |
+------------+-------------------+
|          1 |           45.0000 |
|          2 |           40.0000 |
+------------+-------------------+
2 rows in set (0.00 sec)

mysql> -- Find pending orders(preparing or on_the_way):
mysql> SELECT * FROM orders WHERE order_status IN ('preparing', 'on_the_way') ORDER BY placed_at;
Empty set (0.00 sec)

mysql> -- List veg items for restaurant_id = 1;
mysql> SELECT * FROM menu_items WHERE restaurant_id = 1 AND is_veg = TRUE;
+--------------+---------------+--------------+-----------------+--------+--------+--------------+
| menu_item_id | restaurant_id | name         | description     | price  | is_veg | is_available |
+--------------+---------------+--------------+-----------------+--------+--------+--------------+
|            2 |             1 | Paneer Tikka | Tandoori panner | 220.00 |      1 |            1 |
+--------------+---------------+--------------+-----------------+--------+--------+--------------+
1 row in set (0.00 sec)

mysql> -- Update menu price (increase by 10%) for a restaurant:
mysql> UPDATE menu_items SET price = ROUND(price * 1.10,2) WHERE restaurant_id = 3;
Query OK, 2 rows affected (0.01 sec)
Rows matched: 2  Changed: 2  Warnings: 0

mysql> -- Average order value (AOV) per restaurant:
mysql> SELECT restaurant_id, ROUND(AVG(order_total),2) AS avg_order_value
    -> FROM orders WHERE order_status = 'delivered' GROUP BY restaurant_id;
+---------------+-----------------+
| restaurant_id | avg_order_value |
+---------------+-----------------+
|             1 |          540.00 |
|             3 |          900.00 |
+---------------+-----------------+
2 rows in set (0.00 sec)

mysql> -- Recent ratings for a resturant (resturant_id = 1):
mysql> SELECT o.order_id, o.rating, o.placed_at
    -> FROM orders o WHERE o.restaurant_id = 1 AND o.rating IS NOT NULL ORDER BY placed_at DESC LIMIT 10;
+----------+--------+---------------------+
| order_id | rating | placed_at           |
+----------+--------+---------------------+
|        1 |      5 | 2025-11-10 12:00:00 |
+----------+--------+---------------------+
1 row in set (0.00 sec)

mysql> -- Flag menu items low in availability (example: mark item unavailable):
mysql> UPDATE menu_items SET is_available = FALSE WHERE menu_item_id = 4;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> -- Sales breakdown by cuisine:
mysql> SELECT r.cuisine, COUNT(o.order_id) AS orders_count, SUM(o.order_total) AS revenue
    -> FROM orders o JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    -> WHERE o.order_status = 'delivered'
    -> GROUP BY r.cuisine ORDER BY revenue DESC;
+---------+--------------+---------+
| cuisine | orders_count | revenue |
+---------+--------------+---------+
| Italian |            1 |  900.00 |
| Indian  |            1 |  540.00 |
+---------+--------------+---------+
2 rows in set (0.00 sec)

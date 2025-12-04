mysql> CREATE DATABASE inventory_management_db;
Query OK, 1 row affected (0.01 sec)

mysql> USE inventory_management_db;
Database changed

mysql> -- Categories
mysql> CREATE TABLE categories (
    -> category_id INT AUTO_INCREMENT PRIMARY KEY,
    -> name VARCHAR(100) NOT NULL UNIQUE,
    -> description TEXT
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.05 sec)

mysql> -- Items (Products/SKUs)
mysql> CREATE TABLE items (
    -> item_id INT AUTO_INCREMENT PRIMARY KEY,
    -> sku VARCHAR(50) NOT NULL UNIQUE,
    -> name VARCHAR(200) NOT NULL,
    -> category_id INT,
    -> unit VARCHAR(20) DEFAULT 'pcs',
    -> unit_cost DECIMAL(12,2) DEFAULT 0.00,
    -> reorder_point INT DEFAULT 10,              -- min qty before reorder
    -> reorder_qty INT DEFAULT 50,                -- suggested reorder qty
    -> is_active BOOLEAN DEFAULT TRUE,
    -> CONSTRAINT fk_items_category FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.05 sec)

mysql> -- Warehouses
mysql> CREATE TABLE warehouses (
    -> warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    -> name VARCHAR(150) NOT NULL,
    -> location VARCHAR(255),
    -> capacity INT DEFAULT NULL,
    -> manager VARCHAR(150)
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.02 sec)

mysql> -- Warehouse stock (current quantities per warehouse per item)
mysql> CREATE TABLE warehouse_stock (
    -> stock_id INT AUTO_INCREMENT PRIMARY KEY,
    -> warehouse_id INT NOT NULL,
    -> item_id INT NOT NULL,
    -> quantity INT NOT NULL DEFAULT 0,
    -> last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    -> CONSTRAINT fk_ws_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_ws_item FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE,
    -> UNIQUE KEY uq_warehouse_item (warehouse_id, item_id)
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.06 sec)

mysql> -- Vendors / Suppliers
mysql> CREATE TABLE vendors (
    -> vendor_id INT AUTO_INCREMENT PRIMARY KEY,
    -> name VARCHAR(200) NOT NULL,
    -> contact_name VARCHAR(150),
    -> phone VARCHAR(30),
    -> email VARCHAR(150),
    -> address TEXT
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.02 sec)

mysql> -- Purchases (purchase orders from vendors)
mysql> CREATE TABLE purchases (
    -> purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    -> vendor_id INT NOT NULL,
    -> warehouse_id INT NOT NULL,
    -> purchase_date DATE DEFAULT (CURRENT_DATE),
    -> total_amount DECIMAL(12,2) DEFAULT 0.00,
    -> status ENUM('ordered', 'received', 'cancelled') DEFAULT 'ordered',
    -> notes TEXT,
    -> CONSTRAINT fk_purchases_vendor FOREIGN KEY (vendor_id) REFERENCES vendors(vendor_id) ON DELETE RESTRICT,
    -> CONSTRAINT fk_purchases_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE RESTRICT
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.05 sec)

mysql> -- Purchase items (line items for each purchase)
mysql> CREATE TABLE purchase_items (
    -> purchase_item_id INT AUTO_INCREMENT PRIMARY KEY,
    -> purchase_id INT NOT NULL,
    -> item_id INT NOT NULL,
    -> quantity INT NOT NULL,
    -> unit_cost DECIMAL(12,2) NOT NULL,
    -> CONSTRAINT fk_pi_purchase FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_pi_item FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE RESTRICT
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.05 sec)

mysql> -- Inventory movements (manual adjustments, transfers, slaes outflow)
mysql> -- movement_type: receive, issue, transfer_in, transfer_out, adjustment
mysql> CREATE TABLE inventory_movements (
    -> movement_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    -> item_id INT NOT NULL,
    -> from_warehouse_id INT DEFAULT NULL,
    -> to_warehouse_id INT DEFAULT NULL,
    -> quantity INT NOT NULL,
    -> movement_type ENUM('receive', 'issue', 'transfer_in', 'transfer_out', 'adjustment') NOT NULL,
    -> movement_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    -> reference VARCHAR(200),
    -> notes TEXT,
    -> CONSTRAINT fk_im_item FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_im_from_wh FOREIGN KEY (from_warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE SET NULL,
    -> CONSTRAINT fk_im_to_wh FOREIGN KEY (to_warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE SET NULL
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.06 sec)

mysql> -- Indexes for references
mysql> CREATE INDEX idx_ws_item ON warehouse_stock(item_id);
Query OK, 0 rows affected (0.04 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_im_item ON inventory_movements(item_id);
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_pi_item ON purchase_items(item_id);
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> -- Sample data: categories;
mysql> INSERT INTO categories (name, description) VALUES
    -> ('Electronics', 'Phones, chargers, accessories'),
    -> ('Home', 'Home & kitchen items'),
    -> ('Stationery', 'Office supplies');
Query OK, 3 rows affected (0.06 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> -- Sample data: items
mysql> INSERT INTO items (sku, name, category_id, unit, unit_cost, reorder_point, reorder_qty) VALUES
    -> ('SKU-1001', 'USB-C Charger', 1, 'pcs', 250.00, 20, 100),
    -> ('SKU-1002', 'Wireless Mouse', 1, 'pcs', 450.00, 10, 50),
    -> ('SKU-2001', 'Ceramic Mug', 2, 'pcs', 120.00, 30, 120),
    -> ('SKU-3001', 'A4 Notebook', 3, 'pcs', 40.00, 100, 500);
Query OK, 4 rows affected (0.03 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> -- Sample data: warehouses
mysql> INSERT INTO warehouses (name, location, capacity, manager) VALUES
    -> ('Mumbai Warehouse', 'Mumbai, Maharashtra', 10000, 'Ramesh Patel'),
    -> ('Delhi Warehouse', 'New Delhi', 8000, 'Sonia Verma');
Query OK, 2 rows affected (0.03 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> -- Initialize warehouse_stock
mysql> INSERT INTO warehouse_stock (warehouse_id, item_id, quantity) VALUES
    -> (1, 1, 120),
    -> (1, 2, 45),
    -> (1, 3, 60),
    -> (1, 4, 800),
    -> (2, 1, 30),
    -> (2, 2, 10),
    -> (2, 3, 40),
    -> (2, 4, 200);
Query OK, 8 rows affected (0.03 sec)
Records: 8  Duplicates: 0  Warnings: 0

mysql> -- Sample vendors
mysql> INSERT INTO vendors (name, contact_name, phone, email, address) VALUES
    -> ('ABC Electronics', 'Mr. Sharma', '9900011111', 'sales@abcelec.com', '10 Vendor St, Mumbai'),
    -> ('Homeware Pvt Ltd', 'Ms. Gupta', '9900022222', 'contact@homeware.com', '5 Market Rd, Delhi');
Query OK, 2 rows affected (0.03 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> -- Sample purchase (PO) and items
mysql> INSERT INTO purchases (vendor_id, warehouse_id, purchase_date, total_amount, status, notes) VALUES
    -> (1, 1, '2025-11-10', 25000.00, 'received', 'Restock chargers'),
    -> (2, 2, '2025-11-12', 4800.00, 'ordered', 'New mugs');
Query OK, 2 rows affected (0.02 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> INSERT INTO purchase_items (purchase_id, item_id, quantity, unit_cost) VALUES
    -> (1, 1, 100, 250.00),
    -> (1, 2, 50, 450.00),
    -> (2, 3, 40, 120.00);
Query OK, 3 rows affected (0.02 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> -- When purchase received, log inventory_movements and update warehouse_stock
mysql> -- Example: receive purchase 1 into warehouse 1
mysql> INSERT INTO inventory_movements (item_id, to_warehouse_id, quantity, movement_type, reference, notes)
    -> VALUES
    -> (1, 1, 100, 'receive', 'PO#1', 'Received chargers'),
    -> (2, 1, 50, 'receive', 'PO#1', 'Received mice');
Query OK, 2 rows affected (0.03 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> UPDATE warehouse_stock ws
    -> JOIN (SELECT 1 AS item_id, 100 AS qty UNION SELECT 2,50) inc ON ws.item_id = inc.item_id AND ws.warehouse_id = 1
    -> SET ws.quantity = ws.quantity + inc.qty;
Query OK, 2 rows affected (0.01 sec)
Rows matched: 2  Changed: 2  Warnings: 0

mysql> -- Views
mysql> -- 1) vw_stock_by_warehouse: quick stock levels per warehouse with item info
mysql> CREATE VIEW vw_stock_by_warehouse AS
    -> SELECT w.warehouse_id, w.name AS warehouse_name,
    -> i.item_id, i.sku, i.name AS item_name, COALESCE(ws.quantity,0) AS quantity, i.reorder_point, i.reorder_qty
    -> FROM warehouses w
    -> CROSS JOIN items i
    -> LEFT JOIN warehouse_stock ws ON ws.warehouse_id = w.warehouse_id AND ws.item_id = i.item_id;
Query OK, 0 rows affected (0.01 sec)

mysql> -- 2) vw_reorder_alerts: items needing reorder (any warehouse quantity <= reorder_point)
mysql> CREATE VIEW vw_reorder_alerts AS
    -> SELECT ws.warehouse_id, w.name AS warehouse_name, i.item_id, i.sku, i.name AS item_name, ws.quantity, i.reorder_point, i.reorder_qty
    -> FROM warehouse_stock ws
    -> JOIN items i ON ws.item_id = i.item_id
    -> JOIN warehouses w ON ws.warehouse_id = w.warehouse_id
    -> WHERE ws.quantity <= i.reorder_point
    -> ORDER BY w.name, ws.quantity ASC;
Query OK, 0 rows affected (0.01 sec)

mysql> -- Item details by SKU
mysql> SELECT * FROM items WHERE sku = 'SKU-1001';
+---------+----------+---------------+-------------+------+-----------+---------------+-------------+-----------+
| item_id | sku      | name          | category_id | unit | unit_cost | reorder_point | reorder_qty | is_active |
+---------+----------+---------------+-------------+------+-----------+---------------+-------------+-----------+
|       1 | SKU-1001 | USB-C Charger |           1 | pcs  |    250.00 |            20 |         100 |         1 |
+---------+----------+---------------+-------------+------+-----------+---------------+-------------+-----------+
1 row in set (0.04 sec)

mysql> -- Current stock for an item across all warehouses:
mysql> SELECT i.item_id, i.sku, i.name, SUM(ws.quantity) AS total_qty
    -> FROM items i
    -> JOIN warehouse_stock ws ON i.item_id = ws.item_id
    -> WHERE i.item_id = 1
    -> GROUP BY i.item_id, i.sku, i.name;
+---------+----------+---------------+-----------+
| item_id | sku      | name          | total_qty |
+---------+----------+---------------+-----------+
|       1 | SKU-1001 | USB-C Charger |       250 |
+---------+----------+---------------+-----------+
1 row in set (0.02 sec)

mysql> -- Items below reorder point (global per warehouse view):
mysql> SELECT * FROM vw_reorder_alerts;
+--------------+-----------------+---------+----------+----------------+----------+---------------+-------------+
| warehouse_id | warehouse_name  | item_id | sku      | item_name      | quantity | reorder_point | reorder_qty |
+--------------+-----------------+---------+----------+----------------+----------+---------------+-------------+
|            2 | Delhi Warehouse |       2 | SKU-1002 | Wireless Mouse |       10 |            10 |          50 |
+--------------+-----------------+---------+----------+----------------+----------+---------------+-------------+
1 row in set (0.03 sec)

mysql> -- Create a purchase order (example)
mysql> INSERT INTO purchases (vendor_id, warehouse_id, purchase_date, total_amount,status) VALUES (1, 1, '2025-11-20', 12500.00, 'ordered');
Query OK, 1 row affected (0.05 sec)

mysql> SET @po = LAST_INSERT_ID();
Query OK, 0 rows affected (0.00 sec)

mysql> INSERT INTO purchase_items (purchase_id, item_id, quantity, unit_cost) VALUES (@po, 1, 50, 250.00), (@po, 2, 20, 450.00);
Query OK, 2 rows affected (0.02 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> -- Receive a purchase (log movements + update stock):
mysql> INSERT INTO inventory_movements (item_id, to_warehouse_id, quantity, movement_type, reference, notes) VALUES (1, 1, 50, 'receive', CONCAT('PO#', @po), 'Received chargers');
Query OK, 1 row affected (0.02 sec)

mysql> -- then update warehouse_stock_accordingly
mysql> UPDATE warehouse_stock ws JOIN (SELECT 1 AS item_id, 50 AS qty) inc ON ws.item_id = inc.item_id AND ws.warehouse_id = 1
    -> SET ws.quantity = ws.quantity + inc.qty;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> -- Transfer 30 units of item_id = 4 from warehouse 1 to 2:
mysql> START TRANSACTION;
Query OK, 0 rows affected (0.00 sec)

mysql> INSERT INTO inventory_movements (item_id, from_warehouse_id, to_warehouse_id, quantity, movement_type, reference) VALUES (4, 1, 2, 30, 'transfer_out', 'TX-001');
Query OK, 1 row affected (0.00 sec)

mysql> INSERT INTO inventory_movements (item_id, from_warehouse_id, to_warehouse_id, quantity, movement_type, reference) VALUES (4, 1, 2, 30, 'transfer_in', 'TX-001');
Query OK, 1 row affected (0.00 sec)

mysql> UPDATE warehouse_stock SET quantity = quantity - 30 WHERE warehouse_id = 1 AND item_id = 4;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> UPDATE warehouse_stock SET quantity = quantity + 30 WHERE warehouse_id = 2 AND item_id = 4;
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> COMMIT;
Query OK, 0 rows affected (0.01 sec)

mysql> -- Top 10 items by total quantity (across warehouses):
mysql> SELECT i.item_id, i.sku, i.name, SUM(ws.quantity) AS total_qty
    -> FROM items i JOIN warehouse_stock ws ON i.item_id = ws.item_id
    -> GROUP BY i.item_id, i.sku, i.name
    -> ORDER BY total_qty DESC
    -> LIMIT 10;
+---------+----------+----------------+-----------+
| item_id | sku      | name           | total_qty |
+---------+----------+----------------+-----------+
|       4 | SKU-3001 | A4 Notebook    |      1000 |
|       1 | SKU-1001 | USB-C Charger  |       300 |
|       2 | SKU-1002 | Wireless Mouse |       105 |
|       3 | SKU-2001 | Ceramic Mug    |       100 |
+---------+----------+----------------+-----------+
4 rows in set (0.01 sec)

mysql> -- Purchase history for vendor_id = 1:
mysql> SELECT p.*, pi.item_id, pi.quantity, pi.unit_cost
    -> FROM purchases p JOIN purchase_items pi ON p.purchase_id = pi.purchase_id
    -> WHERE p.vendor_id = 1
    -> ORDER BY p.purchase_date DESC;
+-------------+-----------+--------------+---------------+--------------+----------+------------------+---------+----------+-----------+
| purchase_id | vendor_id | warehouse_id | purchase_date | total_amount | status   | notes            | item_id | quantity | unit_cost |
+-------------+-----------+--------------+---------------+--------------+----------+------------------+---------+----------+-----------+
|           3 |         1 |            1 | 2025-11-20    |     12500.00 | ordered  | NULL             |       1 |       50 |    250.00 |
|           3 |         1 |            1 | 2025-11-20    |     12500.00 | ordered  | NULL             |       2 |       20 |    450.00 |
|           1 |         1 |            1 | 2025-11-10    |     25000.00 | received | Restock chargers |       1 |      100 |    250.00 |
|           1 |         1 |            1 | 2025-11-10    |     25000.00 | received | Restock chargers |       2 |       50 |    450.00 |
+-------------+-----------+--------------+---------------+--------------+----------+------------------+---------+----------+-----------+
4 rows in set (0.00 sec)

mysql> -- Stock value per warehouse (invetory valuation by unit_cost):
mysql> SELECT w.warehouse_id, w.name, SUM(ws.quantity * i.unit_cost) AS stock_value
    -> FROM warehouse_stock ws
    -> JOIN items i ON ws.item_id = i.item_id
    -> JOIN warehouses w ON ws.warehouse_id = w.warehouse_id
    -> GROUP BY w.warehouse_id, w.name;
+--------------+------------------+-------------+
| warehouse_id | name             | stock_value |
+--------------+------------------+-------------+
|            2 | Delhi Warehouse  |    26000.00 |
|            1 | Mumbai Warehouse |   148250.00 |
+--------------+------------------+-------------+
2 rows in set (0.00 sec)

mysql> -- Items never stocked in a warehouse (zero or missing):
mysql> SELECT w.warehouse_id, w.name, i.item_id, i.sku, COALESCE(ws.quantity,0) AS qty
    -> FROM warehouses w CROSS JOIN items i LEFT JOIN warehouse_stock ws ON ws.warehouse_id = w.warehouse_id AND ws.item_id = i.item_id
    -> WHERE COALESCE(ws.quantity,0) = 0;
Empty set (0.00 sec)

mysql> -- Recent inventory movements from item_id = 1:
mysql> SELECT * FROM inventory_movements WHERE item_id = 1 ORDER BY movement_date DESC LIMIT 20;
+-------------+---------+-------------------+-----------------+----------+---------------+---------------------+-----------+-------------------+
| movement_id | item_id | from_warehouse_id | to_warehouse_id | quantity | movement_type | movement_date       | reference | notes             |
+-------------+---------+-------------------+-----------------+----------+---------------+---------------------+-----------+-------------------+
|           3 |       1 |              NULL |               1 |       50 | receive       | 2025-12-04 09:33:24 | PO#3      | Received chargers |
|           1 |       1 |              NULL |               1 |      100 | receive       | 2025-11-27 10:35:53 | PO#1      | Received chargers |
+-------------+---------+-------------------+-----------------+----------+---------------+---------------------+-----------+-------------------+
2 rows in set (0.00 sec)

mysql> -- Reorder suggestions
mysql> SELECT * FROM vw_reorder_alerts;
+--------------+-----------------+---------+----------+----------------+----------+---------------+-------------+
| warehouse_id | warehouse_name  | item_id | sku      | item_name      | quantity | reorder_point | reorder_qty |
+--------------+-----------------+---------+----------+----------------+----------+---------------+-------------+
|            2 | Delhi Warehouse |       2 | SKU-1002 | Wireless Mouse |       10 |            10 |          50 |
+--------------+-----------------+---------+----------+----------------+----------+---------------+-------------+
1 row in set (0.00 sec)

mysql> -- Add a new SKU:
mysql> INSERT INTO items (sku, name, category_id, unit, unit_cost, reorder_point, reorder_qty) VALUES ('SKU-4001', 'LED Lamp', 1, 'pcs', 150.00, 20, 100);
Query OK, 1 row affected (0.03 sec)

mysql> -- Soft-delete an item (deactivate):
mysql> UPDATE items SET is_active = FALSE WHERE item_id = 3;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> -- Aggregate monthly purchases (value) for last 6 months:
mysql> SELECT DATE_FORMAT(purchase_date, '%Y-%m') AS ym, SUM(total_amount) AS month_spend
    -> FROM purchases
    -> WHERE purchase_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
    -> GROUP BY ym ORDER BY ym DESC;
+---------+-------------+
| ym      | month_spend |
+---------+-------------+
| 2025-11 |    42300.00 |
+---------+-------------+
1 row in set (0.00 sec)

mysql> -- Aggregate monthly purchases (value) for last 6 months:
mysql> -- Most frequently received items:
mysql> SELECT im.item_id, i.sku, i.name, SUM(im.quantity) AS received_qty
    -> FROM inventory_movements im JOIN items i ON im.item_id = i.item_id
    -> WHERE im.movement_type = 'receive'
    -> GROUP BY im.item_id, i.sku, i.name
    -> ORDER BY received_qty DESC LIMIT 20;
+---------+----------+----------------+--------------+
| item_id | sku      | name           | received_qty |
+---------+----------+----------------+--------------+
|       1 | SKU-1001 | USB-C Charger  |          150 |
|       2 | SKU-1002 | Wireless Mouse |           50 |
+---------+----------+----------------+--------------+
2 rows in set (0.00 sec)

mysql> -- List purchases that are still 'ordered' (not received):
mysql> SELECT * FROM purchases WHERE status = 'ordered' ORDER BY purchase_date;
+-------------+-----------+--------------+---------------+--------------+---------+----------+
| purchase_id | vendor_id | warehouse_id | purchase_date | total_amount | status  | notes    |
+-------------+-----------+--------------+---------------+--------------+---------+----------+
|           2 |         2 |            2 | 2025-11-12    |      4800.00 | ordered | New mugs |
|           3 |         1 |            1 | 2025-11-20    |     12500.00 | ordered | NULL     |
+-------------+-----------+--------------+---------------+--------------+---------+----------+
2 rows in set (0.00 sec)

mysql> -- Adjust quantity (manual correction):
mysql> INSERT INTO inventory_movements (item_id, to_warehouse_id, quantity, movement_type, reference, notes) VALUES (2, 1, -5, 'adjustment', 'INV-ADJ-001', 'Damaged returned');
Query OK, 1 row affected (0.01 sec)

mysql> UPDATE warehouse_stock SET quantity = GREATEST(0, quantity - 5) WHERE warehouse_id = 1 AND item_id = 2;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> -- Show stock shortfall (total across warehouses less than reorder point):
mysql> SELECT i.item_id, i.sku, i.name, SUM(ws.quantity) AS total_qty, i.reorder_point
    -> FROM items i JOIN warehouse_stock ws ON i.item_id = ws.item_id
    -> GROUP BY i.item_id, i.sku, i.name, i.reorder_point
    -> HAVING SUM(ws.quantity) < i.reorder_point;
Empty set (0.01 sec)

mysql> -- Vendor spend last year:
mysql> SELECT v.vendor_id, v.name, SUM(p.total_amount) AS spent_last_year
    -> FROM vendors v JOIN purchases p ON v.vendor_id = p.vendor_id
    -> WHERE p.purchase_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
    -> GROUP BY v.vendor_id, v.name ORDER BY spent_last_year DESC;
+-----------+------------------+-----------------+
| vendor_id | name             | spent_last_year |
+-----------+------------------+-----------------+
|         1 | ABC Electronics  |        37500.00 |
|         2 | Homeware Pvt Ltd |         4800.00 |
+-----------+------------------+-----------------+
2 rows in set (0.01 sec)

mysql> -- Quick snapshot stock value and qty per SKU:
mysql> SELECT i.sku, i.name, SUM(ws.quantity) AS qty, SUM(ws.quantity * i.unit_cost) AS value
    -> FROM items i JOIN warehouse_stock ws ON i.item_id = ws.item_id
    -> GROUP BY i.sku, i.name ORDER BY value DESC;
+----------+----------------+------+----------+
| sku      | name           | qty  | value    |
+----------+----------------+------+----------+
| SKU-1001 | USB-C Charger  |  300 | 75000.00 |
| SKU-1002 | Wireless Mouse |  100 | 45000.00 |
| SKU-3001 | A4 Notebook    | 1000 | 40000.00 |
| SKU-2001 | Ceramic Mug    |  100 | 12000.00 |
+----------+----------------+------+----------+
4 rows in set (0.00 sec)

mysql> -- Recompute/initialize warehouse_stock (warehouse_id, item_id, quantity)
mysql> SELECT w.warehouse_id, i.item_id, 0
    -> FROM warehouses w CROSS JOIN items i;
+--------------+---------+---+
| warehouse_id | item_id | 0 |
+--------------+---------+---+
|            2 |       1 | 0 |
|            1 |       1 | 0 |
|            2 |       2 | 0 |
|            1 |       2 | 0 |
|            2 |       5 | 0 |
|            1 |       5 | 0 |
|            2 |       3 | 0 |
|            1 |       3 | 0 |
|            2 |       4 | 0 |
|            1 |       4 | 0 |
+--------------+---------+---+
10 rows in set (0.00 sec)

mysql> -- Remove a purchase and its items (cascades):
mysql> DELETE FROM purchases WHERE purchase_id = 2;
Query OK, 1 row affected (0.01 sec)
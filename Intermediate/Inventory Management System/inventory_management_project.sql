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

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

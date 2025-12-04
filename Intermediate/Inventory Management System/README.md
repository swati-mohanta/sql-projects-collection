# 📦 Inventory & Warehouse Management System (MySQL)

A MySQL 8+ compatible intermediate SQL project that models inventory across multiple warehouses, including purchases, stock, vendors, and inventory movements.

## Files
- `inventory_management_project.sql` — schema + sample data + views
- `queries.sql` — practical queries (included below)

## Schema Summary
Tables:
- `categories` — product categories
- `items` — SKUs, unit cost, reorder thresholds
- `warehouses` — physical storage locations
- `warehouse_stock` — current quantity per warehouse per item
- `vendors` — suppliers
- `purchases` & `purchase_items` — purchase orders and their lines
- `inventory_movements` — shipping/receiving/transfer records

Views:
- `vw_stock_by_warehouse` — full stock matrix per warehouse & item
- `vw_reorder_alerts` — items that are at or below reorder point

## How to run
1. Create DB & use it:
```sql
CREATE DATABASE inventory_db;
USE inventory_db;
````

2. Run:

```bash
mysql -u user -p inventory_db < inventory_management_mysql.sql
```

## Features & Demonstrated Skills

* Multi-warehouse stock management
* Purchase order receipts and stock updates
* Inventory movement audit trail
* Reorder logic and alerts via views
* Use of UNIQUE constraints, FK constraints, and indexes
* Joins, aggregations, and basic inventory analytics

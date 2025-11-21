# 🍕 Food Delivery System (MySQL)

A SQL project that models a real-world **food delivery platform** similar to Zomato/Swiggy.
This system includes users, restaurants, menu items, delivery partners, orders, and order items with complete relationships and sample data.

It’s an **intermediate-level SQL project**, perfect for database learning, portfolio building, and demonstrating SQL skills on GitHub.

---

## 🗂 Project Files

| File                         | Description                                          |
| ---------------------------- | ---------------------------------------------------- |
| **food_delivery_mysql.sql**  | Full MySQL schema + sample data + indexes + view     |
| **queries.sql** *(optional)* | 25 practice queries (CRUD, JOIN, analytics, reports) |

---

## 🧱 Database Schema Overview

This project includes the following tables:

### **1. users**

Stores customer information
`user_id, name, email, address, created_at`

### **2. restaurants**

Restaurant details
`restaurant_id, name, cuisine, rating, address`

### **3. menu_items**

Restaurant menu items
`menu_item_id, restaurant_id, price, veg/non-veg, availability`

### **4. delivery_partners**

Delivery agent details
`partner_id, name, vehicle, rating`

### **5. orders**

Main order table
`order_id, user_id, restaurant_id, partner_id, order_total, status, timestamps`

### **6. order_items**

Order ↔ menu_items mapping
`order_item_id, order_id, menu_item_id, quantity, item_price`

### **View Included**

* **restaurant_revenue** — total orders, revenue, and average rating per restaurant

---

## 📦 Features

### ✔ User Management

Create and manage customer details.

### ✔ Restaurant & Menu System

Store menu items, restaurant ratings, availability, cuisine types.

### ✔ Order Management

Place orders, assign delivery partners, track order status.

### ✔ Many-to-Many relationship

Orders ↔ Menu Items are handled via **order_items**.

### ✔ Delivery Partner Tracking

Partner rating, status, vehicle type.

### ✔ Revenue & Analytics

Using SQL Aggregations and one reporting view.

---

## ▶️ How to Run This Project

### **1. Create a new database**

```sql
CREATE DATABASE food_delivery_db;
USE food_delivery_db;
```

### **2. Run the SQL file**

Either run in MySQL Workbench or via terminal:

```bash
mysql -u root -p food_delivery_db < food_delivery_mysql.sql
```

### **3. Done!**

All tables, sample data, view & indexes are now created.

---


## 🛠 Skills Demonstrated in This Project

* Relational database modeling
* Normalization (1NF → 3NF)
* Primary & Foreign Keys
* Many-to-many relationships
* MySQL functions (JOIN, GROUP BY, HAVING, ORDER BY)
* Views for analytics
* Time functions (INTERVAL, TIMESTAMPDIFF)
* Window Functions (ROW_NUMBER, where useful)
* Data aggregation for revenue and insights

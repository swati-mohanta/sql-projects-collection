# 🏥 **Hospital Management System (MySQL)**

This project models a real-world hospital database using **MySQL**. It includes patients, doctors, departments, appointments, treatments, and billing — giving you hands-on experience with relational design, foreign keys, JOIN operations, and SQL reporting queries.

### 📁 **Tables Included**

* **departments** – Hospital departments and their details
* **patients** – Patient demographic data
* **doctors** – Doctors, specialization, and department mapping
* **appointments** – Scheduled/completed appointments
* **treatments** – Diagnosis, procedures, medication, and treatment cost
* **bills** – Payment details, amount due, insurance notes, etc.

---

## 🔧 **Features Implemented**

### ✔ Patient & Doctor Management

* Add/update patient demographics
* Maintain doctor details & department associations

### ✔ Appointment Scheduling

* Create, update, cancel, or complete appointments
* Track upcoming visits, repeated patients, peak times

### ✔ Treatment Tracking

* Record diagnosis, medications, procedures & cost
* Link each treatment to its respective appointment

### ✔ Billing System

* Generate bills for appointments
* Track paid/unpaid bills
* Calculate outstanding amounts
* Insurance or cash/card payment tracking

### ✔ SQL Reports & Analytics

Includes 20+ practical SQL queries such as:

* Upcoming appointments
* Busiest doctor
* Patients with outstanding payments
* Revenue per month
* Most expensive procedures
* Emergency department visits
* Patient history & summary
* Window-function-based analytics (MySQL 8+)

---

## 📄 **File: `hospital_management_project.sql`**

This file contains:

* Full database schema
* InnoDB engine + foreign key constraints
* Sample data for all tables
* Useful indexes
* A view (`patient_outstanding`) for financial summaries

You can import it directly using MySQL Workbench or:

```bash
mysql -u your_user -p your_database < hospital_management_mysql.sql
```

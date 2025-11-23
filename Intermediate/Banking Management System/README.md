# Banking Management System **

A relational SQL project modeling a simple banking system using MySQL 8+.  
Includes customers, branches, accounts, transactions, loans, and cards. Good for showing financial data modelling, transaction history, and reporting.

## 📁 Files
- `banking_mysql.sql` — full schema, sample data, views

## 🧩 Schema Overview
- `customers` — personal details
- `branches` — branch metadata
- `accounts` — bank accounts (savings/current/fixed)
- `transactions` — ledger of deposits, withdrawals, transfers, fees, loan payments
- `loans` — loan records linked to accounts
- `cards` — debit/credit cards linked to accounts
- Views:
  - `account_balances` — quick lookup of account balances and holder information
  - `branch_summary` — number of accounts and total deposits per branch

## ▶️ How to run
1. Create a database and use it:
```sql
CREATE DATABASE banking_db;
USE banking_db;
````

2. Import the SQL:

```bash
mysql -u user -p bankinh_db < banking_management_project.sql
```

## ✅ Key Features

* Proper FK relationships with InnoDB
* Decimal money columns for precise arithmetic
* Transaction history for auditability
* Simple loan tracking
* Views for reporting and analytics

mysql> CREATE DATABASE banking_db;
Query OK, 1 row affected (0.01 sec)

mysql> USE banking_db;
Database changed

mysql> -- Customers
mysql> CREATE TABLE customers (
    -> customer_id INT AUTO_INCREMENT PRIMARY KEY,
    -> first_name VARCHAR(50) NOT NULL,
    -> last_name VARCHAR(50) NOT NULL,
    -> dob DATE,
    -> phone VARCHAR(30),
    -> email VARCHAR(150),
    -> address TEXT,
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.04 sec)

mysql> -- Branches
mysql> CREATE TABLE branches (
    -> branch_id INT AUTO_INCREMENT PRIMARY KEY,
    -> name VARCHAR(150) NOT NULL,
    -> city VARCHAR(100),
    -> address TEXT,
    -> phone VARCHAR(30),
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.02 sec)

mysql> -- Accounts
mysql> -- Use Decimal for money. balance is maintained via transactions (but we keep a cached balance column for convenience).
mysql> CREATE TABLE accounts (
    -> account_id INT AUTO_INCREMENT PRIMARY KEY,
    -> customer_id INT NOT NULL,
    -> branch_id INT NOT NULL,
    -> account_no VARCHAR(20) NOT NULL UNIQUE,
    -> account_type ENUM('savings', 'current', 'fixed') DEFAULT 'savings',
    -> opened_date DATE DEFAULT (CURRENT_DATE),
    -> balance DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    -> is_active BOOLEAN DEFAULT TRUE,
    -> CONSTRAINT fk_accounts_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE RESTRICT
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.05 sec)

mysql> -- Transactions
mysql> -- transaction_type: deposit, withdrawal, transfer, fee, interest, loan_payment
mysql> CREATE TABLE transactions (
    -> transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    -> account_id INT NOT NULL,
    -> related_account_id INT DEFAULT NULL, -- for transfers
    -> amount DECIMAL(18,2) NOT NULL, -- positive amount
    -> transaction_type ENUM('deposit', 'withdrawal', 'transfer', 'fee', 'interest', 'loan_payment') NOT NULL,
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    -> performed_by VARCHAR(100) DEFAULT 'system', -- teller id or system
    -> description VARCHAR(255),
    -> CONSTRAINT fk_tx_account FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_tx_related_account FOREIGN KEY (related_account_id) REFERENCES accounts(account_id) ON DELETE SET NULL
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.04 sec)

mysql> -- Loans
mysql> CREATE TABLE loans (
    -> loan_id INT AUTO_INCREMENT PRIMARY KEY,
    -> account_id INT NOT NULL, -- the account that receives/disburses the loan
    -> peincipal DECIMAL(18,2) NOT NULL,
    -> balance DECIMAL(18,2) NOT NULL,
    -> interest_rate DECIMAL(5,2) NOT NULL, -- annual percentage
    -> start_date DATE,
    -> term_months INT,
    -> status ENUM('active', 'closed', 'defaulted') DEFAULT 'active',
    -> CONSTRAINT fk_loan_account FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.05 sec)

mysql> -- Cards
mysql> CREATE TABLE cards (
    -> card_id INT AUTO_INCREMENT PRIMARY KEY,
    -> account_id INT NOT NULL,
    -> card_number CHAR(16) NOT NULL UNIQUE,
    -> card_type ENUM('debit', 'credit') DEFAULT 'debit',
    -> expiry DATE,
    -> is_blocked BOOLEAN DEFAULT FALSE,
    -> CONSTRAINT fk_card_account FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.04 sec)

mysql> -- Indexes
mysql> CREATE INDEX idx_accounts_customer ON accounts(customer_id);
Query OK, 0 rows affected (0.05 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_tx_account ON transactions(account_id);
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_tx_created_at ON transactions(created_at);
Query OK, 0 rows affected (0.01 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_loans_account ON loans(account_id);
Query OK, 0 rows affected (0.02 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> -- Sample data: branches
mysql> INSERT INTO branches (name, city, address, phone) VALUES
    -> ('Central Branch', 'Munabi', '12 Main St, Mumbai', '022-111111'),
    -> ('North Branch', 'Delhi', '45 North Ave, Delhi', '011-222222'),
    -> ('East Branch', 'Kolkata', '9 River Rd, Kolkata', '033-333333');
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> UPDATE branches
    -> SET city = 'Mumbai' WHERE name = 'Central Branch';
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> -- Sample data: customers
mysql> INSERT INTO customers (first_name, last_name, dob, phone, email, address) VALUES
    -> ('Aditi', 'Rao', '1990-04-15', '9810001111', 'aditi.rao@example.com', '12 Bose St, Mumbai'),
    -> ('Sanjay', 'Kumar', '1985-09-02', '9820002222', 'sanjay.kumar@example.com', '45 Lake Rd, Pune'),
    -> ('Meera', 'Shah', '1978-12-10', '9830003333', 'meera.shah@example.com', '9 Hill Lane, Kolkata');
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> -- Sample data: accounts
mysql> INSERT INTO accounts (customer_id, branch_id, account_no, account_type, opened_date, balance) VALUES
    -> (1, 1, 'ACC100001', 'savings', '2022-06-01', 50000.00),
    -> (2, 1, 'ACC100002', 'current', '2020-01-20', 150000.00),
    -> (3, 2, 'ACC100003', 'savings', '2018-11-10', 8000.00);
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> -- Sample data: transactions (deposit/withdrawals/tranfers)
mysql> INSERT INTO transactions (account_id, amount, transaction_type, performed_by, description) VALUES
    -> (1, 50000.00, 'deposit', 'init', 'Initial deposit'),
    -> (2, 150000.00, 'deposit', 'init', 'Initial deposit'),
    -> (3, 8000.00, 'deposit', 'init', 'Initial deposit');
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> -- Sample data: cards
mysql> INSERT INTO cards (account_id, card_number, card_type, expiry) VALUES
    -> (1, '4000000000000001', 'debit', '2027-12-31'),
    -> (2, '4000000000000002', 'debit', '2026-08-31');
Query OK, 2 rows affected (0.01 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> -- Example transfer: Sanjay transfers 20,000 from ACC100000002 -> ACC100000001
mysql> -- We record two transactions: withdrawal on source.deposit on target and optionally set related account_id
mysql> INSERT INTO transactions (account_id, related_account_id, amount, transaction_type, performed_by, description) VALUES
    -> (2, 1, 20000.00, 'withdrawal', 'teller_01', 'Transfer to AC100000000001'),
    -> (1, 2, 20000.00, 'deposit', 'teller_01', 'Transfer to AC100000000002');
Query OK, 2 rows affected (0.03 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> -- Update balances to reflect transactions (normally done via application logic / triggers)
mysql> UPDATE accounts SET balance = balance + 50000.00 WHERE account_no = 'AC1000000001';
Query OK, 0 rows affected (0.01 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> UPDATE accounts SET balance = balance + 150000.00 WHERE account_no = 'AC1000000002';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> UPDATE accounts SET balance = balance + 80000.00 WHERE account_no = 'AC1000000003';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> -- apply transfer: subtract from source, add to target
mysql> UPDATE accounts SET balance = balance - 20000.00 WHERE account_no = 'AC1000000002';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> UPDATE accounts SET balance = balance - 20000.00 WHERE account_no = 'AC1000000001';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 0  Changed: 0  Warnings: 0

mysql> -- Sample loan: Meera takes a loan linked to account ACC10000003
mysql> INSERT INTO loans (account_id, principal, balance, interest_rate, start_date, term_months) VALUES
    -> ((SELECT account_id FROM accounts WHERE account_no = 'ACC10000003'), 50000.00, 50000.00, 10.50, '2025-01-15', 60);
ERROR 1054 (42S22): Unknown column 'principal' in 'field list'
mysql> DESCRIBE loans;
+---------------+-------------------------------------+------+-----+---------+----------------+
| Field         | Type                                | Null | Key | Default | Extra          |
+---------------+-------------------------------------+------+-----+---------+----------------+
| loan_id       | int                                 | NO   | PRI | NULL    | auto_increment |
| account_id    | int                                 | NO   | MUL | NULL    |                |
| peincipal     | decimal(18,2)                       | NO   |     | NULL    |                |
| balance       | decimal(18,2)                       | NO   |     | NULL    |                |
| interest_rate | decimal(5,2)                        | NO   |     | NULL    |                |
| start_date    | date                                | YES  |     | NULL    |                |
| term_months   | int                                 | YES  |     | NULL    |                |
| status        | enum('active','closed','defaulted') | YES  |     | active  |                |
+---------------+-------------------------------------+------+-----+---------+----------------+
8 rows in set (0.01 sec)

mysql> ALTER TABLE loans
    -> RENAME COLUMN peincipal to principal;
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> -- Views for analytics
mysql> -- 1) account_balances: quick lookups of current balances (cached)
mysql> CREATE VIEW account_balances AS
    -> SELECT a.account_id, a.account_no, a.account_type, a.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    -> a.branch_id, b.name AS branch_name, a.balance, a.is_active
    -> FROM accounts a
    -> JOIN customers c ON a.customer_id = c.customer_id
    -> JOIN branches b ON a.branch_id = b.branch_id;
Query OK, 0 rows affected (0.01 sec)

mysql> -- 2) branch summary: number of accounts, total deposits (balance) per branch
mysql> CREATE VIEW branch_summary AS
    -> SELECT br.branch_id, br.name AS branch_name, COUNT(account_id) AS num_accounts,
    -> IFNULL(SUM(a.balance),0) AS total_deposits
    -> FROM branches br
    -> LEFT JOIN accounts a ON br.branch_id = a.branch_id
    -> GROUP BY br.branch_id, br.name;
Query OK, 0 rows affected (0.01 sec)

mysql> -- Show all accounts with balances:
mysql> SELECT * FROM account_balances ORDER BY balance DESC;
+------------+------------+--------------+-------------+---------------+-----------+----------------+-----------+-----------+
| account_id | account_no | account_type | customer_id | customer_name | branch_id | branch_name    | balance   | is_active |
+------------+------------+--------------+-------------+---------------+-----------+----------------+-----------+-----------+
|          2 | ACC100002  | current      |           2 | Sanjay Kumar  |         1 | Central Branch | 150000.00 |         1 |
|          1 | ACC100001  | savings      |           1 | Aditi Rao     |         1 | Central Branch |  50000.00 |         1 |
|          3 | ACC100003  | savings      |           3 | Meera Shah    |         2 | North Branch   |   8000.00 |         1 |
+------------+------------+--------------+-------------+---------------+-----------+----------------+-----------+-----------+
3 rows in set (0.00 sec)

mysql> -- Last 10 transactins for account no = 'ACC10000001'
mysql> SELECT t.*
    -> FROM transactions t
    -> JOIN accounts a ON t.account_id = a.account_id
    -> WHERE a.account_no = 'ACC1000000000001
    '> '
    -> ORDER BY t.created_at DESC
    -> LIMIT 10;
Empty set (0.00 sec)

mysql> -- Branch summary
mysql> SELECT * FROM branch_summary;
+-----------+----------------+--------------+----------------+
| branch_id | branch_name    | num_accounts | total_deposits |
+-----------+----------------+--------------+----------------+
|         1 | Central Branch |            2 |      200000.00 |
|         2 | North Branch   |            1 |        8000.00 |
|         3 | East Branch    |            0 |           0.00 |
+-----------+----------------+--------------+----------------+
3 rows in set (0.01 sec)

mysql> -- Active loans
mysql> SELECT l.*, a.account_no, CONCAT(c.first_name, ' ' , c.last_name) AS customer
    -> FROM loans l
    -> JOIN accounts a ON l.account_id = a.account_id
    -> JOIN customers c ON a.customer_id = c.customer_id
    -> WHERE l.status = 'active';
Empty set (0.00 sec)
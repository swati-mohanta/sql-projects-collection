mysql> CREATE DATABASE library_db;
Query OK, 1 row affected (0.01 sec)

mysql> USE library_db;
Database changed
mysql> CREATE TABLE books (
    -> book_id INT PRIMARY KEY,
    -> title VARCHAR(100),
    -> author VARCHAR(50),
    -> genre VARCHAR(30),
    -> available_copies INT
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> CREATE TABLE members (
    -> member_id INT PRIMARY KEY,
    -> name VARCHAR(50),
    -> membership_date DATE
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql> CREATE TABLE borrowings (
    -> borrow_id INT PRIMARY KEY,
    -> book_id INT,
    -> member_id INT,
    -> borrow_date DATE,
    -> return_date DATE,
    -> FOREIGN KEY (book_id) REFERENCES books(book_id),
    -> FOREIGN KEY (member_id) REFERENCES members(member_id)
    -> );
Query OK, 0 rows affected (0.06 sec)

mysql> INSERT INTO books VALUES
    -> (1, 'The Alchemist', 'Paulo Coelho', 'Fiction', 5),
    -> (2, 'Atomic Habits', 'James Clear', 'Slef-help', 3),
    -> (3, 'Clean Code', 'Robert C. Martin', 'Programming', 2),
    -> (4, 'To Kill a Mockingbird', 'Harper Lee', 'Classic', 4);
Query OK, 4 rows affected (0.01 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> INSERT INTO members VALUES
    -> (101, 'Amit Sharma', '2022-06-12'),
    -> (102, 'Neha Singh', '2023-01-20'),
    -> (103, 'Ravi Kumar', '2023-07-15');
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> INSERT INTO borrowings VALUES
    -> (1001, 1, 101, '2024-08-01', '2024-08-15'),
    -> (1002, 2, 102, '2024-08-05', NULL),
    -> (1003, 3, 103, '2024-08-10', '2024-08-20'),
    -> (1004, 1, 103, '2024-08-25', NULL);
Query OK, 4 rows affected (0.01 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM books;
+---------+-----------------------+------------------+-------------+------------------+
| book_id | title                 | author           | genre       | available_copies |
+---------+-----------------------+------------------+-------------+------------------+
|       1 | The Alchemist         | Paulo Coelho     | Fiction     |                5 |
|       2 | Atomic Habits         | James Clear      | Slef-help   |                3 |
|       3 | Clean Code            | Robert C. Martin | Programming |                2 |
|       4 | To Kill a Mockingbird | Harper Lee       | Classic     |                4 |
+---------+-----------------------+------------------+-------------+------------------+
4 rows in set (0.00 sec)

mysql> SELECT name FROM members
    -> WHERE membership_date > '2023-01-01';
+------------+
| name       |
+------------+
| Neha Singh |
| Ravi Kumar |
+------------+
2 rows in set (0.00 sec)

mysql> SELECT b.title, m.name, br.borrow_date
    -> FROM borrowings br
    -> JOIN books b ON br.book_id = b.book_id
    -> JOIN members m ON br.member_id = m.member_id
    -> WHERE br.return_date IS NULL;
+---------------+------------+-------------+
| title         | name       | borrow_date |
+---------------+------------+-------------+
| Atomic Habits | Neha Singh | 2024-08-05  |
| The Alchemist | Ravi Kumar | 2024-08-25  |
+---------------+------------+-------------+
2 rows in set (0.00 sec)

mysql> SELECT b.title, COUNT(br.borrow_id) AS total_borrowed
    -> FROM books b
    -> LEFT JOIN borrowings br ON b.book_id = br.book_id
    -> GROUP BY b.title
    -> ORDER BY total_borrowed DESC;
+-----------------------+----------------+
| title                 | total_borrowed |
+-----------------------+----------------+
| The Alchemist         |              2 |
| Atomic Habits         |              1 |
| Clean Code            |              1 |
| To Kill a Mockingbird |              0 |
+-----------------------+----------------+
4 rows in set (0.00 sec)

mysql> SELECT m.name, COUNT(br.borrow_id) AS total_borrowed
    -> FROM members m
    -> JOIN borrowings br ON m.member_id = br.member_id
    -> GROUP BY m.name
    -> HAVING COUNT(br.borrow_id) > 1;
+------------+----------------+
| name       | total_borrowed |
+------------+----------------+
| Ravi Kumar |              2 |
+------------+----------------+
1 row in set (0.00 sec)

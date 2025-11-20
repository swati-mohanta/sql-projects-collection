mysql> CREATE DATABASE student_db;
Query OK, 1 row affected (0.01 sec)

mysql> USE student_db;
Database changed
mysql> CREATE TABLE students (
    -> student_id INT PRIMARY KEY,
    -> name VARCHAR(50),
    -> age INT,
    -> gender VARCHAR(10),
    -> department VARCHAR(50)
    -> );
Query OK, 0 rows affected (0.03 sec)

mysql> CREATE TABLE courses (
    -> course_id INT PRIMARY KEY,
    -> course_name VARCHAR(50),
    -> credits INT
    -> );
Query OK, 0 rows affected (0.02 sec)

mysql> CREATE TABLE enrollments (
    -> enrollment_id INT PRIMARY KEY,
    -> student_id INT ,
    -> course_id INT,
    -> grade VARCHAR(2),
    -> FOREIGN KEY (student_id) REFERENCES students(student_id),
    -> FOREIGN KEY (course_id) REFERENCES courses(course_id)
    -> );
Query OK, 0 rows affected (0.05 sec)

mysql> INSERT INTO students VALUES
    -> (1, 'Amit Sharma', 20, 'Male', 'Computer Science'),
    -> (2, 'Neha Singh', 21, 'Female', 'Electronics'),
    -> (3, 'Ravi Kumar', 19, 'Male', 'Mechanical'),
    -> (4, 'Priya Verma', 22, 'Female', 'Computer Science');
Query OK, 4 rows affected (0.01 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> INSERT INTO courses VALUES
    -> (101, 'Database Systems', 4),
    -> (102, 'Operating Systems', 3),
    -> (103, 'Data Structures', 4);
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> INSERT INTO enrollments VALUES
    -> (1001, 1, 101, 'A'),
    -> (1002, 2, 103, 'B'),
    -> (1003, 3, 102, 'A'),
    -> (1004, 1, 103, 'B'),
    -> (1005, 4, 101, 'A');
Query OK, 5 rows affected (0.01 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM students;
+------------+-------------+------+--------+------------------+
| student_id | name        | age  | gender | department       |
+------------+-------------+------+--------+------------------+
|          1 | Amit Sharma |   20 | Male   | Computer Science |
|          2 | Neha Singh  |   21 | Female | Electronics      |
|          3 | Ravi Kumar  |   19 | Male   | Mechanical       |
|          4 | Priya Verma |   22 | Female | Computer Science |
+------------+-------------+------+--------+------------------+
4 rows in set (0.00 sec)

mysql> SELECT name, age FROM students WHERE department = 'Computer Science';
+-------------+------+
| name        | age  |
+-------------+------+
| Amit Sharma |   20 |
| Priya Verma |   22 |
+-------------+------+
2 rows in set (0.00 sec)

mysql> SELECT s.name, c.course_name, e.grade
    -> FROM students s
    -> JOIN courses c ON s.student_id = e.student_id
    -> JOIN courses c ON e.course_id = c.course_id
    -> WHERE s.name = 'Amit Sharma';
ERROR 1066 (42000): Not unique table/alias: 'c'
mysql> SELECT s.name, c.course_name, e.grade
    -> FROM students s
    -> JOIN enrollments e ON s.student_id = e.student_id
    -> JOIN courses c ON e.course_id = c.course_id
    -> WHERE s.name = 'Amit Sharma';
+-------------+------------------+-------+
| name        | course_name      | grade |
+-------------+------------------+-------+
| Amit Sharma | Database Systems | A     |
| Amit Sharma | Data Structures  | B     |
+-------------+------------------+-------+
2 rows in set (0.00 sec)

mysql> SELECT c.course_name, COUNT(e.student_id) AS total_students
    -> FROM courses c
    -> JOIN enrollments e ON c.course_id = e.course_id
    -> GROUP BY c.course_name;
+-------------------+----------------+
| course_name       | total_students |
+-------------------+----------------+
| Database Systems  |              2 |
| Operating Systems |              1 |
| Data Structures   |              2 |
+-------------------+----------------+
3 rows in set (0.00 sec)

mysql> UPDATE enrollments
    -> SET grade = 'A+'
    -> WHERE enrollment_id = 1004;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

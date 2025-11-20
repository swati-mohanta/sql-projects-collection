mysql> CREATE DATABASE hospital_management_db;
Query OK, 1 row affected (0.01 sec)

mysql> USE hospital_management_db;
Database changed

mysql> -- Departments
mysql> CREATE TABLE departments (
    -> department_id INT AUTO_INCREMENT PRIMARY KEY,
    -> name VARCHAR(100) NOT NULL UNIQUE,
    -> floor INT,
    -> phone_extension VARCHAR(20)
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.05 sec)

mysql> -- Patients
mysql> CREATE TABLE patients (
    -> patient_id INT AUTO_INCREMENT PRIMARY KEY,
    -> first_name VARCHAR(50) NOT NULL,
    -> last_name VARCHAR(50) NOT NULL,
    -> dob DATE,
    -> gender ENUM('Male', 'Female', 'Other') DEFAULT 'Other',
    -> phone VARCHAR(30),
    -> email VARCHAR(150),
    -> address TEXT,
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.02 sec)

mysql> -- Doctors
mysql> CREATE TABLE doctors (
    -> doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    -> first_name VARCHAR(50) NOT NULL,
    -> last_name VARCHAR(50) NOT NULL,
    -> specialization VARCHAR(100),
    -> department_id INT,
    -> phone VARCHAR(30),
    -> email VARCHAR(150),
    -> hire_date DATE,
    -> CONSTRAINT fk_doctors_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.04 sec)

mysql> -- Appointments
mysql> CREATE TABLE appointments (
    -> appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    -> patient_id INT NOT NULL,
    -> doctor_id INT,
    -> appointment_dt DATETIME NOT NULL,
    -> reason TEXT,
    -> status ENUM('scheduled', 'completed', 'cancelled', 'no-show') DEFAULT'scheduled',
    -> created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    -> CONSTRAINT fk_appointments_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_appointments_doctor FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id) ON DELETE SET NULL
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.06 sec)

mysql> -- Treatments (linked to appointments)
mysql> CREATE TABLE treatments (
    -> treatment_id INT AUTO_INCREMENT PRIMARY KEY,
    -> appointment_id INT NOT NULL,
    -> diagnosis VARCHAR(255),
    -> medication TEXT,
    -> procedure_name VARCHAR(255),
    -> notes TEXT,
    -> cost DECIMAL(12,2) DEFAULT 0.00,
    -> CONSTRAINT fk_treatments_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE CASCADE
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.04 sec)

mysql> -- Bills
mysql> CREATE TABLE bills (
    -> bill_id INT AUTO_INCREMENT PRIMARY KEY,
    -> patient_id INT NOT NULL,
    -> appointment_id INT,
    -> amount_due DECIMAL(12,2) NOT NULL,
    -> amount_paid DECIMAL(12,2) DEFAULT 0.00,
    -> billing_date DATE DEFAULT (CURRENT_DATE),
    -> paid BOOLEAN DEFAULT FALSE,
    -> payment_method VARCHAR(50), -- card/cash/insurance
    -> notes TEXT,
    -> CONSTRAINT fk_bills_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE CASCADE,
    -> CONSTRAINT fk_bills_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id) ON DELETE SET NULL
    -> ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
Query OK, 0 rows affected (0.06 sec)

mysql> -- Indexes for common queries
mysql> CREATE INDEX idx_appointments_dt ON appointments(appointment_dt);
Query OK, 0 rows affected (0.07 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_bills_patient ON bills(patient_id);
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> CREATE INDEX idx_treatments_app ON treatments(appointment_id);
Query OK, 0 rows affected (0.03 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> -- Sample data: departments
mysql> INSERT INTO departments (name, floor, phone_extension) VALUES
    -> ('Cardiology', 2, '2101'),
    -> ('Neurology', 3, '3101'),
    -> ('Orthopedics', 4, '4101'),
    -> ('Emergency', 1, '1100');
Query OK, 4 rows affected (0.01 sec)
Records: 4  Duplicates: 0  Warnings: 0

mysql> -- Sample data: patients
mysql> INSERT INTO patients (first_name, last_name, dob, gender, phone, email, address) VALUES
    -> ('Asha', 'Patel', '1985-07-12', 'Female', '9810012345', 'asha.patel@example.com', '12 Rose St, Mumbai'),
    -> ('Rahul', 'Meher', '1992-01-23', 'Male', '9820023456', 'rahul.meher@example.com', '45 Lake Rd, Pune'),
    -> ('Sana', 'Roy', '1978-11-18', 'Female', '9830034567', 'sana.roy@example.com', '9 Hill Lane, Kolkata'),
    -> ('Arjun', 'Singh', '2000-03-18', 'Male', '9840045678', 'arjun.singh@example.com', '77 MG Rd, Delhi'),
    -> ('Maya', 'Iyer', '1969-12-30', 'Female', '9850056789', 'maya.iyer@example.com', '101 Palm Ave, Chennai');
Query OK, 5 rows affected (0.01 sec)
Records: 5  Duplicates: 0  Warnings: 0


mysql> -- Sample data: doctors
mysql> INSERT INTO doctors (first_name, last_name, specialization, department_id, phone, email, hire_date) VALUES
    -> ('Neha', 'Kulkarni', 'Cardiologist', 1, '9900012345', 'neha.k@example.com', '2015-06-15'),
    -> ('Vikram', 'Shah', 'Neurologist', 2, '9900023456', 'vikram.s@example.com', '2018-01-20'),
    -> ('Sunil', 'Reddy', 'Orthopedic Surgeon', 3, '9900034567', 'sunil.r@example.com', '2010-09-10'),
    -> ('Priya', 'Nair', 'Emergency Medicine', 4, '9900045678', 'priya.n@example.com', '2020-03-05'),
    -> ('Karan', 'Gupta', 'General Physician', 4, '9900056789', 'karan.g@example.com', '2012-11-01');
Query OK, 5 rows affected (0.01 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> -- Sample data: appointments
mysql> INSERT INTO appointments (patient_id, doctor_id, appointment_dt, reason, status) VALUES
    -> (1, 1, '2025-11-10 09:00:00', 'Chest pain follow-up', 'completed'),
    -> (2, 5, '2025-11-12 14:30:00', 'Fever and Cough', 'completed'),
    -> (3, 2, '2025-11-15 11:00:00', 'Migraine evaluation', 'scheduled'),
    -> (4, 3, '2025-11-18 16:00:00', 'Knee pain', 'scheduled'),
    -> (5, 4, '2025-11-19 01:30:00', 'Admitted: Accident', 'completed'),
    -> (1, 1, '2025-11-20 12:00:00', 'ECG review', 'scheduled'),
    -> (2, 5, '2025-11-20 10:00:00', 'Follow-up visit', 'scheduled'),
    -> (3, 2, '2025-11-21 09:30:00', 'Neurological tests', 'scheduled'),
    -> (4, 3, '2025-11-21 11:00:00', 'Physical therapy consult', 'scheduled'),
    -> (5, 4, '2025-11-22 07:00:00', 'Observation', 'scheduled');
Query OK, 10 rows affected (0.01 sec)
Records: 10  Duplicates: 0  Warnings: 0

mysql> -- Sample data: treatments (for completed appts)
mysql> INSERT INTO treatments (appointment_id, diagnosis, medication, procedure_name, notes, cost) VALUES
    -> (1, 'Stable angina', 'Aspirin, Beta-blocker', 'ECG', 'No complications', 1500.00),
    -> (2, 'Acute bronchitis', 'Antibiotics', 'Chest X-ray', 'Prescribed rest', 800.00),
    -> (5, 'Multiple fractures', 'Pain Management', 'Surgery: ORIF', 'Surgery Successful', 45000.00);
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> -- Sample data: bills
mysql> INSERT INTO bills (patient_id, appointment_id, amount_due, amount_paid, billing_date, paid, payment_method, notes) VALUES
    -> (1, 1, 2000.00, 2000.00, '2025-11-11', TRUE, 'card', 'Includes consultation & tests'),
    -> (2, 2, 1000.00, 1000.00, '2025-11-13', TRUE, 'cash', 'OPD visit'),
    -> (5, 5, 47000.00, 10000.00, '2025-11-20', FALSE, 'insurance', 'Partial paid, surgery balance');
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> -- View: outstanding amount per patient
mysql> CREATE VIEW patient_outstanding AS
    -> SELECT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, IFNULL(SUM(b.amount_due - b.amount_paid),0) AS outstanding FROM patients p LEFT JOIN bills b ON p.patient_id = b.patient_id GROUP BY p.patient_id, patient_name;
Query OK, 0 rows affected (0.02 sec)

mysql> -- list upcoming appointments (next 7 days)
mysql> SELECT a.*, CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    -> CONCAT(d.first_name, ' ', d.last_name) AS doctor_name
    -> FROM appointments a
    -> JOIN PATIENTS p ON a.patient_id = p.patient_id
    -> LEFT JOIN doctors d ON a.doctor_id = d.doctor_id
    -> WHERE a.appointment_dt BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)
    -> ORDER BY a.appointment_dt;
+----------------+------------+-----------+---------------------+--------------------------+-----------+---------------------+--------------+-------------+
| appointment_id | patient_id | doctor_id | appointment_dt      | reason                   | status    | created_at          | patient_name | doctor_name |
+----------------+------------+-----------+---------------------+--------------------------+-----------+---------------------+--------------+-------------+
|              8 |          3 |         2 | 2025-11-21 09:30:00 | Neurological tests       | scheduled | 2025-11-20 13:05:42 | Sana Roy     | Vikram Shah |
|              9 |          4 |         3 | 2025-11-21 11:00:00 | Physical therapy consult | scheduled | 2025-11-20 13:05:42 | Arjun Singh  | Sunil Reddy |
|             10 |          5 |         4 | 2025-11-22 07:00:00 | Observation              | scheduled | 2025-11-20 13:05:42 | Maya Iyer    | Priya Nair  |
+----------------+------------+-----------+---------------------+--------------------------+-----------+---------------------+--------------+-------------+
3 rows in set (0.01 sec)

mysql> -- Patients per department (distinct patients):
mysql> SELECT dept.name, COUNT(DISTINCT a.patient_id) AS patient_count
    -> FROM departments dept
    -> JOIN doctors doc ON doc.department_id = dept.department_id
    -> JOIN appointments a ON a.doctor_id = doc.doctor_id
    -> GROUP BY dept.name;
+-------------+---------------+
| name        | patient_count |
+-------------+---------------+
| Cardiology  |             1 |
| Emergency   |             2 |
| Neurology   |             1 |
| Orthopedics |             1 |
+-------------+---------------+
4 rows in set (0.01 sec)

mysql> -- Busiest doctor in last 30 days

    -> ;
ERROR 1109 (42S02): Unknown table 'd' in field list
mysql> -- Busiest doctor in last 30 days
mysql> SELECT CONCAT(d.first_name, ' ', d.last_name) AS doctor_name, COUNT(*) AS appts
    -> FROM appointments a
    -> JOIN doctors d ON a.doctor_id = d.doctor_id
    -> WHERE a.appointment_dt >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    -> GROUP BY doctor_name
    -> ORDER BY appts DESC
    -> LIMIT 1;
+---------------+-------+
| doctor_name   | appts |
+---------------+-------+
| Neha Kulkarni |     2 |
+---------------+-------+
1 row in set (0.01 sec)

mysql> -- Total revenue (amount_paid) by month:
mysql> SELECT DATE_FORMAT(billing_date, '%Y-%m-01')AS month_start, SUM(amount_paid) AS revenue
    -> FROM bills
    -> GROUP BY month_start
    -> ORDER BY month_start DESC;
+-------------+----------+
| month_start | revenue  |
+-------------+----------+
| 2025-11-01  | 13000.00 |
+-------------+----------+
1 row in set (0.00 sec)

mysql> -- Patients with outstanding balances
mysql> SELECT p.patient_id, CONCAT(p.first_name, ' ' , p.last_name) AS name, SUM(b.amount_due - b.amount_paid) AS outstanding
    -> FROM patients p
    -> JOIN bills b ON p.patient_id = b.patient_id
    -> GROUP BY p.patient_id, name
    -> HAVING outstanding > 0;
+------------+-----------+-------------+
| patient_id | name      | outstanding |
+------------+-----------+-------------+
|          5 | Maya Iyer |    37000.00 |
+------------+-----------+-------------+
1 row in set (0.00 sec)

mysql> -- Treatments & costs for patient_id = 5:
mysql> SELECT t.*, a.appointment_dt
    -> FROM treatments t
    -> JOIN appointments a ON t.appointment_id = a.appointment_id
    -> WHERE a.patient_id = 5;
+--------------+----------------+--------------------+-----------------+----------------+--------------------+----------+---------------------+
| treatment_id | appointment_id | diagnosis          | medication      | procedure_name | notes              | cost     | appointment_dt      |
+--------------+----------------+--------------------+-----------------+----------------+--------------------+----------+---------------------+
|            3 |              5 | Multiple fractures | Pain Management | Surgery: ORIF  | Surgery Successful | 45000.00 | 2025-11-19 01:30:00 |
+--------------+----------------+--------------------+-----------------+----------------+--------------------+----------+---------------------+
1 row in set (0.00 sec)

mysql> -- Average cost per procedure_name:
mysql> SELECT procedure_name, COUNT(*) AS times_given, AVG(cost) AS avg_cost
    -> FROM treatments
    -> GROUP BY procedure_name
    -> ORDER BY avg_cost DESC;
+----------------+-------------+--------------+
| procedure_name | times_given | avg_cost     |
+----------------+-------------+--------------+
| Surgery: ORIF  |           1 | 45000.000000 |
| ECG            |           1 |  1500.000000 |
| Chest X-ray    |           1 |   800.000000 |
+----------------+-------------+--------------+
3 rows in set (0.00 sec)

mysql> -- Recent Emergency department visits (last 7 days):
mysql> SELECT a.*, CONCAT(p.first_name, ' ', p.last_name) AS patient, CONCAT(d.first_name, ' ' , d.last_name) AS doctor
    -> FROM appointments a
    -> JOIN doctors d ON a.doctor_id = d.doctor_id
    -> JOIN departments dept ON d.department_id = dept.department_id
    -> JOIN patients p ON p.patient_id = a.patient_id
    -> WHERE dept.name = 'Emergency' AND a.appointment_dt >= DATE_SUB(NOW(), INTERVAL 7 DAY);
+----------------+------------+-----------+---------------------+--------------------+-----------+---------------------+-------------+-------------+
| appointment_id | patient_id | doctor_id | appointment_dt      | reason             | status    | created_at          | patient     | doctor      |
+----------------+------------+-----------+---------------------+--------------------+-----------+---------------------+-------------+-------------+
|              5 |          5 |         4 | 2025-11-19 01:30:00 | Admitted: Accident | completed | 2025-11-20 13:05:42 | Maya Iyer   | Priya Nair  |
|             10 |          5 |         4 | 2025-11-22 07:00:00 | Observation        | scheduled | 2025-11-20 13:05:42 | Maya Iyer   | Priya Nair  |
|              7 |          2 |         5 | 2025-11-20 10:00:00 | Follow-up visit    | scheduled | 2025-11-20 13:05:42 | Rahul Meher | Karan Gupta |
+----------------+------------+-----------+---------------------+--------------------+-----------+---------------------+-------------+-------------+
3 rows in set (0.00 sec)

mysql> -- Find no-shows:
mysql> SELECT a.*, CONCAT(p.first_name, ' ', p.last_name) AS patient
    -> FROM appointments a
    -> JOIN patients p ON a.patient_id = p.patient_id
    -> WHERE a.status = 'no-show';
Empty set (0.00 sec)

mysql> SELECT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS name,
    -> IFNULL(SUM(b.amount_due),0) AS total_due, IFNULL(SUM(b.amount_paid),0) AS total_paid
    -> FROM patients p
    -> LEFT JOIN bills b ON p.patient_id = b.patient_id
    -> GROUP BY p.patient_id, name;
+------------+-------------+-----------+------------+
| patient_id | name        | total_due | total_paid |
+------------+-------------+-----------+------------+
|          1 | Asha Patel  |   2000.00 |    2000.00 |
|          2 | Rahul Meher |   1000.00 |    1000.00 |
|          3 | Sana Roy    |      0.00 |       0.00 |
|          4 | Arjun Singh |      0.00 |       0.00 |
|          5 | Maya Iyer   |  47000.00 |   10000.00 |
+------------+-------------+-----------+------------+
5 rows in set (0.00 sec)

mysql> -- Top 5 most expensive procedures (avg cost):
mysql> SELECT procedure_name, AVG(cost) AS avg_cost
    -> FROM treatments
    -> GROUP BY procedure_name
    -> ORDER BY avg_cost DESC
    -> LIMIT 5;
+----------------+--------------+
| procedure_name | avg_cost     |
+----------------+--------------+
| Surgery: ORIF  | 45000.000000 |
| ECG            |  1500.000000 |
| Chest X-ray    |   800.000000 |
+----------------+--------------+
3 rows in set (0.00 sec)

mysql> -- Insert a new appointment
mysql> INSERT INTO appointments (patient_id, doctor_id, appointment_dt, reason, status) VALUES
    -> (3, 2, '2025-12-01 10:30:00', 'Follow-up brain MRI review', 'scheduled');
Query OK, 1 row affected (0.01 sec)

mysql> -- Mark appointment completed + insert treatment:
mysql> UPDATE appointments SET status = 'completed' WHERE appointment_id = 3;
Query OK, 1 row affected (0.01 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> INSERT INTO treatments (appointment_id, diagnosis, medication, procedure_name, notes, cost) VALUES
    -> (3, 'Migrane - improved', 'Triptans', 'MRI review', 'Prescribed preventive therapy', 1200.00);
Query OK, 1 row affected (0.00 sec)

mysql> -- Last appointment per patient (using window function):
mysql> WITH ranked AS (
    -> SELECT patient_id, appointment_id, appointment_dt,
    -> ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY appointment_dt DESC) RN
    -> FROM appointments
    -> )
    -> SELECT r.patient_id, r.appointment_id, r.appointment_dt
    -> FROM ranked r
    -> WHERE r.rn = 1;
+------------+----------------+---------------------+
| patient_id | appointment_id | appointment_dt      |
+------------+----------------+---------------------+
|          1 |              6 | 2025-11-20 12:00:00 |
|          2 |              7 | 2025-11-20 10:00:00 |
|          3 |             11 | 2025-12-01 10:30:00 |
|          4 |              9 | 2025-11-21 11:00:00 |
|          5 |             10 | 2025-11-22 07:00:00 |
+------------+----------------+---------------------+
5 rows in set (0.01 sec)

mysql> -- Last appointment per patient (using window function):
mysql> WITH ranked AS (
    -> SELECT patient_id, appointment_id, appointment_dt,
    -> ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY appointment_dt DESC) rn
    -> FROM appointments
    -> )
    -> SELECT r.patient_id, r.appointment_id, r.appointment_dt
    -> FROM ranked r
    -> WHERE r.rn = 1;
+------------+----------------+---------------------+
| patient_id | appointment_id | appointment_dt      |
+------------+----------------+---------------------+
|          1 |              6 | 2025-11-20 12:00:00 |
|          2 |              7 | 2025-11-20 10:00:00 |
|          3 |             11 | 2025-12-01 10:30:00 |
|          4 |              9 | 2025-11-21 11:00:00 |
|          5 |             10 | 2025-11-22 07:00:00 |
+------------+----------------+---------------------+
5 rows in set (0.00 sec)

mysql> -- Delete cancelled appointments older than 90 days:
mysql> DELETE FROM appointments
    -> WHERE status = 'cancelled' AND appointment_dt < DATE_SUB(NOW(), INTERVAL 90 DAY);
Query OK, 0 rows affected (0.00 sec)

mysql> -- Unpaid bills greater than 10,000:
mysql> SELECT * FROM bills WHERE paid = FALSE AND (amount_due - amount_paid) > 10000;
+---------+------------+----------------+------------+-------------+--------------+------+----------------+-------------------------------+
| bill_id | patient_id | appointment_id | amount_due | amount_paid | billing_date | paid | payment_method | notes                         |
+---------+------------+----------------+------------+-------------+--------------+------+----------------+-------------------------------+
|       3 |          5 |              5 |   47000.00 |    10000.00 | 2025-11-20   |    0 | insurance      | Partial paid, surgery balance |
+---------+------------+----------------+------------+-------------+--------------+------+----------------+-------------------------------+
1 row in set (0.00 sec)

mysql> -- Patient Statement (bills + treatments) for patients_id = 5:
mysql> SELECT p.patient_id, CONCAT(p.first_name, ' ' , p.last_name) AS patient, b.billing_date, b.amount_due, b.amount_paid, t.diagnosis, t.procedure_name
    -> FROM patients p
    -> LEFT JOIN bills b ON p.patient_id = b.patient_id
    -> LEFT JOIN appointments a ON a.appointment_id = b.appointment_id
    -> LEFT JOIN treatments t ON t.appointment_id = a.appointment_id
    -> WHERE p.patient_id = 5
    -> ORDER BY b.billing_date;
+------------+-----------+--------------+------------+-------------+--------------------+----------------+
| patient_id | patient   | billing_date | amount_due | amount_paid | diagnosis          | procedure_name |
+------------+-----------+--------------+------------+-------------+--------------------+----------------+
|          5 | Maya Iyer | 2025-11-20   |   47000.00 |    10000.00 | Multiple fractures | Surgery: ORIF  |
+------------+-----------+--------------+------------+-------------+--------------------+----------------+
1 row in set (0.00 sec)
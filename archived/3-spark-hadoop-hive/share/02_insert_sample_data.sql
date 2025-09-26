-- Hive 示例：插入样本数据
USE test_db;

-- 插入员工数据
INSERT INTO employees VALUES
(1, '张三', 'IT', 8000.0, '2020-01-15'),
(2, '李四', 'HR', 6500.0, '2019-03-20'),
(3, '王五', 'Finance', 7200.0, '2021-06-10'),
(4, '赵六', 'IT', 9500.0, '2018-11-05'),
(5, '钱七', 'Marketing', 7800.0, '2020-09-12'),
(6, '孙八', 'IT', 8500.0, '2021-02-28'),
(7, '周九', 'HR', 6800.0, '2019-12-01'),
(8, '吴十', 'Finance', 7500.0, '2020-07-15');

-- 插入部门数据
INSERT INTO departments VALUES
(1, 'IT', 'Beijing', '张三'),
(2, 'HR', 'Shanghai', '李四'),
(3, 'Finance', 'Guangzhou', '王五'),
(4, 'Marketing', 'Shenzhen', '钱七');

-- 为分区表插入数据（需要指定分区）
INSERT INTO sales_data PARTITION(year=2023, month=1) VALUES
('T001', 'Laptop', 2, 5999.99, 'C001'),
('T002', 'Mouse', 5, 99.99, 'C002'),
('T003', 'Keyboard', 3, 299.99, 'C001');

INSERT INTO sales_data PARTITION(year=2023, month=2) VALUES
('T004', 'Monitor', 1, 1299.99, 'C003'),
('T005', 'Headphones', 2, 199.99, 'C002'),
('T006', 'Webcam', 1, 399.99, 'C004');

INSERT INTO sales_data PARTITION(year=2023, month=3) VALUES
('T007', 'Tablet', 1, 2999.99, 'C005'),
('T008', 'Phone', 2, 3999.99, 'C003'),
('T009', 'Charger', 4, 49.99, 'C001');

-- 验证数据插入
SELECT COUNT(*) as employee_count FROM employees;
SELECT COUNT(*) as department_count FROM departments;
SELECT COUNT(*) as sales_count FROM sales_data;

-- 显示插入的数据
SELECT * FROM employees LIMIT 10;
SELECT * FROM departments;
SELECT * FROM sales_data LIMIT 10;
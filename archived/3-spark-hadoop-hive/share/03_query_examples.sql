-- Hive 查询示例：各种SQL功能演示
USE test_db;

-- 1. 基础查询
SELECT '=== 基础查询示例 ===' as section;

-- 查询所有员工
SELECT * FROM employees;

-- 查询特定字段
SELECT name, department, salary FROM employees;

-- 条件查询
SELECT * FROM employees WHERE salary > 7000;

-- 2. 聚合函数
SELECT '=== 聚合函数示例 ===' as section;

-- 统计员工总数
SELECT COUNT(*) as total_employees FROM employees;

-- 计算平均工资
SELECT AVG(salary) as avg_salary FROM employees;

-- 查找最高和最低工资
SELECT MAX(salary) as max_salary, MIN(salary) as min_salary FROM employees;

-- 计算工资总和
SELECT SUM(salary) as total_salary FROM employees;

-- 3. 分组查询
SELECT '=== 分组查询示例 ===' as section;

-- 按部门分组统计
SELECT department, COUNT(*) as emp_count, AVG(salary) as avg_salary
FROM employees 
GROUP BY department;

-- 按部门分组，只显示员工数大于1的部门
SELECT department, COUNT(*) as emp_count
FROM employees 
GROUP BY department 
HAVING COUNT(*) > 1;

-- 4. 排序
SELECT '=== 排序示例 ===' as section;

-- 按工资降序排列
SELECT name, salary FROM employees ORDER BY salary DESC;

-- 按部门升序，工资降序排列
SELECT name, department, salary 
FROM employees 
ORDER BY department ASC, salary DESC;

-- 5. 连接查询
SELECT '=== 连接查询示例 ===' as section;

-- 内连接：员工和部门信息
SELECT e.name, e.salary, d.dept_name, d.location
FROM employees e
JOIN departments d ON e.department = d.dept_name;

-- 左连接示例
SELECT e.name, e.department, d.location
FROM employees e
LEFT JOIN departments d ON e.department = d.dept_name;

-- 6. 子查询
SELECT '=== 子查询示例 ===' as section;

-- 查询工资高于平均工资的员工
SELECT name, salary 
FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 查询每个部门工资最高的员工
SELECT name, department, salary
FROM employees e1
WHERE salary = (
    SELECT MAX(salary) 
    FROM employees e2 
    WHERE e1.department = e2.department
);

-- 7. 分区表查询
SELECT '=== 分区表查询示例 ===' as section;

-- 查询特定分区的数据
SELECT * FROM sales_data WHERE year = 2023 AND month = 1;

-- 查询多个分区的数据
SELECT * FROM sales_data WHERE year = 2023 AND month IN (1, 2);

-- 按分区统计销售数据
SELECT year, month, COUNT(*) as transaction_count, SUM(quantity * price) as total_sales
FROM sales_data 
GROUP BY year, month 
ORDER BY year, month;

-- 8. 字符串函数
SELECT '=== 字符串函数示例 ===' as section;

-- 字符串长度和大小写转换
SELECT name, 
       LENGTH(name) as name_length,
       UPPER(name) as upper_name,
       LOWER(department) as lower_dept
FROM employees;

-- 字符串连接
SELECT CONCAT(name, ' - ', department) as employee_info FROM employees;

-- 字符串截取
SELECT name, SUBSTR(name, 1, 1) as first_char FROM employees;

-- 9. 日期函数
SELECT '=== 日期函数示例 ===' as section;

-- 日期格式化和计算
SELECT name, hire_date,
       YEAR(hire_date) as hire_year,
       MONTH(hire_date) as hire_month,
       DATEDIFF(CURRENT_DATE, hire_date) as days_since_hire
FROM employees;

-- 10. 条件表达式
SELECT '=== 条件表达式示例 ===' as section;

-- CASE WHEN 语句
SELECT name, salary,
       CASE 
           WHEN salary >= 9000 THEN '高薪'
           WHEN salary >= 7000 THEN '中薪'
           ELSE '基础薪资'
       END as salary_level
FROM employees;

-- 11. 窗口函数（如果支持）
SELECT '=== 窗口函数示例 ===' as section;

-- 排名函数
SELECT name, department, salary,
       ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank,
       RANK() OVER (ORDER BY salary DESC) as overall_rank
FROM employees;

-- 累计统计
SELECT name, department, salary,
       SUM(salary) OVER (PARTITION BY department ORDER BY salary) as running_total
FROM employees;

-- 12. 数据统计分析
SELECT '=== 数据统计分析示例 ===' as section;

-- 部门薪资统计
SELECT department,
       COUNT(*) as employee_count,
       MIN(salary) as min_salary,
       MAX(salary) as max_salary,
       AVG(salary) as avg_salary,
       STDDEV(salary) as salary_stddev
FROM employees
GROUP BY department;

-- 销售数据分析
SELECT product_name,
       COUNT(*) as transaction_count,
       SUM(quantity) as total_quantity,
       AVG(price) as avg_price,
       SUM(quantity * price) as total_revenue
FROM sales_data
GROUP BY product_name
ORDER BY total_revenue DESC;
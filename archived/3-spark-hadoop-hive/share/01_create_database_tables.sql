-- Hive 基础示例：创建数据库和表
-- 创建数据库
CREATE DATABASE IF NOT EXISTS test_db
COMMENT 'Test database for Hive examples'
LOCATION '/user/hive/warehouse/test_db.db';

-- 使用数据库
USE test_db;

-- 创建员工表
CREATE TABLE IF NOT EXISTS employees (
    id INT,
    name STRING,
    department STRING,
    salary DOUBLE,
    hire_date DATE
)
COMMENT 'Employee information table'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- 创建部门表
CREATE TABLE IF NOT EXISTS departments (
    dept_id INT,
    dept_name STRING,
    location STRING,
    manager STRING
)
COMMENT 'Department information table'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- 创建分区表示例（按年份分区）
CREATE TABLE IF NOT EXISTS sales_data (
    transaction_id STRING,
    product_name STRING,
    quantity INT,
    price DOUBLE,
    customer_id STRING
)
PARTITIONED BY (year INT, month INT)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- 显示所有表
SHOW TABLES;

-- 显示表结构
DESCRIBE employees;
DESCRIBE departments;
DESCRIBE sales_data;
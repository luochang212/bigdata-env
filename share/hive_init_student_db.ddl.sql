-- 创建数据库
CREATE DATABASE IF NOT EXISTS student_db;

-- USE student_db;

-- 创建学生成绩表
CREATE TABLE IF NOT EXISTS student_db.student_scores (
    student_id INT COMMENT '学生ID',
    student_name STRING COMMENT '学生姓名',
    course_name STRING COMMENT '课程名称',
    score INT COMMENT '成绩分数',
    exam_date STRING COMMENT '考试日期，格式：yyyy-MM-dd'
)
COMMENT '学生成绩记录表'
PARTITIONED BY (day STRING COMMENT 'day')
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;

-- 创建分区并从本地文件加载数据
LOAD DATA LOCAL INPATH '/opt/share/hive_data/score_20250615.txt' 
OVERWRITE INTO TABLE student_db.student_scores 
PARTITION (day='2025-06-15');

LOAD DATA LOCAL INPATH '/opt/share/hive_data/score_20250616.txt' 
OVERWRITE INTO TABLE student_db.student_scores 
PARTITION (day='2025-06-16');

LOAD DATA LOCAL INPATH '/opt/share/hive_data/score_20250617.txt' 
OVERWRITE INTO TABLE student_db.student_scores 
PARTITION (day='2025-06-17');

-- 打印表分区
show partitions student_db.student_scores;

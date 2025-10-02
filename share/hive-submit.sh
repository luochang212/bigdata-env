# 建学生成绩表，插入数据
hive -f hive_init_student_db.ddl.sql

# 计算学生平均分
hive -f hive_analysis.sql

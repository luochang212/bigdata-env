# 项目文档

## 💻 使用说明

### Spark 任务提交
```bash
# 进入主节点容器
docker exec -it spark-hadoop-hive-master bash

# 提交 Spark 任务
spark-submit \
  --class org.apache.spark.examples.SparkPi \
  --master spark://master:7077 \
  --deploy-mode client \
  $SPARK_HOME/examples/jars/spark-examples_2.12-3.3.0.jar \
  10
```

### HDFS 操作
```bash
# 查看 HDFS 文件系统
hdfs dfs -ls /

# 创建目录
hdfs dfs -mkdir /user/data

# 上传文件
hdfs dfs -put /opt/share/sample.txt /user/data/

# 下载文件
hdfs dfs -get /user/data/sample.txt /opt/share/
```

### Hive 数据操作
```bash
# 启动 Hive CLI
hive

# 创建数据库
CREATE DATABASE IF NOT EXISTS test_db;

# 使用数据库
USE test_db;

# 创建表
CREATE TABLE IF NOT EXISTS employees (
  id INT,
  name STRING,
  department STRING
) STORED AS TEXTFILE;

# 插入数据
INSERT INTO employees VALUES (1, 'John', 'IT'), (2, 'Jane', 'HR');

# 查询数据
SELECT * FROM employees;
```

### JupyterLab 中使用 PySpark
```python
from pyspark.sql import SparkSession

# 创建 Spark 会话
spark = SparkSession.builder \
    .appName("BigDataEnv") \
    .master("spark://master:7077") \
    .getOrCreate()

# 创建 DataFrame
data = [("Alice", 25), ("Bob", 30), ("Charlie", 35)]
columns = ["name", "age"]
df = spark.createDataFrame(data, columns)

# 显示数据
df.show()

# 停止 Spark 会话
spark.stop()
```

## 🔧 常用命令

### 服务管理
```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f [service_name]

# 进入容器
docker exec -it spark-hadoop-hive-master bash
```

### 集群监控
```bash
# 查看 Spark 集群状态
curl http://localhost:8080/json/

# 查看 HDFS 状态
hdfs dfsadmin -report

# 查看 YARN 应用
yarn application -list
```

### 数据管理
```bash
# 备份 HDFS 数据
hdfs dfs -cp /user/data /backup/data

# 清理临时文件
hdfs dfs -rm -r /tmp/*

# 检查 HDFS 健康状态
hdfs fsck /
```

## 🐛 故障排除

### 常见问题

#### 1. 容器启动失败
```bash
# 检查容器状态
docker compose ps

# 查看详细日志
docker compose logs [service-name]

# 检查资源使用情况
docker stats

# 重新构建镜像
docker compose build --no-cache
```

#### 2. 端口冲突
如果遇到端口被占用的错误，可以修改 `docker-compose.yml` 中的端口映射：
```yaml
ports:
  - '8081:8080'  # 将主机端口改为 8081
```

#### 3. 内存不足
确保 Docker 分配了足够的内存资源（建议至少 8GB）：
- Docker Desktop: Settings → Resources → Memory

#### 4. Spark 任务失败
- 检查 Spark Master 是否正常运行
- 确认 Worker 节点已连接到 Master
- 查看应用日志：http://localhost:4040

#### 5. HDFS 连接问题
```bash
# 检查 NameNode 状态
hdfs dfsadmin -report

# 重新格式化 NameNode（谨慎使用）
hdfs namenode -format
```

#### 6. Hive 连接失败
```bash
# 检查 MySQL 连接
docker exec -it hive-mysql mysql -u hive -phive123 -e "SHOW DATABASES;"

# 重新初始化 Hive 元数据
docker exec -it spark-hadoop-hive-master schematool -dbType mysql -initSchema
```

#### 7. JupyterLab 无法访问
```bash
# 检查 JupyterLab 是否正在运行
docker exec -it spark-hadoop-hive-master ps aux | grep jupyter

# 重新启动 JupyterLab
docker exec -it spark-hadoop-hive-master /opt/miniconda3/bin/jupyter lab --allow-root --ip=0.0.0.0 --port=8888 --no-browser
```

### 清理和重置

#### 完全重置环境
```bash
# 停止所有服务
docker compose down

# 删除所有容器和卷
docker compose down -v

# 删除镜像（可选）
docker rmi spark-hadoop-hive:latest

# 重新构建和启动
docker compose build --no-cache
docker compose up -d
```

#### 清理 HDFS 数据
```bash
# 进入 master 容器
docker exec -it spark-hadoop-hive-master bash

# 格式化 NameNode（谨慎操作，会删除所有 HDFS 数据）
hdfs namenode -format
```

### 性能优化

#### 内存配置
编辑 `docker-compose.yml` 调整内存分配：
```yaml
environment:
  - SPARK_WORKER_MEMORY=2G  # 增加 Worker 内存
  - SPARK_WORKER_CORES=2    # 增加 CPU 核心数
```

#### 存储优化
```bash
# 设置 HDFS 副本数
hdfs dfsadmin -setDefaultReplication 2

# 清理 HDFS 垃圾文件
hdfs dfs -expunge
```
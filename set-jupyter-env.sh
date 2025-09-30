#!/bin/bash

# 激活 conda base 环境（Python 3.9，兼容 Spark 3.3.0）
source /opt/miniconda3/bin/activate base

# 设置 Hadoop 环境变量
export HADOOP_HOME="/opt/hadoop"
export HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"
export HADOOP_LOG_DIR="/var/log/hadoop"

# 设置 Hive 环境变量
export HIVE_HOME="/opt/hive"
export HIVE_CONF_DIR="$HIVE_HOME/conf"

# 设置 Spark 环境变量
export SPARK_HOME="/opt/bitnami/spark"

# 设置 Java 环境变量
export JAVA_HOME="/opt/bitnami/java"

# 更新 PATH
export PATH="$HADOOP_HOME/sbin:$HADOOP_HOME/bin:$HIVE_HOME/bin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$JAVA_HOME/bin:$PATH"

# 设置 Python 路径以支持 PySpark
export PYSPARK_PYTHON="$(which python)"
export PYSPARK_DRIVER_PYTHON="$(which python)"

# 启动传入的命令
exec "$@"

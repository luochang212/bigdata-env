#!/bin/bash

# Python版本的Spark Word Count提交脚本
# 使用方法: ./submit_python_wordcount.sh [input_file]

set -e  # 遇到错误时退出

# 默认输入文件
INPUT_FILE=${1:-"/words.txt"}

# Spark配置参数
MASTER="yarn"
DEPLOY_MODE="cluster"
APP_NAME="Python Word Count"
EXECUTOR_MEMORY="1g"
DRIVER_MEMORY="512m"
EXECUTOR_CORES="2"
NUM_EXECUTORS="2"

# Python脚本路径
PYTHON_SCRIPT="./word_count.py"

echo "========================================="
echo "提交Python Spark Word Count任务"
echo "========================================="
echo "输入文件: $INPUT_FILE"
echo "Master: $MASTER"
echo "部署模式: $DEPLOY_MODE"
echo "应用名称: $APP_NAME"
echo "Executor内存: $EXECUTOR_MEMORY"
echo "Driver内存: $DRIVER_MEMORY"
echo "========================================="

# 检查输入文件是否存在于HDFS中
echo "检查HDFS中的输入文件..."
if ! hdfs dfs -test -e "$INPUT_FILE"; then
    echo "错误: 输入文件 $INPUT_FILE 在HDFS中不存在"
    echo "请先将文件上传到HDFS:"
    echo "hdfs dfs -put /path/to/local/file $INPUT_FILE"
    exit 1
fi

echo "输入文件存在，开始提交任务..."

# 提交Spark任务
spark-submit \
    --master "$MASTER" \
    --deploy-mode "$DEPLOY_MODE" \
    --name "$APP_NAME" \
    --executor-memory "$EXECUTOR_MEMORY" \
    --driver-memory "$DRIVER_MEMORY" \
    --executor-cores "$EXECUTOR_CORES" \
    --num-executors "$NUM_EXECUTORS" \
    --conf spark.sql.adaptive.enabled=true \
    --conf spark.sql.adaptive.coalescePartitions.enabled=true \
    "$PYTHON_SCRIPT" \
    "$INPUT_FILE"

echo "========================================="
echo "任务提交完成！"
echo "========================================="
echo "查看应用状态: yarn application -list"
echo "查看应用日志: yarn logs -applicationId <application_id>"
echo "查看输出结果: hdfs dfs -cat /word-count-python/part-*"
echo "========================================="
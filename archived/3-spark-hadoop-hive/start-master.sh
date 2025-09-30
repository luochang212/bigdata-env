#!/bin/bash

# 启动服务脚本 - 更健壮的版本
set -e  # 遇到错误立即退出

echo "=== 启动 Hadoop 服务 ==="
/opt/hadoop/sbin/start-dfs.sh
/opt/hadoop/sbin/start-yarn.sh

echo "=== 等待 Hadoop 服务就绪 ==="
# 动态等待 HDFS 就绪
for i in {1..30}; do
    if hdfs dfsadmin -report &>/dev/null; then
        echo "HDFS 服务已就绪"
        break
    fi
    echo "等待 HDFS 服务启动... ($i/30)"
    sleep 2
done

# 检查 YARN 是否就绪
for i in {1..15}; do
    if yarn node -list &>/dev/null; then
        echo "YARN 服务已就绪"
        break
    fi
    echo "等待 YARN 服务启动... ($i/15)"
    sleep 2
done

echo "=== 初始化 Hive Metastore Schema ==="
schematool -dbType mysql -initSchema -ifNotExists

echo "=== 创建日志目录 ==="
mkdir -p /var/log

echo "=== 启动 Hive Metastore 服务 ==="
hive --service metastore > /var/log/hive-metastore.log 2>&1 &
METASTORE_PID=$!

# 等待并检查 Metastore 是否成功启动
sleep 10
if kill -0 $METASTORE_PID 2>/dev/null; then
    echo "Hive Metastore 启动成功 (PID: $METASTORE_PID)"
else
    echo "Hive Metastore 启动失败，查看日志："
    cat /var/log/hive-metastore.log
    exit 1
fi

echo "=== 启动 HiveServer2 ==="
hiveserver2 > /var/log/hiveserver2.log 2>&1 &
HIVESERVER2_PID=$!

# 等待并检查 HiveServer2 是否成功启动
sleep 10
if kill -0 $HIVESERVER2_PID 2>/dev/null; then
    echo "HiveServer2 启动成功 (PID: $HIVESERVER2_PID)"
else
    echo "HiveServer2 启动失败，查看日志："
    cat /var/log/hiveserver2.log
    exit 1
fi

echo "=== 所有服务启动完成 ==="
echo "Metastore PID: $METASTORE_PID"
echo "HiveServer2 PID: $HIVESERVER2_PID"

echo "=== 启动 Spark Master ==="
exec /opt/bitnami/scripts/spark/run.sh
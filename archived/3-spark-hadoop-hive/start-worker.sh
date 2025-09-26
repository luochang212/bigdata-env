#!/bin/bash

# Worker 节点启动脚本 - 稳健版本
set -e  # 遇到错误立即退出

echo "=== Worker 节点启动开始 ==="

# 等待 master 节点就绪
echo "=== 等待 Master 节点就绪 ==="
MASTER_HOST=${SPARK_MASTER_URL#spark://}
MASTER_HOST=${MASTER_HOST%:*}
MASTER_PORT=${SPARK_MASTER_URL##*:}

for i in {1..60}; do
    if timeout 2 bash -c "</dev/tcp/$MASTER_HOST/$MASTER_PORT" 2>/dev/null; then
        echo "Master 节点已就绪 ($MASTER_HOST:$MASTER_PORT)"
        break
    fi
    echo "等待 Master 节点启动... ($i/60)"
    sleep 2
done

# 验证 Master 是否真正可用
if ! timeout 2 bash -c "</dev/tcp/$MASTER_HOST/$MASTER_PORT" 2>/dev/null; then
    echo "错误: Master 节点不可达 ($MASTER_HOST:$MASTER_PORT)"
    exit 1
fi

echo "=== 启动 SSH 服务 ==="
/etc/init.d/ssh start > /dev/null 2>&1 &

# 等待 SSH 服务启动
for i in {1..10}; do
    if pgrep sshd > /dev/null; then
        echo "SSH 服务已启动"
        break
    fi
    echo "等待 SSH 服务启动... ($i/10)"
    sleep 1
done

echo "=== 等待 HDFS NameNode 就绪 ==="
# 等待 HDFS NameNode 可用
for i in {1..30}; do
    if hdfs dfsadmin -report &>/dev/null; then
        echo "HDFS NameNode 已就绪"
        break
    fi
    echo "等待 HDFS NameNode 启动... ($i/30)"
    sleep 2
done

echo "=== 启动 HDFS DataNode ==="
# 清理可能存在的旧 DataNode 进程和 PID 文件
if [ -f "/tmp/hadoop-root-datanode.pid" ]; then
    echo "清理旧的 DataNode PID 文件"
    rm -f /tmp/hadoop-root-datanode.pid
fi

# 停止可能运行的 DataNode 进程
pkill -f "org.apache.hadoop.hdfs.server.datanode.DataNode" 2>/dev/null || true
sleep 2

hdfs --daemon start datanode

# 验证 DataNode 是否成功启动
sleep 5
for i in {1..15}; do
    if hdfs dfsadmin -report | grep -q "Live datanodes"; then
        echo "HDFS DataNode 启动成功"
        break
    fi
    echo "等待 DataNode 注册到 NameNode... ($i/15)"
    sleep 2
done

# 检查 DataNode 进程是否运行
if ! pgrep -f "org.apache.hadoop.hdfs.server.datanode.DataNode" > /dev/null; then
    echo "警告: DataNode 进程可能未正常启动"
    # 显示 DataNode 日志的最后几行
    if [ -f "$HADOOP_HOME/logs/hadoop-*-datanode-*.log" ]; then
        echo "DataNode 日志:"
        tail -20 $HADOOP_HOME/logs/hadoop-*-datanode-*.log
    fi
fi

echo "=== 启动 YARN NodeManager ==="
# 清理可能存在的旧 NodeManager 进程和 PID 文件
if [ -f "/tmp/hadoop-root-nodemanager.pid" ]; then
    echo "清理旧的 NodeManager PID 文件"
    rm -f /tmp/hadoop-root-nodemanager.pid
fi

# 停止可能运行的 NodeManager 进程
pkill -f "org.apache.hadoop.yarn.server.nodemanager.NodeManager" 2>/dev/null || true
sleep 2

yarn --daemon start nodemanager

# 验证 NodeManager 是否成功启动
sleep 5
for i in {1..15}; do
    if yarn node -list 2>/dev/null | grep -q "$(hostname)"; then
        echo "YARN NodeManager 启动成功"
        break
    fi
    echo "等待 NodeManager 注册到 ResourceManager... ($i/15)"
    sleep 2
done

# 检查 NodeManager 进程是否运行
if ! pgrep -f "org.apache.hadoop.yarn.server.nodemanager.NodeManager" > /dev/null; then
    echo "警告: NodeManager 进程可能未正常启动"
    # 显示 NodeManager 日志的最后几行
    if [ -f "$HADOOP_HOME/logs/yarn-*-nodemanager-*.log" ]; then
        echo "NodeManager 日志:"
        tail -20 $HADOOP_HOME/logs/yarn-*-nodemanager-*.log
    fi
fi

echo "=== 所有 Hadoop 服务启动完成 ==="
echo "DataNode 状态: $(pgrep -f DataNode > /dev/null && echo '运行中' || echo '未运行')"
echo "NodeManager 状态: $(pgrep -f NodeManager > /dev/null && echo '运行中' || echo '未运行')"

echo "=== 启动 Spark Worker ==="
echo "连接到 Master: $SPARK_MASTER_URL"
echo "Worker 内存: ${SPARK_WORKER_MEMORY:-1G}"
echo "Worker 核心数: ${SPARK_WORKER_CORES:-1}"

# 启动 Spark Worker
exec /opt/bitnami/scripts/spark/run.sh
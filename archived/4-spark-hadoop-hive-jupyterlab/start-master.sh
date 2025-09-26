#!/bin/bash

# 启动服务脚本 - 更健壮的版本
set -e  # 遇到错误立即退出

# 默认不安装 miniconda
INSTALL_MINICONDA=false

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --install-miniconda)
            INSTALL_MINICONDA=true
            shift
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  --install-miniconda    安装 Miniconda"
            echo "  -h, --help            显示此帮助信息"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 -h 或 --help 查看帮助信息"
            exit 1
            ;;
    esac
done

# Miniconda 安装函数
install_miniconda() {
    echo "=== 安装 Miniconda ==="

    # 检查是否已经安装
    if command -v conda &> /dev/null; then
        echo "Miniconda 已经安装，跳过安装步骤"
        return 0
    fi

    # 下载并安装 Miniconda
    echo "正在下载 Miniconda..."
    curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh

    echo "正在安装 Miniconda..."
    bash /tmp/miniconda.sh -b -u -p /opt/miniconda

    # 清理安装文件
    rm -f /tmp/miniconda.sh

    # 激活 miniconda 环境
    source /opt/miniconda/bin/activate

    # 初始化 conda
    /opt/miniconda/bin/conda init bash

    # 配置 conda 使用 conda-forge 仓库以避免服务条款问题
    echo "正在配置 Conda 仓库..."
    /opt/miniconda/bin/conda config --add channels conda-forge
    /opt/miniconda/bin/conda config --set channel_priority strict
    
    # 或者接受服务条款（如果需要使用默认仓库）
    echo "正在接受 Conda 服务条款..."
    /opt/miniconda/bin/conda config --set channel_priority flexible
    echo 'y' | /opt/miniconda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
    echo 'y' | /opt/miniconda/bin/conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

    # 安装 Jupyter Lab
    echo "正在安装 Jupyter Lab..."
    /opt/miniconda/bin/conda install -y -c conda-forge jupyterlab

    echo "Jupyter Lab 安装和配置完成"
    echo "Miniconda 安装完成"
}

# 启动 jupyterlab
start_jupyterlab() {
    echo "=== 启动 JupyterLab ==="

    # 创建持久化的环境变量配置文件
    mkdir -p /opt/miniconda/etc/conda/activate.d
    cat > /opt/miniconda/etc/conda/activate.d/bigdata-env.sh << 'EOF'
#!/bin/bash
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
export PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-*-src.zip:$PYTHONPATH"
export PYSPARK_PYTHON="/opt/miniconda/bin/python"
export PYSPARK_DRIVER_PYTHON="/opt/miniconda/bin/python"
EOF

    # 创建 deactivate 脚本（可选）
    mkdir -p /opt/miniconda/etc/conda/deactivate.d
    cat > /opt/miniconda/etc/conda/deactivate.d/bigdata-env.sh << 'EOF'
#!/bin/bash
# 清理环境变量（可选）
unset HADOOP_HOME HADOOP_CONF_DIR HADOOP_LOG_DIR
unset HIVE_HOME HIVE_CONF_DIR
unset SPARK_HOME
# 注意：不要 unset JAVA_HOME，因为其他程序可能需要它
EOF

    # 确保脚本可执行
    chmod +x /opt/miniconda/etc/conda/activate.d/bigdata-env.sh
    chmod +x /opt/miniconda/etc/conda/deactivate.d/bigdata-env.sh

    # 创建启动脚本，确保环境变量在 JupyterLab 中可用
    cat > /tmp/jupyter_env.sh << 'EOF'
#!/bin/bash
# 激活 conda base 环境
source /opt/miniconda/bin/activate base

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
export PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-*-src.zip:$PYTHONPATH"
export PYSPARK_PYTHON="/opt/miniconda/bin/python"
export PYSPARK_DRIVER_PYTHON="/opt/miniconda/bin/python"

# 启动传入的命令
exec "$@"
EOF
    
    chmod +x /tmp/jupyter_env.sh

    # 启动 JupyterLab
    nohup /tmp/jupyter_env.sh /opt/miniconda/bin/jupyter lab \
    --notebook-dir=/opt/share \
    --ip=0.0.0.0 \
    --port=8888 \
    --no-browser \
    --allow-root > /var/log/jupyterlab.log 2>&1 &
    JUPYTER_PID=$!
    
    # 等待 JupyterLab 启动
    sleep 5
    if kill -0 $JUPYTER_PID 2>/dev/null; then
        echo "JupyterLab 启动成功 (PID: $JUPYTER_PID)"
        echo "JupyterLab 访问地址: http://localhost:8888"
        echo "查看 JupyterLab token: /opt/miniconda/bin/jupyter lab list"
        echo ""
        echo "环境变量已配置，在 JupyterLab 终端中应该可以使用以下命令："
        echo "  - hive (启动 Hive CLI)"
        echo "  - pyspark (启动 PySpark)"
        echo "  - spark-shell (启动 Spark Scala Shell)"
        echo "  - hdfs (Hadoop 分布式文件系统命令)"
        echo ""
        echo "如果命令仍然不可用，请在终端中运行："
        echo "  source /opt/miniconda/etc/conda/activate.d/bigdata-env.sh"
    else
        echo "JupyterLab 启动失败，查看日志："
        cat /var/log/jupyterlab.log
    fi
}


echo "=== 启动 Hadoop 服务 ==="
if ! /opt/hadoop/sbin/start-dfs.sh; then
    echo "错误: HDFS 启动失败"
    exit 1
fi

if ! /opt/hadoop/sbin/start-yarn.sh; then
    echo "错误: YARN 启动失败"
    exit 1
fi

echo "=== 等待 Hadoop 服务就绪 ==="
# 动态等待 HDFS 就绪
HDFS_READY=false
for i in {1..30}; do
    if hdfs dfsadmin -report &>/dev/null; then
        echo "HDFS 服务已就绪"
        HDFS_READY=true
        break
    fi
    echo "等待 HDFS 服务启动... ($i/30)"
    sleep 2
done

if [ "$HDFS_READY" = false ]; then
    echo "错误: HDFS 服务启动超时，请检查配置和日志"
    exit 1
fi

# 检查 YARN 是否就绪
YARN_READY=false
for i in {1..15}; do
    if yarn node -list &>/dev/null; then
        echo "YARN 服务已就绪"
        YARN_READY=true
        break
    fi
    echo "等待 YARN 服务启动... ($i/15)"
    sleep 2
done

if [ "$YARN_READY" = false ]; then
    echo "错误: YARN 服务启动超时，请检查配置和日志"
    exit 1
fi

echo "=== 初始化 Hive Metastore Schema ==="
if ! schematool -dbType mysql -initSchema -ifNotExists; then
    echo "错误: Hive Metastore Schema 初始化失败"
    exit 1
fi

echo "=== 创建日志目录 ==="
if ! mkdir -p /var/log; then
    echo "错误: 无法创建日志目录 /var/log"
    exit 1
fi

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

# 如果指定了安装 miniconda，则执行安装
if [ "$INSTALL_MINICONDA" = true ]; then
    install_miniconda
    start_jupyterlab
fi

echo "=== 启动 Spark Master ==="
exec /opt/bitnami/scripts/spark/run.sh
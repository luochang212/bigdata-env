#!/bin/bash

# 启动服务脚本 - 更健壮的版本
set -e  # 遇到错误立即退出

# 默认启动 JupyterLab
START_JUPYTERLAB=true

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-jupyterlab)
            START_JUPYTERLAB=false
            shift
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo "选项:"
            echo "  --no-jupyterlab       不启动 JupyterLab"
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

# 启动 jupyterlab
start_jupyterlab() {
    echo "=== 启动 JupyterLab ==="

    # 检查 Miniconda 是否已安装
    if ! command -v conda &> /dev/null; then
        echo "错误: Miniconda 未安装，无法启动 JupyterLab"
        return 1
    fi

    # 确认 set-conda-env.sh 存在
    if [ ! -f /opt/set-conda-env.sh ]; then
        echo "错误: 未找到 /opt/set-conda-env.sh"
        return 1
    fi

    # 创建持久化的环境变量配置文件
    mkdir -p /opt/miniconda3/etc/conda/activate.d
    cp /opt/set-conda-env.sh /opt/miniconda3/etc/conda/activate.d/bigdata-env.sh
    chmod +x /opt/miniconda3/etc/conda/activate.d/bigdata-env.sh

    # 创建启动脚本，确保环境变量在 JupyterLab 中可用
    cp /opt/set-jupyter-env.sh /tmp/jupyter_env.sh
    chmod +x /tmp/jupyter_env.sh

    # 创建 JupyterLab 配置文件，设置默认 shell 为 bash
    # 获取当前用户的 home 目录
    JUPYTER_CONFIG_DIR="${HOME:-/root}/.jupyter"
    mkdir -p "$JUPYTER_CONFIG_DIR"
    cp /opt/jupyter_server_config.py "$JUPYTER_CONFIG_DIR/"

    echo "JupyterLab 配置文件已创建: $JUPYTER_CONFIG_DIR/jupyter_server_config.py"

    # 启动 JupyterLab
    nohup /tmp/jupyter_env.sh /opt/miniconda3/bin/jupyter lab \
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
    else
        echo "JupyterLab 启动失败，查看日志："
        cat /var/log/jupyterlab.log
        return 1
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

# 如果指定了启动 JupyterLab，则执行启动
if [ "$START_JUPYTERLAB" = true ]; then
    start_jupyterlab
fi

echo "=== 启动 Spark Master ==="
exec /opt/bitnami/scripts/spark/run.sh
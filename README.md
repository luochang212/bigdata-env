
# bigdata-env

基于 Docker Compose 部署大数据开发环境，集成了 Spark、Hadoop、Hive 和 JupyterLab。

## 📋 环境要求

### 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 至少 8GB 内存
- 至少 20GB 可用磁盘空间

### 平台支持

- [x] macOS (Intel/Apple Silicon)
- [x] Linux (x86_64)
- [x] Windows (WSL2)

## 🏗️ 架构说明

### 服务组件
```
┌───────────────────┐   ┌──────────────────┐   ┌──────────────────┐
│   Spark Master    │   │  Spark Worker 1  │   │  Spark Worker 2  │
│   (Master Node)   │   │  (Worker Node)   │   │  (Worker Node)   │
│                   │   │                  │   │                  │
│ • Spark Master    │   │ • Spark Worker   │   │ • Spark Worker   │
│ • Hadoop NameNode │   │ • Hadoop DataNode│   │ • Hadoop DataNode│
│ • YARN ResourceMgr│   │ • YARN NodeMgr   │   │ • YARN NodeMgr   │
│ • Hive Metastore  │   │                  │   │                  │
│ • JupyterLab      │   │                  │   │                  │
└───────────────────┘   └──────────────────┘   └──────────────────┘
          │                       │                       │
          └───────────────────────┼───────────────────────┘
                                  │
                        ┌────────────────────┐
                        │       MySQL        │
                        │ (Metadata Storage) │
                        └────────────────────┘
```

### 端口映射

| 服务 | 端口 | 说明 |
|------|------|------|
| Spark Master Web UI | [8080](http://localhost:8080) | Spark 集群管理界面 |
| Hadoop NameNode | [9870](http://localhost:9870) | HDFS 管理界面 |
| YARN ResourceManager | [8088](http://localhost:8088) | YARN 资源管理界面 |
| JupyterLab | [8888](http://localhost:8888) | 交互式开发环境 |
| Hive Metastore | 9083 | Hive 元数据服务 |
| HiveServer2 | 10000 | Hive JDBC/ODBC 服务 |
| Hadoop History Server | 19888 | MapReduce 历史服务器 |
| YARN NodeManager | 8042 | YARN 节点管理界面 |
| Spark Application UI | 4040 | Spark 应用监控界面 |
| MySQL | 3306 | 数据库服务 |

## 🛠️ 本地安装

> [!WARNING]
>
> 1. `hive-site.xml` 与 `docker-compose.yml` 可能包含明文密码，请勿将包含密码的文件推送至公网仓库
> 2. 本项目密码仅作示例之用，请勿在生产环境中使用

### 1. 克隆项目

```bash
git clone https://github.com/luochang212/bigdata-env.git
cd bigdata-env
```

### 2. 配置 `.env` 文件

复制 `.env` 文件模版，创建你的 `.env` 文件：

```bash
cp .env.example .env
```

编辑 `.env` 文件，更新密码（可选）：

```bash
MYSQL_ROOT_PASSWORD=[your-mysql-root-password]
MYSQL_PASSWORD=[your-mysql-password]
HIVE_DB_PASSWORD=[your-hive-db-password]
```

### 3. 构建和启动服务

```bash
# 对于 Windows 用户，需要转换为 Unix 换行符
# Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# .\convert.ps1

# 构建镜像（首次运行或更新 Dockerfile 后）
docker compose build --no-cache

# 启动所有服务
docker compose up -d

# 停止并删除所有服务
docker compose down -v --rmi local
```

### 4. 验证服务状态

```bash
# 检查容器状态
docker compose ps

# 查看服务日志
docker compose logs -f
```

### 5. 验证 Hive 连接

```bash
docker exec -it spark-hadoop-hive-master hive -e 'SHOW DATABASES;'
```

### 6. 获取 JupyterLab Token

JupyterLab 地址：[http://localhost:8888/lab](http://localhost:8888/lab)

进入 master 节点容器，执行以下命令获取访问令牌：

```bash
docker exec -it spark-hadoop-hive-master /opt/miniconda3/bin/jupyter lab list
```

进入 JupyterLab 后，可以直接使用 Hive 和 Spark：

```bash
# 验证 Hive 服务可用
hive -e 'SHOW DATABASES;'

# 确认 Spark 服务可用
pyspark

# 也可启动 Spark 交互式命令行
spark-shell
```

<!-- ## 📁 项目结构

```
bigdata-env/
├── .env.example              # 环境变量模板
├── .gitignore               # Git 忽略文件
├── Dockerfile               # 镜像构建文件
├── README.md                # 项目说明文档
├── docker-compose.yml       # 服务编排文件
├── docs.md                  # 详细文档
├── config/                  # 配置文件目录
│   ├── core-site.xml       # Hadoop 核心配置
│   ├── hadoop-env.sh       # Hadoop 环境变量
│   ├── hdfs-site.xml       # HDFS 配置
│   ├── hive-site.xml       # Hive 配置
│   ├── mapred-site.xml     # MapReduce 配置
│   ├── ssh_config          # SSH 配置
│   ├── workers             # Worker 节点列表
│   └── yarn-site.xml       # YARN 配置
├── share/                   # 共享数据目录
│   └── .gitkeep
├── start-master.sh          # 主节点启动脚本
├── start-worker.sh          # 工作节点启动脚本
└── archived/                # 历史版本存档
    ├── 1-spark/
    ├── 2-spark-hadoop/
    ├── 3-spark-hadoop-hive/
    └── 4-spark-hadoop-hive-jupyterlab/
``` -->

## 📚 参考资料

- [使用 Docker 快速部署 Spark + Hadoop 大数据集群](https://s1mple.cc/2021/10/12/%E4%BD%BF%E7%94%A8-Docker-%E5%BF%AB%E9%80%9F%E9%83%A8%E7%BD%B2-Spark-Hadoop-%E5%A4%A7%E6%95%B0%E6%8D%AE%E9%9B%86%E7%BE%A4/)

## 📝 Vibe Coding

声明：本项目使用 [Trae AI](https://trae.ai) 辅助开发。

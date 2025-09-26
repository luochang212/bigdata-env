

[使用 Docker 快速部署 Spark + Hadoop 大数据集群](https://s1mple.cc/2021/10/12/%E4%BD%BF%E7%94%A8-Docker-%E5%BF%AB%E9%80%9F%E9%83%A8%E7%BD%B2-Spark-Hadoop-%E5%A4%A7%E6%95%B0%E6%8D%AE%E9%9B%86%E7%BE%A4/)

jupyterlab

hive spark自带？

shellcheck ./start-worker.sh

bash -n ./start-worker.sh

docker compose build --no-cache

docker compose up -d

docker exec -it spark-hadoop-hive-master hive -e 'SHOW DATABASES;'

http://localhost:8888/lab

docker exec -it spark-hadoop-hive-master /opt/miniconda/bin/jupyter lab list

docker build --dry-run -f Dockerfile . 
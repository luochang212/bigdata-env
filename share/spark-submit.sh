## USAGE: 
## 1. 检查 Spark 版本
#   spark-submit --version
## 2. 将数据上传到 HDFS
#   hdfs dfs -mkdir -p /user/root
#   hdfs dfs -put -f /opt/share/spark_data/PRSA_data_2010.1.1-2014.12.31.csv /user/root/
#   hdfs dfs -ls /user/root/
## 3. 提交 Spark 任务
#   bash submit.sh
## 4. 检查结果
#   hdfs dfs -ls /user/root/season_avg
#   hdfs dfs -cat /user/root/season_avg/part-00000-* | head -n 10

## 模式选择：
#   --master yarn
#   --deploy-mode [client|cluster]

source $(conda info --base)/etc/profile.d/conda.sh
conda activate base

PY_BIN=$(which python)

# 以 Yarn 集群模式运行
spark-submit \
  --master yarn \
  --deploy-mode cluster \
  --name data-analysis-task \
    --conf spark.executor.memory=4g \
    --conf spark.dynamicAllocation.minExecutors=800 \
    --conf spark.pyspark.driver.python=$PY_BIN \
    --conf spark.pyspark.python=$PY_BIN \
    --executor-cores 2 \
    --num-executors 2 \
    --executor-memory 2g \
    --driver-memory 1g \
    /opt/share/spark.py

## 以 Standalone 模式运行
# spark-submit \
#   --master spark://master:7077 \
#   /opt/share/spark.py

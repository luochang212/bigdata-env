一主二从

yarn 模式

$ pyspark
>>> sc._gateway.jvm.org.apache.hadoop.util.VersionInfo.getVersion()
'3.3.2'

https://github.com/s1mplecc/spark-hadoop-docker

https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/ClusterSetup.html

docker build -t spark-hadoop .

docker compose build --no-cache

docker compose up -d

# 进入主节点容器
docker exec -it spark-hadoop-master bash

# 启动 PySpark 交互式环境
pyspark

# 或启动 Spark Shell (Scala)
spark-shell

hadoop fs -put /opt/share/words.txt /

hadoop fs -ls /

HDFS Web UI

http://localhost:9870

http://localhost:9870/explorer.html#/

可以通过 Spark 访问 HDFS 了，访问 URI 为 hdfs://master:9000


$ pyspark
>>> lines = sc.textFile('hdfs://master:9000/words.txt')
>>> lines.collect()
>>> words = lines.flatMap(lambda x: x.split(' '))
>>> words.saveAsTextFile('hdfs://master:9000/split-words')
>>> exit()

hdfs dfs -ls /

hdfs dfs -ls /split-words

hdfs dfs -cat /split-words/part-00000


$ pyspark
>>> lines = sc.textFile('hdfs://master:9000/words.txt')
>>> words = lines.flatMap(lambda x: x.split(' '))
>>> word_counts = words.map(lambda word: (word, 1)).reduceByKey(lambda a, b: a + b)
>>> word_counts.collect()
>>> word_counts.saveAsTextFile('hdfs://master:9000/word-count')
>>> exit()

hdfs dfs -ls /

hdfs dfs -ls /word-count

# 查看单个分区的结果
hdfs dfs -cat /word-count/part-00000
hdfs dfs -cat /word-count/part-00001

# 查看完整的word count结果（合并所有分区）
hdfs dfs -cat /word-count/part-*




$ spark-submit --master yarn \
--deploy-mode cluster \
--name "Word Count" \
--executor-memory 1g \
--class org.apache.spark.examples.JavaWordCount \
/opt/bitnami/spark/examples/jars/spark-examples_2.12-3.1.2.jar /words.txt



ls -la /opt/share/word_count.py

python3 -m py_compile /opt/share/word_count.py 

yarn node -list

chmod +x /opt/share/word_count.py 

spark-submit --master yarn --deploy-mode client --executor-memory 512m --driver-memory 1g --num-executors 1 --executor-cores 1 word_count.py /words.txt

spark-submit --master yarn --deploy-mode client --executor-memory 512m --driver-memory 1g --num-executors 1 --executor-cores 1 --conf spark.pyspark.python=/opt/bitnami/python/bin/python3 word_count.py /words.txt 

# Spark SQL
spark-sql --help

spark-sql

spark-sql -e "SELECT 'Hello Spark SQL' as greeting, current_timestamp() as current_time" 


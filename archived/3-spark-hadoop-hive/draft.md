docker compose build --no-cache

docker compose up -d



docker compose logs -f

docker exec -it spark-hadoop-hive-master bash

hive

hive -e 'SHOW DATABASES;'

docker exec -it spark-hadoop-hive-master hive -e 'SHOW DATABASES;'



echo "=== 服务端口映射 ===" && docker port spark-hadoop-hive-master

echo "=== 测试 Web 界面可访问性 ===" && curl -s -o /dev/null -w "Spark Master UI (8080): %{http_code}\n" http://localhost:8080 && curl -s -o /dev/null -w "HDFS NameNode UI (9870): %{http_code}\n" http://localhost:9870 && curl -s -o /dev/null -w "YARN ResourceManager UI (8088): %{http_code}\n" http://localhost:8088 

你的 Spark-Hadoop-Hive 集群现在完全正常运行，以下是可访问的服务：

- Spark Master UI : http://localhost:8080
- HDFS NameNode UI : http://localhost:9870
- YARN ResourceManager UI : http://localhost:8088
- Hive Metastore : localhost:9083
- HiveServer2 : localhost:10000
- Spark Application UI : http://localhost:4040 (当有应用运行时)
- YARN NodeManager UI : http://localhost:8042
- MapReduce JobHistory : http://localhost:19888


docker exec spark-hadoop-hive-master beeline -u "jdbc:hive2://localhost:10000" -e "SHOW DATABASES;" 


    command: >
      bash -c "/opt/hadoop/sbin/start-dfs.sh && 
               /opt/hadoop/sbin/start-yarn.sh &&
               sleep 35 &&
               schematool -dbType mysql -initSchema -ifNotExists &&
               nohup hive --service metastore > /var/log/hive-metastore.log 2>&1 &
               sleep 5 &&
               nohup hiveserver2 > /var/log/hiveserver2.log 2>&1 &
               /opt/bitnami/scripts/spark/run.sh"


    command: >
      bash -c "sleep 60 &&
               /etc/init.d/ssh start > /dev/null &
               sleep 5 &&
               hdfs --daemon start datanode &&
               sleep 10 &&
               /opt/bitnami/scripts/spark/run.sh"
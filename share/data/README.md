# 数据准备

## 一、将 CSV 文件下载到当前目录

`PRSA_data_2010.1.1-2014.12.31.csv`: [Beijing PM2.5](https://archive.ics.uci.edu/dataset/381/beijing+pm2+5+data)

## 二、上传数据到 HDFS

```bash
hdfs dfs -mkdir -p /user/root

hdfs dfs -put -f /opt/share/data/PRSA_data_2010.1.1-2014.12.31.csv /user/root/

hdfs dfs -ls /user/root/
```

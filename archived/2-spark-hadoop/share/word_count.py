#!/opt/bitnami/python/bin/python3
"""
Python版本的Spark Word Count程序
统计文本文件中每个单词的出现次数
USAGE: python word_count.py hdfs://master:9000/words.txt
"""

from pyspark.sql import SparkSession
import sys
import re

def main():
    # 检查命令行参数
    if len(sys.argv) != 2:
        print("Usage: word_count.py <input_file>", file=sys.stderr)
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    # 创建SparkSession
    spark = SparkSession.builder \
        .appName("Python Word Count") \
        .getOrCreate()
    
    # 获取SparkContext
    sc = spark.sparkContext
    
    try:
        # 读取输入文件
        text_file = sc.textFile(input_file)
        
        # 执行word count操作
        word_counts = text_file \
            .flatMap(lambda line: re.findall(r'\b\w+\b', line.lower())) \
            .map(lambda word: (word, 1)) \
            .reduceByKey(lambda a, b: a + b) \
            .sortBy(lambda x: x[1], ascending=False)
        
        # 收集结果并打印
        results = word_counts.collect()
        
        print("Word Count Results:")
        print("==================")
        for word, count in results:
            print(f"{word}: {count}")
        
        print(f"\nTotal unique words: {len(results)}")
        
        # 保存结果到HDFS（如果需要）
        output_path = "/word-count-python"
        word_counts.saveAsTextFile(output_path)
        print(f"\nResults saved to HDFS: {output_path}")
        
    except Exception as e:
        print(f"Error processing file: {e}", file=sys.stderr)
        sys.exit(1)
    
    finally:
        # 停止SparkSession
        spark.stop()

if __name__ == "__main__":
    main()
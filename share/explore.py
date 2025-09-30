from pyspark.sql import SparkSession, functions as F


def create_spark():
    spark = (
        SparkSession.builder
        .master("yarn")  # yarn local[*]
        .appName("PRSA-Analysis")
        .getOrCreate()
    )
    return spark

def read_csv(csv_path):
    df = (
        spark.read.option("header", "true")
        .option("inferSchema", "true")
        .option("nullValue", "NA")
        .csv(csv_path)
    )
    return df

def calc_season_stats(df):
    df = df.withColumnRenamed("pm2.5", "pm25").withColumn(
        "date",
        F.to_date(
            F.format_string(
                "%04d-%02d-%02d", F.col("year"), F.col("month"), F.col("day")
            )
        ),
    ).withColumn(
        "timestamp",
        F.to_timestamp(
            F.format_string(
                "%04d-%02d-%02d %02d:00:00",
                F.col("year"),
                F.col("month"),
                F.col("day"),
                F.col("hour"),
            )
        ),
    )

    print("\n==== 季节维度 PM2.5 ====")
    season_expr = (
        F.when(F.col("month").isin(12, 1, 2), F.lit("Winter"))
        .when(F.col("month").isin(3, 4, 5), F.lit("Spring"))
        .when(F.col("month").isin(6, 7, 8), F.lit("Summer"))
        .otherwise(F.lit("Fall"))
    )
    season_avg = (
        df.withColumn("season", season_expr)
        .groupBy("season")
        .agg(F.mean("pm25").alias("avg_pm25"), F.count("*").alias("n"))
        .orderBy(F.desc("avg_pm25"))
    )
    return season_avg


if __name__ == '__main__':
    spark = create_spark()
    df = read_csv("/user/root/PRSA_data_2010.1.1-2014.12.31.csv")
    season_avg = calc_season_stats(df)
    # season_avg.show(truncate=False)
    output_dir = "/user/root/season_avg"
    season_avg.coalesce(1).write.mode("overwrite").option("header", "true").csv(output_dir)
    spark.stop()

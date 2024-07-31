import pyspark.sql.functions as F
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder.appName("stage_to_analytics").enableHiveSupport().getOrCreate()
)

df = spark.sql("select * from stage.gazettes")

df = df.withColumn(
    "scraping_delay_in_days",
    F.datediff(F.col("scraped_date"), F.col("publication_date")),
)

gazettes_metrics = df.groupBy("territory_id").agg(
    F.max("publication_date").alias("last_publication_date"),
    F.max("scraped_date").alias("last_scraped_date"),
    F.max("scraping_delay_in_days").alias("max_scraping_delay"),
    F.sum("total_gazettes").alias("total_gazettes_published"),
    F.sum(F.when(F.col("is_extra_edition") == True, 1).otherwise(0)).alias(
        "extra_edition_count"
    ),
    F.sum(F.when(F.col("is_extra_edition") == False, 1).otherwise(0)).alias(
        "not_extra_edition_count"
    ),
)

DESTINATION_TABLE = "s3://political-datalake-analytics/querido-diario/gazettes_metrics/"
gazettes_metrics.write.mode("overwrite").parquet(DESTINATION_TABLE)

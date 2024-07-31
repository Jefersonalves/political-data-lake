import pyspark.sql.functions as F
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("raw_to_stage").enableHiveSupport().getOrCreate()

df = spark.sql("select * from raw.gazettes")
exploded = df.withColumn("data", F.explode("gazettes")).select(
    "total_gazettes", "scraped_date", "data.*"
)

exploded = exploded.withColumnRenamed("date", "publication_date")
exploded = exploded.drop("excerpts")

DESTINATION_TABLE = "s3://political-datalake-stage/querido-diario/gazettes/"
exploded.write.partitionBy("territory_id", "publication_date").mode(
    "overwrite"
).parquet(DESTINATION_TABLE)

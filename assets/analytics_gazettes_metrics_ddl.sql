CREATE EXTERNAL TABLE `gazettes_metrics`(
  `territory_id` string,
  `last_publication_date` string,
  `last_scraped_date` string,
  `max_scraping_delay` int,
  `total_gazettes_published` bigint,
  `extra_edition_count` bigint,
  `not_extra_edition_count` bigint)
ROW FORMAT SERDE
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION
  's3://political-datalake-analytics/querido-diario/gazettes_metrics/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0',
  'CrawlerSchemaSerializerVersion'='1.0',
  'UPDATED_BY_CRAWLER'='political_data_lake_analytics_crawler',
  'averageRecordSize'='144',
  'classification'='parquet',
  'compressionType'='none',
  'objectCount'='2',
  'recordCount'='3',
  'sizeKey'='2463',
  'typeOfData'='file')

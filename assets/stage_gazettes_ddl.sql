CREATE EXTERNAL TABLE `gazettes`(
  `total_gazettes` int,
  `scraped_date` string,
  `scraped_at` string,
  `url` string,
  `territory_name` string,
  `state_code` string,
  `edition` string,
  `is_extra_edition` boolean,
  `txt_url` string)
PARTITIONED BY (
  `territory_id` string,
  `publication_date` string)
ROW FORMAT SERDE
  'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
STORED AS INPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
LOCATION
  's3://political-datalake-stage/querido-diario/gazettes/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0',
  'CrawlerSchemaSerializerVersion'='1.0',
  'UPDATED_BY_CRAWLER'='political_data_lake_stage_crawler',
  'averageRecordSize'='530',
  'classification'='parquet',
  'compressionType'='none',
  'objectCount'='64',
  'partition_filtering.enabled'='true',
  'recordCount'='79',
  'sizeKey'='253696',
  'typeOfData'='file')

CREATE EXTERNAL TABLE `gazettes`(
  `total_gazettes` int COMMENT 'from deserializer',
  `gazettes` array<struct<territory_id:string,date:string,scraped_at:string,url:string,territory_name:string,state_code:string,excerpts:array<string>,edition:string,is_extra_edition:boolean,txt_url:string>> COMMENT 'from deserializer')
PARTITIONED BY (
  `scraped_date` string,
  `territory_id` string)
ROW FORMAT SERDE
  'org.openx.data.jsonserde.JsonSerDe'
WITH SERDEPROPERTIES (
  'paths'='gazettes,total_gazettes')
STORED AS INPUTFORMAT
  'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://political-datalake-raw/querido-diario/gazettes/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0',
  'CrawlerSchemaSerializerVersion'='1.0',
  'UPDATED_BY_CRAWLER'='political_data_lake_raw_crawler',
  'averageRecordSize'='764',
  'classification'='json',
  'compressionType'='none',
  'objectCount'='50',
  'partition_filtering.enabled'='true',
  'recordCount'='50',
  'sizeKey'='38533',
  'typeOfData'='file')

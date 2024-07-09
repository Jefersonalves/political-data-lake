from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.providers.amazon.aws.operators.emr import EmrServerlessStartJobOperator
from airflow.providers.amazon.aws.operators.lambda_function import (
    LambdaInvokeFunctionOperator,
)


def upload_directory_to_s3(aws_conn_id, local_directory, bucket_name):
    import logging
    import os

    s3_hook = S3Hook(aws_conn_id=aws_conn_id)
    for root, _, files in os.walk(local_directory):
        for file in files:
            local_path = os.path.join(root, file)
            s3_key = os.path.relpath(local_path, local_directory)
            s3_hook.load_file(
                filename=local_path, key=s3_key, bucket_name=bucket_name, replace=True
            )
            logging.info(f"Uploaded {local_path} to s3://{bucket_name}/{s3_key}")


def fetch_target_territories(date: str):
    import json

    territory_list = ["2704302", "1302603", "1600303", "1721000"]
    data = [
        json.dumps(
            {
                "date": date,
                "territory_id": territory,
                "bucket_name": "political-datalake-raw",
            }
        )
        for territory in territory_list
    ]
    return data


default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "retries": 0,
}

with DAG(
    "querido_diario_pipeline_dag",
    default_args=default_args,
    description="Run querido diario data pipeline",
    schedule_interval=None,
    start_date=datetime(2024, 4, 1),
    tags=["data-engineer", "ingestion"],
    catchup=True,
) as dag:

    fetch_territories_task = PythonOperator(
        task_id="fetch_territories",
        python_callable=fetch_target_territories,
        op_args=["{{ ds }}"],
        provide_context=True,
    )

    update_scripts_task = PythonOperator(
        task_id="update_scripts",
        python_callable=upload_directory_to_s3,
        op_kwargs={
            "aws_conn_id": "aws_politicaldatalake",
            "local_directory": "/opt/airflow/dags/scripts",
            "bucket_name": "{{ var.value.s3_scripts_bucket }}",
        },
    )

    # https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/dynamic-task-mapping.html
    ingest_data_task = LambdaInvokeFunctionOperator.partial(
        task_id="ingest_data",
        function_name="{{ var.value.lambda_ingestion_function }}",
        aws_conn_id="aws_politicaldatalake",
        region_name="sa-east-1",
    ).expand(payload=fetch_territories_task.output)

    process_raw_to_stage_task = EmrServerlessStartJobOperator(
        aws_conn_id="aws_politicaldatalake",
        task_id="process_raw_to_stage",
        application_id="{{ var.value.emr_serverless_application_id }}",
        execution_role_arn="{{ var.value.emr_serverless_execution_role_arn }}",
        job_driver={
            "sparkSubmit": {
                "entryPoint": "s3://{{ var.value.s3_scripts_bucket }}/raw_to_stage.py",
                "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
            }
        },
    )

    process_stage_to_analytics_task = EmrServerlessStartJobOperator(
        aws_conn_id="aws_politicaldatalake",
        task_id="process_stage_to_analytics",
        application_id="{{ var.value.emr_serverless_application_id }}",
        execution_role_arn="{{ var.value.emr_serverless_execution_role_arn }}",
        job_driver={
            "sparkSubmit": {
                "entryPoint": "s3://{{ var.value.s3_scripts_bucket }}/stage_to_analytics.py",
                "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
            }
        },
    )

    fetch_territories_task >> ingest_data_task
    [ingest_data_task, update_scripts_task] >> process_raw_to_stage_task
    process_raw_to_stage_task >> process_stage_to_analytics_task

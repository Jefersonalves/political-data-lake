from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.operators.emr import EmrServerlessStartJobOperator
from airflow.providers.amazon.aws.operators.lambda_function import (
    LambdaInvokeFunctionOperator,
)


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

    fetch_territories = PythonOperator(
        task_id="fetch_territories",
        python_callable=fetch_target_territories,
        op_args=["{{ ds }}"],
        provide_context=True,
    )

    # https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/dynamic-task-mapping.html
    ingest_data = LambdaInvokeFunctionOperator.partial(
        task_id="ingest_data",
        function_name="ingestion_lambda",
        aws_conn_id="aws_politicaldatalake",
        region_name="sa-east-1",
    ).expand(payload=fetch_territories.output)

    process_raw_to_stage = EmrServerlessStartJobOperator(
        aws_conn_id="aws_politicaldatalake",
        task_id="process_raw_to_stage",
        application_id="{{ var.value.emr_serverless_application_id }}",
        execution_role_arn="{{ var.value.emr_serverless_execution_role_arn }}",
        job_driver={
            "sparkSubmit": {
                "entryPoint": "s3://political-datalake-scripts/raw_to_stage.py",
                "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
            }
        },
    )

    process_stage_to_analytics = EmrServerlessStartJobOperator(
        aws_conn_id="aws_politicaldatalake",
        task_id="process_stage_to_analytics",
        application_id="{{ var.value.emr_serverless_application_id }}",
        execution_role_arn="{{ var.value.emr_serverless_execution_role_arn }}",
        job_driver={
            "sparkSubmit": {
                "entryPoint": "s3://political-datalake-scripts/stage_to_analytics.py",
                "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
            }
        },
    )

    (
        fetch_territories
        >> ingest_data
        >> process_raw_to_stage
        >> process_stage_to_analytics
    )

from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.operators.emr import EmrServerlessStartJobOperator
from airflow.providers.amazon.aws.operators.lambda_function import (
    LambdaInvokeFunctionOperator,
)


def fetch_territories(date: str):
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

    get_territories = PythonOperator(
        task_id="get_territories",
        python_callable=fetch_territories,
        op_args=["{{ ds }}"],
        provide_context=True,
    )

    # https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/dynamic-task-mapping.html
    invoke_lambda_function = LambdaInvokeFunctionOperator.partial(
        task_id="invoke_lambda_function",
        function_name="ingestion_lambda",
        aws_conn_id="aws_politicaldatalake",
        region_name="sa-east-1",
    ).expand(payload=get_territories.output)

    raw_to_stage_job = EmrServerlessStartJobOperator(
        aws_conn_id="aws_politicaldatalake",
        task_id="raw_to_stage_job",
        application_id="{{ var.value.emr_serverless_application_id }}",
        execution_role_arn="{{ var.value.emr_serverless_execution_role_arn }}",
        job_driver={
            "sparkSubmit": {
                "entryPoint": "s3://political-datalake-scripts/raw_to_stage.py",
                "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
            }
        },
    )

    get_territories >> invoke_lambda_function >> raw_to_stage_job

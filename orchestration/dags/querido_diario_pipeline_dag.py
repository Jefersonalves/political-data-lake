from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.operators.emr import EmrServerlessStartJobOperator
from airflow.providers.amazon.aws.operators.lambda_function import (
    LambdaInvokeFunctionOperator,
)
from querido_diario.territories import fetch_target_territories
from utils import upload_directory_to_s3

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
    tags=["data-engineer", "pipeline"],
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
            "local_directory": "/opt/airflow/dags/querido_diario/scripts",
            "bucket_name": "{{ var.value.s3_scripts_bucket }}",
        },
    )

    # https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/dynamic-task-mapping.html
    ingest_data_task = LambdaInvokeFunctionOperator.partial(
        task_id="ingest_gazettes_data",
        function_name="{{ var.value.lambda_ingestion_function }}",
        aws_conn_id="aws_politicaldatalake",
        region_name="sa-east-1",
    ).expand(payload=fetch_territories_task.output)

    process_raw_to_stage_task = EmrServerlessStartJobOperator(
        aws_conn_id="aws_politicaldatalake",
        task_id="process_raw_gazettes",
        application_id="{{ var.value.emr_serverless_application_id }}",
        execution_role_arn="{{ var.value.emr_serverless_execution_role_arn }}",
        job_driver={
            "sparkSubmit": {
                "entryPoint": "s3://{{ var.value.s3_scripts_bucket }}/gazettes_raw_to_stage.py",
                "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
            }
        },
    )

    process_stage_to_analytics_task = EmrServerlessStartJobOperator(
        aws_conn_id="aws_politicaldatalake",
        task_id="process_stage_gazettes",
        application_id="{{ var.value.emr_serverless_application_id }}",
        execution_role_arn="{{ var.value.emr_serverless_execution_role_arn }}",
        job_driver={
            "sparkSubmit": {
                "entryPoint": "s3://{{ var.value.s3_scripts_bucket }}/gazettes_stage_to_analytics.py",
                "sparkSubmitParameters": "--conf spark.hadoop.hive.metastore.client.factory.class=com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory",
            }
        },
    )

    fetch_territories_task >> ingest_data_task
    [ingest_data_task, update_scripts_task] >> process_raw_to_stage_task
    process_raw_to_stage_task >> process_stage_to_analytics_task

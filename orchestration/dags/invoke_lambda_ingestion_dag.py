from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
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
    "invoke_lambda_ingestion_dag",
    default_args=default_args,
    description="A DAG to invoke the Lambda function for ingestion",
    schedule_interval="0 0 * * *",
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
        aws_conn_id="aws_default",
        region_name="sa-east-1",
    ).expand(payload=get_territories.output)

    get_territories >> invoke_lambda_function

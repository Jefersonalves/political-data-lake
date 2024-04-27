
from datetime import datetime
from airflow import DAG
from airflow.providers.amazon.aws.operators.lambda_function import LambdaInvokeFunctionOperator

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

    #https://airflow.apache.org/docs/apache-airflow-providers-amazon/7.4.1/_api/airflow/providers/amazon/aws/operators/lambda_function/index.html
    invoke_lambda_function = LambdaInvokeFunctionOperator(
        task_id="invoke_lambda_function",
        function_name="ingestion_lambda",
        aws_conn_id='aws_default',
        payload='{"date": "{{ ds }}", "territory_id": "2704302", "bucket_name": "political-datalake-raw"}',
        region_name="sa-east-1",
    )

    invoke_lambda_function
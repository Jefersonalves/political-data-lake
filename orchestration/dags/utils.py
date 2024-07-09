import logging
import os

from airflow.providers.amazon.aws.hooks.s3 import S3Hook


def upload_directory_to_s3(aws_conn_id, local_directory, bucket_name):
    s3_hook = S3Hook(aws_conn_id=aws_conn_id)
    for root, _, files in os.walk(local_directory):
        for file in files:
            local_path = os.path.join(root, file)
            s3_key = os.path.relpath(local_path, local_directory)
            s3_hook.load_file(
                filename=local_path, key=s3_key, bucket_name=bucket_name, replace=True
            )
            logging.info(f"Uploaded {local_path} to s3://{bucket_name}/{s3_key}")

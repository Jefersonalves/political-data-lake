import json

import boto3
import requests


def lambda_handler(event, context):
    bucket_name = "political-data-lake-raw"
    file_name = "querido-diario/publication_date=2023-11-01/2704302.json"

    url = "https://queridodiario.ok.org.br/api/gazettes?territory_ids=2704302&published_since=2023-11-01&published_until=2023-11-01"
    r = requests.get(url)
    file_content = json.dumps(r.json())

    s3 = boto3.client("s3")
    s3.put_object(Body=file_content, Bucket=bucket_name, Key=file_name)
    return {"statusCode": 200, "body": "File uploaded successfully."}

import json
import logging

import boto3
import requests


def lambda_handler(event, context=None):
    """
    Fetches gazettes from Querido Diário API for a specific date and territory
    and uploads them to S3

    Example
    -------
    >>> lambda_handler(event={"date": "2023-11-01", "territory_id": "2704302", "bucket_name": "political-datalake-raw"}, context=None)
    >>> {"total_gazettes": 2,
        "gazettes": [
            {
            "territory_id": "2704302",
            "date": "2023-11-01",
            "scraped_at": "2023-11-01T21:02:39.809170",
            "url": "https://querido-diario.nyc3.cdn.digitaloceanspaces.com/2704302/2023-11-01/c7206d999cb0a5d167fad7534601df09fb9e199a.pdf",
            "territory_name": "Maceió",
            "state_code": "AL",
            "excerpts": [],
            "edition": "6799",
            "is_extra_edition": false,
            "txt_url": "https://querido-diario.nyc3.cdn.digitaloceanspaces.com/2704302/2023-11-01/c7206d999cb0a5d167fad7534601df09fb9e199a.txt"
            }
        ]
    }
    """
    bucket_name = event["bucket_name"]
    date = event["date"]
    territory_id = event["territory_id"]
    file_name = f"querido-diario/gazettes/scraped_date={date}/territory_id={territory_id}/{territory_id}.json"

    # https://queridodiario.ok.org.br/api/docs
    url = f"https://queridodiario.ok.org.br/api/gazettes?territory_ids={territory_id}&scraped_since={date}T00:00:00&scraped_until={date}T23:59:59"
    logging.info(f"Fetching data from {url}")
    try:
        r = requests.get(url)
        r.raise_for_status()
    except Exception as e:
        logging.error(f"Error: {e}")
        return {"statusCode": r.status_code, "body": "Error fetching data."}

    if r.json()["gazettes"] != []:
        s3 = boto3.client("s3")
        file_content = json.dumps(r.json())
        s3.put_object(Body=file_content, Bucket=bucket_name, Key=file_name)
        return {
            "statusCode": 200,
            "body": f"File uploaded successfully to {file_name}.",
        }
    else:
        logging.info(f"No gazettes found for {date} in {territory_id}")
        return {"statusCode": 200, "body": "No files to upload."}

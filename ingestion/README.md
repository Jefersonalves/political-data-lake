# ingestion
This folder contains the application used to run lambda functions to ingest data into the data lake
and terraform configuration to deploy the lambda function in AWS.

## Deploy
To deploy, first generate the zip file to be used by the lambda function:
```sh
cd querido-diario-ingestor; poetry build
cd querido-diario-ingestor; poetry run pip install --upgrade -t package dist/*.whl
cd querido-diario-ingestor/package; zip -r ../lambda.zip . -x '*.pyc'
```

Then, apply the terraform configuration:
```sh
terraform init
terraform apply
```

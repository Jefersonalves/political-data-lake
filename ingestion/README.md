# ingestion
This folder contains the application used to run lambda functions to ingest data into the data lake
and terraform configuration to deploy the lambda function in AWS.

## Deploy
To deploy, first generate the zip file to be used by the lambda function:
```sh
cd querido-diario-ingestor
poetry build
poetry run pip install --upgrade -t package dist/*.whl
zip -r ../lambda.zip ./package -x '*.pyc'
cd ..
```

Then, apply the terraform configuration:
```sh
terraform init
terraform apply
```

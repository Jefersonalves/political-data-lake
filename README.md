# political-data-lake

Data Lake para análise do cenário político brasileiro

## Arquitetura

![Arquitetura](./diagrams/political-data-lake.png)

## Usage

1. setup a `pessoal` profile in `~/.aws/credentials`:
```sh
aws configure --profile pessoal
```

### Setup Airflow
1. create a key pair value locally:
```sh
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/airflow-key
```

1. apply the terraform configuration:
```sh
cd platform/orchestration
terraform init
terraform apply
```

1. Install eb cli:
```sh
pip install awsebcli
```

1. Deploy the application to Elastic Beanstalk:
```sh
cd ../../orchestration
eb init
eb use airflow-env
eb deploy
```

### Setup Lambda function

1. Create Lambda zip:
```sh
make lambda
```
1. Apply the terraform configuration:
```sh
cd platform/ingestion
terraform init
terraform apply
```

## political-data-lake

Data Lake para análise do cenário político brasileiro

### Arquitetura

![Arquitetura](./diagrams/political-data-lake.png)

## Usage

1. setup a `pessoal` profile in `~/.aws/credentials`:
```sh
aws configure --profile pessoal
```

1. create a key pair value locally:
```sh
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/airflow-key
```

1. apply the terraform configuration:
```sh
terraform init
terraform apply
```

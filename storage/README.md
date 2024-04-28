# storage
This folder contains the terraform configuration to deploy the storage services in AWS. The script will create three S3 buckets, one for each data lake stage: `raw`, `stage`, and `analytics`.

## Deploy
To deploy the storage services, run the following commands:
```sh
terraform init
terraform apply
```

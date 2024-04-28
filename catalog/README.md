# catalog
This folder contains the terraform configuration to deploy the catalog services in AWS.
The script will create:
1. Necessary IAM roles and policies for Glue.
1. one glue database for each data lake stage: `raw`, `stage`, and `analytics`.
1. one glue crawler for each data lake stage.

## Deploy
To deploy the storage services, run the following commands:
```sh
terraform init
terraform apply
```

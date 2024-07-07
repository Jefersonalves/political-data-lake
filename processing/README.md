# processing
This folder contains the terraform configuration to deploy the processing services in AWS.
The script will create:
1. Necessary IAM roles and policies for EMR Serverless.
1. One EMR Serveless application

The script assumes that the datalake storage buckets have already been created

# deploy
To deploy the services, run the following commands:
```sh
terraform init
terraform apply
```

# next steps
Add incremental processing

# References
1. https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide
1. https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/security-iam-runtime-role.html
1. https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/metastore-config.html
1. https://github.com/aws-samples/emr-studio-notebook-examples/blob/main/examples/deltalake-example-notebook-pyspark.ipynb

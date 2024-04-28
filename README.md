# political-data-lake

End to end data lake project to analyze the brazilian political scenario.

## Architecture

The project architecture is represented in the diagram below:

![Architecture](./diagrams/political-data-lake.png)

All the project is orchestrated by [Airflow](https://airflow.apache.org).
The Airflow contains a DAG that invokes a AWS Lambda function that ingests data from [Querido Diário](https://queridodiario.ok.org.br) and stores it in a [AWS S3](https://aws.amazon.com/s3) bucket.

There are one bucket for each data lake layer: raw, stage, and analytics.

Each bucket has a [AWS Glue](https://aws.amazon.com/glue) crawler that creates a table in the catalog for the data stored in the bucket.

## Usage
The project is divided into storage, orchestration, ingestion, and catalog.
Each part has its own README file with instructions on how to deploy and use it.

The [terraform](https://www.terraform.io) tool is used to deploy the services in AWS.
To run the terraform scripts, you need to have a profile named `pessoal` in your `~/.aws/credentials` file.

Setup the profile with the following command:
```sh
aws configure --profile pessoal
```

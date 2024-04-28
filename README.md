# political-data-lake

End to end data lake project to analyze the brazilian political scenario.

## Architecture

![Architecture](./diagrams/political-data-lake.png)

## Usage
The project is divided into storage, orchestration, ingestion, and catalog.
Each part has its own README file with instructions on how to deploy and use it.

The [terraform](https://www.terraform.io) tool is used to deploy the services in AWS.
To run the terraform scripts, you need to have a profile named `pessoal` in your `~/.aws/credentials` file.

Setup the profile with the following command:
```sh
aws configure --profile pessoal
```

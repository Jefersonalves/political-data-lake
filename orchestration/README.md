# orchestration by airflow

## Usage
Copy `.env.example` file to `.env` and fill in the values following the example. Fill Fernet Key using [this instructions](https://airflow.apache.org/docs/apache-airflow/stable/security/secrets/fernet.html).

### AWS Deploy
1. Create a ssh key locally. This key will be used to access the EC2 instances created by terraform.
    ```sh
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/airflow-key
    ```

1. Apply the terraform configuration. This will create the necessary resources in AWS.

    ```sh
    terraform init
    terraform apply
    ```

1. Every time you want to deploy the application, use the [Elastic Beanstalk CLI](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install.html) to run the following commands:

    ```sh
    eb init
    eb deploy
    ```

# Tips
1. You can start the airflow locally using the commands:
    ```sh
    docker compose up airflow-init -d
    docker compose up -d
    ```

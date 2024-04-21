terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "sa-east-1"
  profile = "pessoal"
}

# Create a role for the lambda function with access to s3
resource "aws_iam_role" "ingestion_lambda_role" {
    name = "ingestion_lambda_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "lambda.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

# Attach a policy to the role to grant access to the S3 bucket
resource "aws_iam_role_policy_attachment" "ingestion_lambda_role_policy_attachment" {
    role       = aws_iam_role.ingestion_lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

## create lambda function using local lambda.zip file
resource "aws_lambda_function" "ingestion_lambda" {
  filename      = "../../ingestion/querido-diario-ingestor/lambda.zip"
  function_name = "ingestion_lambda"
  role          = aws_iam_role.ingestion_lambda_role.arn
  handler       = "querido_diario_ingestor.querido_diario.lambda_handler"
  runtime       = "python3.9"
  memory_size   = 128
  timeout       = 5
}

output role_arn {
    value = aws_iam_role.ingestion_lambda_role.arn
}

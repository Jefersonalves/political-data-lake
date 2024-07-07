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


# Create policy to be used by emr serverless runtime role
# https://docs.aws.amazon.com/emr/latest/EMR-Serverless-UserGuide/security-iam-runtime-role.html
resource "aws_iam_policy" "emr_serverless_policy" {
  name = "emr_serverless_runtime_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
        {
            Sid = "ReadAccessForEMRSamples",
            Effect = "Allow",
            Action = [
                "s3:GetObject",
                "s3:ListBucket"
            ],
            Resource = [
                "arn:aws:s3:::*.elasticmapreduce",
                "arn:aws:s3:::*.elasticmapreduce/*"
            ]
        },
        {
            Sid = "FullAccessToOutputBucket",
            Effect = "Allow",
            Action = [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:DeleteObject"
            ],
            Resource = [
                "arn:aws:s3:::political-datalake-scripts",
                "arn:aws:s3:::political-datalake-scripts/*",
                "arn:aws:s3:::political-datalake-raw",
                "arn:aws:s3:::political-datalake-raw/*",
                "arn:aws:s3:::political-datalake-stage",
                "arn:aws:s3:::political-datalake-stage/*",
                "arn:aws:s3:::political-datalake-analytics",
                "arn:aws:s3:::political-datalake-analytics/*"
            ]
        },
        {
            Sid = "GlueCreateAndReadDataCatalog",
            Effect = "Allow",
            Action = [
                "glue:GetDatabase",
                "glue:CreateDatabase",
                "glue:GetDataBases",
                "glue:CreateTable",
                "glue:GetTable",
                "glue:UpdateTable",
                "glue:DeleteTable",
                "glue:GetTables",
                "glue:GetPartition",
                "glue:GetPartitions",
                "glue:CreatePartition",
                "glue:BatchCreatePartition",
                "glue:GetUserDefinedFunctions"
            ],
            Resource = [
                "*"
            ]
        }
    ]
  })
}


# Create a role for execute emr scripts
resource "aws_iam_role" "emr_serverless_role" {
    name = "emr_serverless_runtime_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "emr-serverless.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })

    managed_policy_arns = [aws_iam_policy.emr_serverless_policy.arn]
}


# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/emrserverless_application
resource "aws_emrserverless_application" "emr_app" {
  name          = "serveless_etl_app"
  release_label = "emr-7.1.0"
  type          = "spark"

  initial_capacity {
    initial_capacity_type = "Driver"

    initial_capacity_config {
      worker_count = 1
      worker_configuration {
        cpu    = "4 vCPU"
        memory = "16 GB"
        disk   = "20 GB"
      }
    }
  }

  initial_capacity {
    initial_capacity_type = "Executor"

    initial_capacity_config {
      worker_count = 2
      worker_configuration {
        cpu    = "4 vCPU"
        memory = "16 GB"
        disk   = "20 GB"
      }
    }
  }

  maximum_capacity {
    cpu    = "12 vCPU"
    memory = "48 GB"
    disk = "60 GB"
  }

}


output emr_serverless_application_id {
    value = aws_emrserverless_application.emr_app.id
}

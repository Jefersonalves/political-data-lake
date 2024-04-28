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

resource "aws_glue_catalog_database" "raw_database" {
  name = "raw"
  description = "Database for political raw data"
}

resource "aws_glue_catalog_database" "stage_database" {
  name = "stage"
  description = "Database for political stage data"
}

resource "aws_glue_catalog_database" "analytics_database" {
  name = "analytics"
  description = "Database for political analytics data"
}

resource "aws_iam_policy" "read_datalake_policy" {
  name = "policy-political-datalake"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = [
            "arn:aws:s3:::political-datalake-raw/*",
            "arn:aws:s3:::political-datalake-stage/*",
            "arn:aws:s3:::political-datalake-analytics/*",
        ]
      },
    ]
  })
}

resource "aws_iam_role" "glue_crawler_role" {
    name = "political_crawler_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = {
                    Service = "glue.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
    managed_policy_arns = [aws_iam_policy.read_datalake_policy.arn]
}

resource "aws_iam_role_policy_attachment" "glue_crawler_role_policy_attachment_2" {
    role       = aws_iam_role.glue_crawler_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_classifier" "json_classifier" {
  name = "json_list_classifier"

  json_classifier {
    json_path = "$[*]"
  }
}

resource "aws_glue_crawler" "raw_crawler" {
  database_name = aws_glue_catalog_database.raw_database.name
  name          = "political_data_lake_raw_crawler"
  description   = "Crawler for political data lake raw data"
  role          = aws_iam_role.glue_crawler_role.arn
  classifiers   = [aws_glue_classifier.json_classifier.name]

  s3_target {
    path = "s3://political-datalake-raw/"
  }

  configuration = jsonencode({
    "Version": 1.0,
    "Grouping": {
      TableLevelConfiguration = 3
    }
  })
}

resource "aws_glue_crawler" "stage_crawler" {
  database_name = aws_glue_catalog_database.raw_database.name
  name          = "political_data_lake_stage_crawler"
  description   = "Crawler for political data lake stage data"
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://political-datalake-stage/"
  }

  configuration = jsonencode({
    "Version": 1.0,
    "Grouping": {
      TableLevelConfiguration = 3
    }
  })
}

resource "aws_glue_crawler" "analytics_crawler" {
  database_name = aws_glue_catalog_database.raw_database.name
  name          = "political_data_lake_analytics_crawler"
  description   = "Crawler for political data lake analytics data"
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://political-datalake-analytics/"
  }

  configuration = jsonencode({
    "Version": 1.0,
    "Grouping": {
      TableLevelConfiguration = 3
    }
  })
}

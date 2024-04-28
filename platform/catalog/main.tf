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

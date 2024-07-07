terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable bucket_prefix {
  type        = string
  default     = "political-datalake"
  description = "Prefix to be added to the bucket name"
}

provider "aws" {
  region  = "sa-east-1"
  profile = "politicaldatalake"
}

resource "aws_s3_bucket" "raw_bucket" {
    bucket = format("%s-raw", var.bucket_prefix)
}

resource "aws_s3_bucket" "stage_bucket" {
    bucket = format("%s-stage", var.bucket_prefix)
}

resource "aws_s3_bucket" "analytics_bucket" {
    bucket = format("%s-analytics", var.bucket_prefix)
}

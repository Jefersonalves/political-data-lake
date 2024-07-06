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

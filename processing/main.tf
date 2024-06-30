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
  name          = "etl-serveless-app"
  release_label = "emr-7.1.0"
  type          = "spark"

  initial_capacity {
    initial_capacity_type = "Driver"

    initial_capacity_config {
      worker_count = 1
      worker_configuration {
        cpu    = "4 vCPU"
        memory = "8 GB"
      }
    }
  }

  initial_capacity {
    initial_capacity_type = "Executor"

    initial_capacity_config {
      worker_count = 1
      worker_configuration {
        cpu    = "4 vCPU"
        memory = "8 GB"
        disk   = "32 GB"
      }
    }
  }

  maximum_capacity {
    cpu    = "16 vCPU"
    memory = "32 GB"
    disk = "128 GB"
  }

}

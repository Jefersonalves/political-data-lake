# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elastic_beanstalk_environment

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

locals {
  envs = { for tuple in regexall("(.*)=(.*)", file(".env")) : tuple[0] => tuple[1] }
}

resource "aws_key_pair" "airflowkey" {
  key_name   = "airflow-key"
  public_key = file("~/.ssh/airflow-key.pub")
}

resource "aws_elastic_beanstalk_application" "airflow" {
  name        = "airflow"
  description = "Airflow application"
}

resource "aws_elastic_beanstalk_environment" "airflowenv" {
  name                = "airflow-env"
  application         = aws_elastic_beanstalk_application.airflow.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.2.2 running Docker"
  tier = "WebServer"

  # https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-elasticbeanstalkenvironment
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t3.medium"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.airflowkey.key_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elb:listener"
    name      = "InstanceProtocol"
    value     = "HTTP"
  }

  dynamic "setting" {
      for_each = local.envs
      content {
          namespace = "aws:elasticbeanstalk:application:environment"
          name      = setting.key
          value     = setting.value
      }
  }
}

output "domain" {
  value = aws_elastic_beanstalk_environment.airflowenv.endpoint_url
}

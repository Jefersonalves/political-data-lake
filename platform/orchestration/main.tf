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
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  #key-pair
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.airflowkey.key_name
  }

  #aws:elasticbeanstalk:environment
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  #aws:elb:listener
  setting {
    namespace = "aws:elb:listener"
    name      = "ListenerProtocol"
    value     = "HTTP"
  }
  #InstanceProtocol
  setting {
    namespace = "aws:elb:listener"
    name      = "InstanceProtocol"
    value     = "HTTP"
  }

  #aws:elasticbeanstalk:application:environment
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PARAM1"
    value     = "value1"
  }
}

output "domain" {
  value = aws_elastic_beanstalk_environment.airflowenv.endpoint_url
}

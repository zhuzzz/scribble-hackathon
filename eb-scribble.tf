terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

# used when first provisioned this bucket
# resource "aws_s3_bucket" "default" {
#   bucket = "helloworld.applicationversion.bucket"
# }

data "aws_s3_bucket" "default" {
  bucket = "helloworld.applicationversion.bucket"
}

data "local_file" "go_source_bundle" {
  filename = "${path.module}/../../Downloads/scribble-go.zip"
}

# resource "aws_s3_bucket_object" "default" {
#   bucket = data.aws_s3_bucket.default.id
#   key    = "scribble-go-buildfile.zip"
#   source = data.local_file.go_source_bundle.filename
# }

data "aws_s3_bucket_object" "default" {
  bucket = data.aws_s3_bucket.default.bucket
  key    = "scribble-go-buildfile.zip"
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "scribble-go"
  application = "terraform-scribble-app"
  description = "application version created by terraform"
  bucket      = data.aws_s3_bucket.default.id
  key         = data.aws_s3_bucket_object.default.key
}

resource "aws_elastic_beanstalk_application" "terraform-scribble" {
  name        = "terraform-scribble-app"
  description = "first try"
}

resource "aws_elastic_beanstalk_environment" "terraformscribbleenv" {
  name                = "terraform-scribble-env"
  application         = aws_elastic_beanstalk_application.terraform-scribble.name
  solution_stack_name = "64bit Amazon Linux 2 v3.1.3 running Go 1"
  version_label       = aws_elastic_beanstalk_application_version.default.name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "us-west-2"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "m5.2xlarge"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PORT"
    value     = "8080"
  }
}


output "s3bucket" {
  value = aws_elastic_beanstalk_application_version.default.key
}


provider "aws" {
  region  = var.region
  version = "~> 3.15.0"
}

provider "github" {
  token   = "${data.aws_ssm_parameter.webhook_secret.value}"
  owner   = var.repository_owner
  version = "~> 4.0.0"
}

provider "random" {
  version = "~> 3.0.0"
}

provider "template" {
  version = "~> 2.2.0"
}
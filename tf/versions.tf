terraform {
  required_version = "1.11.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90.0"
    }
  }

  backend "s3" {
    region = "us-east-1"
    key    = "terraform/terraform.tfstate"
  }

#  backend "local" {
#    path   = "terraform.tfstate"
#  }
}

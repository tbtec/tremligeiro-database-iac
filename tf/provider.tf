terraform {
  required_version = "1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.90.0"
    }
  }

  backend "s3" {
    region = "us-east-1"
    key    = "terraform/database.tfstate"
  }

#  backend "local" {
#    path   = "terraform.tfstate"
#  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.tags
  }
}


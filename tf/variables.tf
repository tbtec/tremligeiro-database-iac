
variable "region" {
  description = "The default region to use for AWS"
  default     = "us-east-1"
}

variable "tags" {
  description = "The default tags to use for AWS resources"
  type        = map(string)
  default = {
    App = "cluster"
  }
}

#variable "bucket_name" {
#  description = "The name of the S3 bucket to store the tfstate file"
#}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  default     = "tremligeiro"
}

variable "database_name" {
  description = "The name of the RDS database"
  default     = "remligeiro_db"
}

variable "cluster_version" {
  description = "The version of Kubernetes to use"
  default     = "1.29"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "azs" {
  type        = list(string)
  description = "The availability zones to use for the VPC"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

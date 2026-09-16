terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Partial config - bucket/key/region/dynamodb_table supplied via -backend-config at init time.
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}

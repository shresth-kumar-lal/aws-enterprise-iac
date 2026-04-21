terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote State with Locking
  # Note: For a strictly $0 criteria, we keep it commented out so we can test locally without provisioning the S3 bucket.
  
  # backend "s3" {
  #   bucket         = "thelibrelife-terraform-state-backend"
  #   key            = "prod/terraform.tfstate"
  #   region         = "ap-south-1"
  #   dynamodb_table = "thelibrelife-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

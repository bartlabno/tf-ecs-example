data "aws_caller_identity" "current" {}

terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Environment = var.environment
      Owner       = var.owner
      Project     = var.project
      Managed     = "Managed by terraform"
    }
  }
}
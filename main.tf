# main.tf
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "assets" {
  bucket = "tf-shop-assets-roman-2026"

  tags = {
    Name      = "tf-shop assets"
    ManagedBy = "terraform"
    Owner     = "Roman"
  }
}


terraform {
  cloud {
    organization = "DubovetskiyRD1984"

    workspaces {
      tags = ["shop"]
    }
  }

  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    
    }    
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix = var.project

  instance_type = terraform.workspace == "prod" ? "t3.small" : "t3.micro"

  common_tags = {
    Project   = var.project
    ManagedBy = "terraform"
    Owner     = "Roman"
    env       = terraform.workspace
  }
}

module "bucket" {
  source             = "./modules/bucket"
  name_prefix        = "tf-shop-assets-roman-2026"
  versioning_enabled = true

  reader_arns = [
    aws_iam_role.ec2_s3_read.arn
  ]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-assets"
  })
}

module "network" {
  source   = "./modules/network"
  project  = var.project
  region   = var.region
  vpc_cidr = var.vpc_cidr
  subnets  = var.subnets
  tags     = local.common_tags
}

resource "aws_s3_object" "hello" {
  bucket = module.bucket.bucket_name
  key    = "hello.txt"
  source = "${path.module}/hello.txt"

  etag = filemd5("${path.module}/hello.txt")
}

moved {
  from = aws_s3_bucket.assets
  to   = module.bucket.aws_s3_bucket.this
}

module "logs_bucket" {
  source = "./modules/bucket"

  name_prefix        = "tf-shop-logs-roman-2026"
  versioning_enabled = false
  reader_arns        = []

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-logs"
  })
}

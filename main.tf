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
  }
}

provider "aws" {
  region = "eu-central-1"
}

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

resource "aws_s3_bucket" "assets" {
  bucket = "tf-shop-assets-roman-2026-${terraform.workspace}"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-assets"
})
  
}

module "network" {
  source = "./modules/network"
  project  = var.project
  region   = var.region
  vpc_cidr = var.vpc_cidr
  subnets  = var.subnets
  tags     = local.common_tags
}


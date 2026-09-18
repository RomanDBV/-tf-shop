locals {
  name_prefix = var.project

  common_tags = {
    Project   = var.project
    ManagedBy = "terraform"
    Owner     = "Roman"
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.project}-vpc" })
}


# Subnets
resource "aws_subnet" "net" {
  for_each = var.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.region}${each.value.az}"

  map_public_ip_on_launch = each.key == "public-a"

  tags = merge(var.tags, {
    Name = "${var.project}-${each.key}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rt"
  })

}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-rt"
  }
}

# Associate only public-a with public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.net["public-a"].id
  route_table_id = aws_route_table.public.id
}










variable "project" {
  description = "Префікс імен ресурсів"
  type        = string
  default     = "tf-shop"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    public-a = {
      cidr = "10.10.1.0/24"
      az   = "a"
    }

    private-b = {
      cidr = "10.10.11.0/24"
      az   = "b"
    }

    private-c = {
      cidr = "10.10.12.0/24"
      az   = "c"
    }
  }
}

variable "allowed_ports" {
  description = "TCP ports allowed by the security group"
  type        = list(number)
  default     = [22, 80, 443]
}

# VCS PR plan test

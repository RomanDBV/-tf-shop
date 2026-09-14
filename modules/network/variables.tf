variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "tags" {
  type = map(string)
}

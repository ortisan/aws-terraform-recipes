provider "aws" {
  region = var.region
}

data "aws_vpc" "router" {
  id = var.vpc_id
}

data "aws_caller_identity" "current" {}
provider "aws" {
  region = "us-east-1"
}

module "cluster" {
  source         = "terraform-aws-modules/rds-aurora/aws"
  name           = "aurora-cluster"
  engine         = "aurora-postgresql"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_class
  instances = {
    one = {}
  }

  vpc_id  = var.rds_vpc_id
  subnets = var.rds_subnet_ids

  allowed_security_groups = var.rds_allowed_security_groups
  allowed_cidr_blocks     = var.rds_allowed_cidr_blocks

  storage_encrypted   = true
  apply_immediately   = true
  monitoring_interval = 10

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

output "rds_database_name" {
  value = module.cluster.cluster_database_name
}

output "rds_cluster_endpoint" {
  value = module.cluster.cluster_endpoint
}

output "rds_cluster_cluster_port" {
  value = module.cluster.cluster_port
}
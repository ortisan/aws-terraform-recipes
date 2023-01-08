variable "rds_engine_version" {
  type    = string
  default = "14.5"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_vpc_id" {
  type    = string
  default = "vpc-08ccd18714a2e8437"
}

variable "rds_subnet_ids" {
  type    = list(string)
  default = ["subnet-01459f2806e7d9f24", "subnet-080509807e667e94e", "subnet-06c8a77208840d3c6"]
}

variable "rds_allowed_security_groups" {
  type    = list(string)
  default = ["sg-01a74b78d530cd862"]
}

variable "rds_allowed_cidr_blocks" {
  type    = list(string)
  default = ["172.31.0.0/16", "0.0.0.0/0"]
}
variable "create_dms" {
  default = "true"
}

variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  description = "Vpc id"
  type        = string
  default     = "vpc-08ccd18714a2e8437"
}

variable "subnet_ids" {
  description = "Subnet ids"
  type        = list(string)
  default     = ["subnet-01459f2806e7d9f24", "subnet-080509807e667e94e"]
}

variable "kms_arn" {
  description = "ARN of KMS"
  type        = string
  default     = ""
}

variable "security_group_ids" {
  description = "Security group ids"
  type        = list(string)
  default     = ["sg-01a74b78d530cd862"]
}

variable "source_attributes" {
  type = map(string)
  default = {
    engine        = "mysql"
    endpoint_type = "source"
    database_name = "userdb"
    endpoint_id   = "source-userdb"
    host          = "userdb.cn9vnkebenrp.us-east-1.rds.amazonaws.com"
    port          = "3306"
    username      = "ortisan"
    password      = "ortisan123"
  }
}

variable "target_attributes" {
  type = map(string)
  default = {
    engine        = "aurora"
    endpoint_type = "target"
    database_name = "useraurora"
    endpoint_id   = "target-useraurora"
    host          = "useraurora.cluster-cn9vnkebenrp.us-east-1.rds.amazonaws.com"
    port          = "3306"
    username      = "ortisan"
    password      = "ortisan123"
  }
}
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

variable "route_table_id" {
  default = "rtb-045bbd7d22b5e279d"
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

variable "task_image" {
  default = "779882487479.dkr.ecr.us-east-1.amazonaws.com/nginx:latest"
}

variable "branch_name" {
  default = "master"
}


variable "project_name" {
  default = "nginx-app"
}
variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  description = "Vpc id"
  type        = string
  default     = "vpc-08ccd18714a2e8437"
}

variable "db_instance_snapshot_arn" {
  description = "ARN of DB Instance snapshot"
  default     = "arn:aws:rds:us-east-1:779882487479:snapshot:userdbsnapshot"
}
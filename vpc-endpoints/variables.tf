variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-08ccd18714a2e8437"
}

variable "instance_type_bastion" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.micro"
}

variable "security_group_ids" {
  type    = list(string)
  default = ["sg-01a74b78d530cd862"]
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = { "Demo" = "Vpc Endpoint" }
}
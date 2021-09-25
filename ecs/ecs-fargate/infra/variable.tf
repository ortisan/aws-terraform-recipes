variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-08ccd18714a2e8437"
}

variable "subnets" {
  default = ["subnet-01459f2806e7d9f24", "subnet-080509807e667e94e"]
}

variable "task_image" {
  default = "779882487479.dkr.ecr.us-east-1.amazonaws.com/test-secrets:latest"
}

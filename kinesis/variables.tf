variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  default = "vpc-08ccd18714a2e8437"
}

variable "subnets" {
  default = ["subnet-01459f2806e7d9f24", "subnet-080509807e667e94e"]
}

variable "ec2_instance_type" {
  default = "t3.micro"
}

variable "task_image" {
  default = "779882487479.dkr.ecr.us-east-1.amazonaws.com/test-param-secret:latest"
  #default = "public.ecr.aws/nginx/nginx:latest"
}
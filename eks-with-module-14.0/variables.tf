variable "region" {
  default = "us-east-1"
}

variable "vpc_id" {
  description = "Vpc id"
  type        = string
  default     = "vpc-08ccd18714a2e8437"
}

variable "public_subnet_nat_id" {
  type = string
  default = "subnet-01459f2806e7d9f24"
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = { "info" = "eks-demo" }
}

variable "cluster_name" {
  default = "demo-with-module-module"
  type    = string
}

variable "cluster_version" {
  default = "1.18"
  type    = string
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [
    {
      rolearn  = "arn:aws:iam::779882487479:role/my_bastion"
      username = "xpto"
      groups   = ["system:masters"]
    },
    # {
    # rolearn  = "arn:aws:iam::779882487479:instance-profile/my_bastion"
    # username = "my_bastion"
    # groups   = ["system:masters"]
    # },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [{
    userarn  = "arn:aws:iam::779882487479:user/admin-cli"
    username = "admin-cli"
    groups   = ["system:masters"]
    },
    # {
    #   userarn  = "arn:aws:iam::779882487479:instance-profile/my_bastion"
    #   username = "my_bastion"
    #   groups   = ["system:masters"]
    # },
  ]
}

variable "workers_ingress_cidrs" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "cluster_egress_cidrs" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "workers_egress_cidrs" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "instance_type_worker_nodes" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t2.medium"
}


variable "instance_type" {
  default = "t2.medium"
  type    = string
}
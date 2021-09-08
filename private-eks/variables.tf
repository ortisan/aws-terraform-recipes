variable "region" {
  default = "us-east-1"
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = { "info" = "eks-demo" }
}

variable "cluster_name" {
  default = "eks-demo"
  type    = string
}

variable "nodegroup_name" {
  default = "ng"
  type    = string
}

variable "cluster_version" {
  default = "1.18"
  type    = string
}

variable "cluster_create_security_group" {
  description = "Whether to create a security group for the cluster or attach the cluster to `cluster_security_group_id`."
  type        = bool
  default     = true
}

variable "cluster_security_group_id" {
  description = "If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingress/egress to work with the workers"
  type        = string
  default     = ""
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_service_ipv4_cidr" {
  description = "service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = "192.168.0.0/16"
}

variable "cluster_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for cluster egress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
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

variable "aws_auth_additional_labels" {
  description = "Additional kubernetes labels applied on aws-auth ConfigMap"
  default     = {}
  type        = map(string)
}

variable "ami_worker_nodes" {
  description = "AMI for worker nodes"
  type        = string
  default     = "ami-05110126038e6d3ff"
}

variable "workers_ingress_cidrs" {
  description = "List of CIDR blocks that are permitted for workers ingress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "workers_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for workers egress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type_worker_nodes" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t2.medium"
}

variable "root_volume_size" {
  description = "Volume size for worker instances"
  type        = string
  default     = "100"
}

variable "root_volume_type" {
  description = "Volume type for worker instances"
  type        = string
  default     = "gp2"
}

variable "worker_public_ip" {
  description = "Associate a public ip address with a worker"
  type        = bool
  default     = false
}

variable "worker_eni_delete" {
  description = "Delete the Elastic Network Interface (ENI) on termination (if set to false you will have to manually delete before destroying)"
  type        = bool
  default     = true
}

variable "ami_bastion" {
  description = "AMI for bastion"
  type        = string
  default     = "ami-0d5eff06f840b45e9"
}

variable "instance_type_bastion" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "Vpc id"
  type        = string
  default     = "vpc-08ccd18714a2e8437"
}

variable "eks_oidc_root_ca_thumbprint" {
  type        = string
  description = "Thumbprint of Root CA for EKS OIDC, Valid until 2037"
  default     = "9e99a48a9960b14926bb7f3b02e22da2b0ab7280"
}



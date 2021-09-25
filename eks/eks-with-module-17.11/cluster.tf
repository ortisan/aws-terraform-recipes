# IAM

resource "aws_iam_role" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = "eks_cluster_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "eks_metrics" {
  count       = var.create_eks ? 1 : 0
  name        = "eks_metrics"
  path        = "/"
  description = "Policy to put EKS metrics on Cloudwatch"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-EksMetrics" {
  policy_arn = aws_iam_policy.eks_metrics[0].arn
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster[0].name
}

# Network

resource "aws_security_group" "cluster" {
  count       = var.create_eks ? 1 : 0
  name_prefix = var.cluster_name
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                      = "${var.cluster_name}-eks_cluster_sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster[0].id
  cidr_blocks       = var.cluster_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "vpc_cluster_ingress" {
  description       = "Allow all VPC comunicate with EKS cluster API."
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "fargate_ingress" {
  description       = "Allow all communications through anywhere."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

# Cluster 

module "eks" {
  # source                                         = "terraform-aws-modules/eks/aws"
  # version                                        = "17.11.0"
  source                                         = "./modules/eks_fargate_custom" # Use custom. Actual have bug https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1245
  create_eks                                     = var.create_eks
  cluster_name                                   = var.cluster_name
  cluster_version                                = var.cluster_version
  vpc_id                                         = var.vpc_id
  subnets                                        = [aws_subnet.eks_1a.id, aws_subnet.eks_1b.id]
  cluster_endpoint_private_access                = true
  enable_irsa                                    = true
  cluster_enabled_log_types                      = ["api", "audit", "authenticator", "scheduler", "controllerManager"]
  cluster_endpoint_private_access_cidrs          = var.private_subnets_cidr
  cluster_endpoint_public_access_cidrs           = var.public_cidr_access
  cluster_create_endpoint_private_access_sg_rule = true
  manage_cluster_iam_resources                   = false
  cluster_iam_role_name                          = aws_iam_role.cluster[0].name
  cluster_create_security_group                  = false
  cluster_security_group_id                      = aws_security_group.cluster[0].id
  manage_worker_iam_resources                    = false
  workers_role_name                              = aws_iam_role.workers[0].name
  worker_create_security_group                   = false
  worker_security_group_id                       = aws_security_group.workers[0].id
  fargate_profiles                               = {}
  # fargate_profiles                  = merge({}, var.fargate_profiles) # Created after nodegroups
  create_fargate_pod_execution_role = false
  fargate_pod_execution_role_name   = aws_iam_role.workers[0].name
  write_kubeconfig                  = false
  depends_on = [
    aws_iam_role.workers
  ]

  node_groups_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 20,
    "iam_role_arn" = aws_iam_role.workers[0].arn
  }

  node_groups = {
    example = {
      desired_capacity = 2
      max_capacity     = 5
      min_capacity     = 1

      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      additional_tags = {
        ExtraTag = "example"
      }
      taints = []
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }
}
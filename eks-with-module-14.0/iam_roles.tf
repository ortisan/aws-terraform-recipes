# resource "aws_iam_policy" "eks_load_balancer_controller" {
#   name        = "AWSLoadBalancerControllerIAMPolicy"
#   path        = "/"
#   description = "Policy to controller Load Balancer"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "iam:CreateServiceLinkedRole",
#         "ec2:DescribeAccountAttributes",
#         "ec2:DescribeAddresses",
#         "ec2:DescribeAvailabilityZones",
#         "ec2:DescribeInternetGateways",
#         "ec2:DescribeVpcs",
#         "ec2:DescribeSubnets",
#         "ec2:DescribeSecurityGroups",
#         "ec2:DescribeInstances",
#         "ec2:DescribeNetworkInterfaces",
#         "ec2:DescribeTags",
#         "ec2:GetCoipPoolUsage",
#         "ec2:DescribeCoipPools",
#         "elasticloadbalancing:DescribeLoadBalancers",
#         "elasticloadbalancing:DescribeLoadBalancerAttributes",
#         "elasticloadbalancing:DescribeListeners",
#         "elasticloadbalancing:DescribeListenerCertificates",
#         "elasticloadbalancing:DescribeSSLPolicies",
#         "elasticloadbalancing:DescribeRules",
#         "elasticloadbalancing:DescribeTargetGroups",
#         "elasticloadbalancing:DescribeTargetGroupAttributes",
#         "elasticloadbalancing:DescribeTargetHealth",
#         "elasticloadbalancing:DescribeTags"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "cognito-idp:DescribeUserPoolClient",
#         "acm:ListCertificates",
#         "acm:DescribeCertificate",
#         "iam:ListServerCertificates",
#         "iam:GetServerCertificate",
#         "waf-regional:GetWebACL",
#         "waf-regional:GetWebACLForResource",
#         "waf-regional:AssociateWebACL",
#         "waf-regional:DisassociateWebACL",
#         "wafv2:GetWebACL",
#         "wafv2:GetWebACLForResource",
#         "wafv2:AssociateWebACL",
#         "wafv2:DisassociateWebACL",
#         "shield:GetSubscriptionState",
#         "shield:DescribeProtection",
#         "shield:CreateProtection",
#         "shield:DeleteProtection"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:AuthorizeSecurityGroupIngress",
#         "ec2:RevokeSecurityGroupIngress"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": ["ec2:CreateSecurityGroup"],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": ["ec2:CreateTags"],
#       "Resource": "arn:aws:ec2:*:*:security-group/*",
#       "Condition": {
#         "StringEquals": {
#           "ec2:CreateAction": "CreateSecurityGroup"
#         },
#         "Null": {
#           "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
#         }
#       }
#     },
#     {
#       "Effect": "Allow",
#       "Action": ["ec2:CreateTags", "ec2:DeleteTags"],
#       "Resource": "arn:aws:ec2:*:*:security-group/*",
#       "Condition": {
#         "Null": {
#           "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
#           "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
#         }
#       }
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:AuthorizeSecurityGroupIngress",
#         "ec2:RevokeSecurityGroupIngress",
#         "ec2:DeleteSecurityGroup"
#       ],
#       "Resource": "*",
#       "Condition": {
#         "Null": {
#           "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
#         }
#       }
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:CreateLoadBalancer",
#         "elasticloadbalancing:CreateTargetGroup"
#       ],
#       "Resource": "*",
#       "Condition": {
#         "Null": {
#           "aws:RequestTag/elbv2.k8s.aws/cluster": "false"
#         }
#       }
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:CreateListener",
#         "elasticloadbalancing:DeleteListener",
#         "elasticloadbalancing:CreateRule",
#         "elasticloadbalancing:DeleteRule"
#       ],
#       "Resource": "*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:AddTags",
#         "elasticloadbalancing:RemoveTags"
#       ],
#       "Resource": [
#         "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*",
#         "arn:aws:elasticloadbalancing:*:*:loadbalancer/net/*/*",
#         "arn:aws:elasticloadbalancing:*:*:loadbalancer/app/*/*"
#       ],
#       "Condition": {
#         "Null": {
#           "aws:RequestTag/elbv2.k8s.aws/cluster": "true",
#           "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
#         }
#       }
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:AddTags",
#         "elasticloadbalancing:RemoveTags"
#       ],
#       "Resource": [
#         "arn:aws:elasticloadbalancing:*:*:listener/net/*/*/*",
#         "arn:aws:elasticloadbalancing:*:*:listener/app/*/*/*",
#         "arn:aws:elasticloadbalancing:*:*:listener-rule/net/*/*/*",
#         "arn:aws:elasticloadbalancing:*:*:listener-rule/app/*/*/*"
#       ]
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:ModifyLoadBalancerAttributes",
#         "elasticloadbalancing:SetIpAddressType",
#         "elasticloadbalancing:SetSecurityGroups",
#         "elasticloadbalancing:SetSubnets",
#         "elasticloadbalancing:DeleteLoadBalancer",
#         "elasticloadbalancing:ModifyTargetGroup",
#         "elasticloadbalancing:ModifyTargetGroupAttributes",
#         "elasticloadbalancing:DeleteTargetGroup"
#       ],
#       "Resource": "*",
#       "Condition": {
#         "Null": {
#           "aws:ResourceTag/elbv2.k8s.aws/cluster": "false"
#         }
#       }
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:RegisterTargets",
#         "elasticloadbalancing:DeregisterTargets"
#       ],
#       "Resource": "arn:aws:elasticloadbalancing:*:*:targetgroup/*/*"
#     },
#     {
#       "Effect": "Allow",
#       "Action": [
#         "elasticloadbalancing:SetWebAcl",
#         "elasticloadbalancing:ModifyListener",
#         "elasticloadbalancing:AddListenerCertificates",
#         "elasticloadbalancing:RemoveListenerCertificates",
#         "elasticloadbalancing:ModifyRule"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# POLICY
# }

resource "aws_iam_policy" "eks_metrics" {
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


resource "aws_iam_role" "cluster" {
  name = "eks_cluster_role"

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

# resource "aws_iam_role_policy_attachment" "cluster-LoadBalancerControllerPolicy" {
#   policy_arn = aws_iam_policy.eks_load_balancer_controller.arn
#   role       = aws_iam_role.cluster.name
# }

resource "aws_iam_role_policy_attachment" "cluster-EksMetrics" {
  policy_arn = aws_iam_policy.eks_metrics.arn
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_cloudwatch_log_group" "cluster_log_group" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7
}

resource "aws_security_group" "cluster" {
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
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = var.cluster_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "vpc_cluster_ingress" {
  description       = "Allow all VPC comunicate with EKS cluster API."
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}












### ROLE FOR WORKERS

resource "aws_iam_role" "workers" {
  name = "eks_workers_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

# Give to workers ec2 permission to ssm
# resource "aws_iam_role_policy_attachment" "ssm" {
#   role       = aws_iam_role.workers.name
#   policy_arn = "arn:aws:iam::779882487479:role/my_bastion"
# }


resource "aws_security_group" "workers" {
  name_prefix = var.cluster_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                      = "${var.cluster_name}-eks_workers_sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers.id
  cidr_blocks       = var.workers_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description       = "Allow workers pods to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  # source_security_group_id = aws_security_group.cluster.id
  cidr_blocks = var.workers_ingress_cidrs
  from_port   = 1025
  to_port     = 65535
  type        = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  description       = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  # source_security_group_id = aws_security_group.cluster.id
  cidr_blocks = var.workers_ingress_cidrs
  from_port   = 10250
  to_port     = 10250
  type        = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description       = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  # source_security_group_id = join("", aws_security_group.cluster.*.id)
  cidr_blocks = var.workers_ingress_cidrs
  from_port   = 443
  to_port     = 443
  type        = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_primary" {
  description       = "Allow pods running on workers to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol          = "all"
  security_group_id = aws_security_group.workers.id
  # source_security_group_id = local.cluster_primary_security_group_id
  cidr_blocks = var.workers_ingress_cidrs
  from_port   = 0
  to_port     = 65535
  type        = "ingress"
}

# resource "aws_security_group_rule" "cluster_primary_ingress_workers" {
#   description              = "Allow pods running on workers to send communication to cluster primary security group (e.g. Fargate pods)."
#   protocol                 = "all"
#   security_group_id        = local.cluster_primary_security_group_id
#   # source_security_group_id = join("", aws_security_group.workers.*.id)
#   from_port                = 0
#   to_port                  = 65535
#   type                     = "ingress"
# }






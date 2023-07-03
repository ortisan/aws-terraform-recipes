locals {
  cluster_security_group_id = var.cluster_create_security_group ? aws_security_group.cluster.id : var.cluster_security_group_id
  subnets                   = [aws_subnet.eks_1a.id, aws_subnet.eks_1b.id]
  ec2_principal             = "ec2.amazonaws.com"
  sts_principal             = "sts.amazonaws.com"
}
locals {
  subnets       = [aws_subnet.eks_1a.id, aws_subnet.eks_1b.id]
  ec2_principal = "ec2.amazonaws.com"
  sts_principal = "sts.amazonaws.com"
}
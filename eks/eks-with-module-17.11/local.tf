locals {
  subnets       = [aws_subnet.eks_1a.id, aws_subnet.eks_1b.id]
  ec2_principal = "ec2.amazonaws.com"
  sts_principal = "sts.amazonaws.com"
  fargate_profile_ids = {
    for profile_id in module.eks.fargate_profile_ids : replace(profile_id, "${var.cluster_name}:", "") => replace(profile_id, "${var.cluster_name}:", "")
  }
}
resource "aws_eks_addon" "vpc_cni" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "vpc-cni"
  addon_version     = "v1.9.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
  depends_on = [
    module.eks,
    data.aws_eks_cluster_auth.cluster
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "coredns"
  addon_version     = "v1.8.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"
  depends_on = [
    module.eks,
    data.aws_eks_cluster_auth.cluster
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name      = module.eks.cluster_id
  addon_name        = "kube-proxy"
  addon_version     = "v1.19.6-eksbuild.2"
  resolve_conflicts = "OVERWRITE"
  depends_on = [
    module.eks,
    data.aws_eks_cluster_auth.cluster
  ]
}
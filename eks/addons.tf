resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.cluster.id
  addon_name                  = "vpc-cni"
  addon_version               = "v1.13.0-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_cluster.cluster
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.cluster.id
  addon_name                  = "coredns"
  addon_version               = "v1.10.1-eksbuild.2"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  depends_on = [
    aws_eks_cluster.cluster,
    aws_eks_node_group.ng
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.cluster.id
  addon_name                  = "kube-proxy"
  addon_version               = "v1.27.1-eksbuild.1"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.cluster
  ]
}

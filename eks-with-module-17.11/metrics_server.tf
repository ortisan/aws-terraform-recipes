resource "helm_release" "custom_metrics_server" {
  name      = "custom-metrics-server"
  chart     = "./helm/custom-metrics-server"
  namespace = "kube-system"
  depends_on = [
    module.eks,
    data.aws_eks_cluster_auth.cluster
  ]
}
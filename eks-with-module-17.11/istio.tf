
# resource "helm_release" "istio_base" {
#   name             = "istio-base"
#   chart            = "./helm/istio-1.11.1/manifests/charts/base"
#   namespace        = "istio-system"
#   create_namespace = true
#   depends_on = [
#     module.eks,
#     data.aws_eks_cluster_auth.cluster,
#   ]
# }

# resource "helm_release" "istio_discovery" {
#   name             = "istiod"
#   chart            = "./helm/istio-1.11.1/manifests/charts/istio-control/istio-discovery"
#   namespace        = "istio-system"
#   create_namespace = true
#   depends_on = [
#     helm_release.istio_base
#   ]
# }

# resource "helm_release" "istio_ingress" {
#   name      = "istio-ingress"
#   chart     = "./helm/istio-1.11.1/manifests/charts/gateways/istio-ingress"
#   namespace = "istio-system"
#   # set {
#   #   name = "gateways.istio-ingressgateway.serviceAnnotations.service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"
#   #   value = "ip"
#   # }

#   # set {
#   #   name = "gateways.istio-ingressgateway.serviceAnnotations.service.beta.kubernetes.io/aws-load-balancer-scheme"
#   #   value = "internet-facing"
#   # }

#   depends_on = [
#     helm_release.istio_discovery
#   ]
# }

# resource "helm_release" "istio_egress" {
#   name      = "istio-egress"
#   chart     = "./helm/istio-1.11.1/manifests/charts/gateways/istio-egress"
#   namespace = "istio-system"
#   depends_on = [
#     helm_release.istio_discovery
#   ]
# }

# # Gateway of applications
# resource "helm_release" "istio_gateway_applications" {
#   name      = "istio-gateway-applications"
#   chart     = "./helm/istio-gateway-applications"
#   namespace = "istio-system"
#   depends_on = [
#     helm_release.istio_ingress
#   ]
# }

# # # Binding between istio and nlb
# # resource "helm_release" "istio_ingress_target_group_binding" {
# #   name             = "istio-ingress-target-group-binding2"
# #   chart            = "./helm/istio-ingress-target-group-binding"
# #   namespace        = "istio-system"
# #   create_namespace = true

# #   set {
# #     name  = "name"
# #     value = "istiobinding2"
# #   }

# #   set {
# #     name  = "tg_80_arn"
# #     value = aws_lb_target_group.istio_80_31381.arn
# #   }

# #   set {
# #     name  = "target_type"
# #     value = aws_lb_target_group.istio_80_31381.target_type
# #   }

# #   depends_on = [
# #     aws_lb_target_group.istio_80_31381,
# #     helm_release.istio_ingress,
# #     # helm_release.aws_load_balancer
# #   ]
# # }


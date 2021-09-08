resource "null_resource" "linux_packages" {
  provisioner "local-exec" {
    # TODO MARCELO ALTEREI AQUI
    command = <<EOF
apt-get update && apt-get install groff less python3 curl -y && cd && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && ls -la && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
# apt-get update && apt-get install awscli groff less python3 curl -y && cd && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && ls -la && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
EOF
  }
  triggers = {
    always_run = timestamp()
  }
}


# output kubeconfig_base64 {
#   value = base64encode(data.template_file.kubeconfig.rendered)
# }


# resource "null_resource" "istio-injection" {
#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     environment = {
#       KUBECONFIG = base64encode(data.template_file.kubeconfig.rendered)
#     }

#     command = <<EOF
#   kubectl label namespace default istio-injection=enabled --overwrite --kubeconfig <(echo $KUBECONFIG | base64 -d)
#   EOF
#   }

#   depends_on = [
#     null_resource.linux_packages,
#     module.eks,
#     aws_eks_node_group.node_groups
#   ]
# }

# resource "helm_release" "aws_load_balancer" {
#   name      = "istio-base"
#   chart     = "./helm/aws-load-balancer-controller"
#   namespace = "kube-system"
#   set {
#     name  = "fullnameOverride"
#     value = "TestingNLB"
#   }
#   set {
#     name  = "clusterName"
#     value = var.cluster_name
#   }
#   depends_on = [
#     kubernetes_namespace.istio-system
#   ]
# }


# resource "kubernetes_namespace" "istio-system" {
#   metadata {
#     name = "istio-system"
#     labels = {
#       istio-injection = "false"
#     }
#   }
#   depends_on = [
#     # null_resource.istio-injection,
#     module.eks,
#     aws_eks_node_group.node_groups
#   ]
# }

# resource "helm_release" "istio_base" {
#   name      = "istio-base"
#   chart     = "./helm/istio_manifest/charts/base"
#   namespace = "istio-system"
#   depends_on = [
#     kubernetes_namespace.istio-system
#   ]
# }

# resource "helm_release" "istio_discovery" {
#   name      = "istiod"
#   chart     = "./helm/istio_manifest/charts/istio-control/istio-discovery"
#   namespace = "istio-system"
#   depends_on = [
#     helm_release.istio_base
#   ]
# }

# resource "helm_release" "istio_ingress" {
#   name      = "istio-ingress"
#   chart     = "./helm/istio_manifest/charts/gateways/istio-ingress"
#   namespace = "istio-system"
#   depends_on = [
#     helm_release.istio_discovery
#   ]
# }

# resource "helm_release" "istio_egress" {
#   name      = "istio-egress"
#   chart     = "./helm/istio_manifest/charts/gateways/istio-egress"
#   namespace = "istio-system"
#   depends_on = [
#     helm_release.istio_discovery
#   ]
# }

# resource "null_resource" "configure_istio_gateway" {
#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     environment = {
#       KUBECONFIG = base64encode(data.template_file.kubeconfig.rendered)
#     }
#     command = <<EOF
#     kubectl apply -f ./helm/istio_manifest/manifests/istio-gateway.yaml --kubeconfig <(echo $KUBECONFIG | base64 -d)
#     EOF
#   }
#   triggers = {
#     always_run = timestamp()
#   }
#   depends_on = [
#     null_resource.linux_packages,
#     helm_release.istio_ingress,
#     module.eks,
#     aws_eks_node_group.node_groups
#   ]
# }


# output kubeconfig_base64 {
#   value = base64encode(data.template_file.kubeconfig.rendered)
# }

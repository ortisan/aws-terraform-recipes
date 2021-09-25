# Istio

## Namespace

resource "kubernetes_namespace" "istio-system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio-base" {
  name      = "istio-base"
  chart     = "./istio_manifests/charts/base"
  namespace = "istio-system"
}

resource "helm_release" "istio-discovery" {
  name      = "istiod"
  chart     = "./istio_manifests/charts/istio-control/istio-discovery"
  namespace = "istio-system"
  depends_on = [helm_release.istio-base]
}

resource "helm_release" "istio-ingress" {
  name      = "istio-ingress"
  chart     = "./istio_manifests/charts/gateways/istio-ingress"
  namespace = "istio-system"
  depends_on = [helm_release.istio-base]
}

resource "helm_release" "istio-egress" {
  name      = "istio-egress"
  chart     = "./istio_manifests/charts/gateways/istio-egress"
  namespace = "istio-system"
  depends_on = [helm_release.istio-base]
}



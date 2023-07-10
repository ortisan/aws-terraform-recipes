# Istio

## Namespace

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  name      = "istio-base"
  chart     = "./helm/istio-1.18.0/charts/base"
  namespace = "istio-system"
  set {
    name  = "global.hub"
    value = "${var.docker_hub}/istio"
  }
}

resource "helm_release" "istio_discovery" {
  name       = "istiod"
  chart      = "./helm/istio-1.18.0/charts/istio-control/istio-discovery"
  namespace  = "istio-system"
  depends_on = [helm_release.istio_base]
  set {
    name  = "global.hub"
    value = "${var.docker_hub}/istio"
  }
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  chart      = "./helm/istio-1.18.0/charts/gateways/istio-ingress"
  namespace  = "istio-system"
  depends_on = [helm_release.istio_base, helm_release.istio_discovery]
  set {
    name  = "global.hub"
    value = "${var.docker_hub}/istio"
  }
}

resource "helm_release" "istio_egress" {
  name       = "istio-egress"
  chart      = "./helm/istio-1.18.0/charts/gateways/istio-egress"
  namespace  = "istio-system"
  depends_on = [helm_release.istio_base, helm_release.istio_discovery]
  set {
    name  = "global.hub"
    value = "${var.docker_hub}/istio"
  }
}

# Binding between istio and nlb
resource "helm_release" "istio_ingress_target_group_binding" {
  name             = "istio-ingress-target-group-binding2"
  chart            = "./helm/istio-ingress-target-group-binding"
  namespace        = "istio-system"
  create_namespace = true

  set {
    name  = "name"
    value = "istiobinding2"
  }

  set {
    name  = "tg_80_arn"
    value = aws_lb_target_group.istio_80_31381.arn
  }

  set {
    name  = "target_type"
    value = aws_lb_target_group.istio_80_31381.target_type
  }

  depends_on = [
    aws_lb_target_group.istio_80_31381,
    helm_release.istio_ingress,
    helm_release.aws_load_balancer
  ]
}




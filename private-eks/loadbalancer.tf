
# resource "aws_iam_role" "eks_load_balancer_controller" {
#   name = "EksLoadBalancerControllerRole"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     },
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "eks_load_balancer_controller" {
#   policy_arn = aws_iam_policy.eks_load_balancer_controller.arn
#   role       = aws_iam_role.eks_load_balancer_controller.name
# }

# resource "kubernetes_service_account" "service_account" {
#   automount_service_account_token = true
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       # This annotation is only used when running on EKS which can
#       # use IAM roles for service accounts.
#       "eks.amazonaws.com/role-arn" = aws_iam_role.eks_load_balancer_controller.arn
#     }
#     labels = {
#       "app.kubernetes.io/name"       = "aws-load-balancer-controller"
#       "app.kubernetes.io/component"  = "controller"
#       "app.kubernetes.io/managed-by" = "terraform"
#     }
#   }
#   depends_on = [aws_eks_cluster.cluster]
# }

# resource "kubernetes_service_account" "app_service_account" {
#   automount_service_account_token = true
#   metadata {
#     name      = "my-service-account"
#     namespace = "default"
#     annotations = {
#       # This annotation is only used when running on EKS which can
#       # use IAM roles for service accounts.
#       "eks.amazonaws.com/role-arn" = aws_iam_role.eks_load_balancer_controller.arn
#     }
#     labels = {
#       "app.kubernetes.io/name"       = "my-service-account"
#       "app.kubernetes.io/component"  = "controller"
#       "app.kubernetes.io/managed-by" = "terraform"
#     }
#   }
#   depends_on = [aws_eks_cluster.cluster]
# }

# resource "helm_release" "aws-load-balancer-controller" {
#   chart      = "aws-load-balancer-controller"
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   atomic     = true
#   timeout    = 300
#   wait       = true

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.cluster.name
#   }

#   set {
#     name  = "region"
#     value = "us-east-1"
#   }

#   set {
#     name  = "vpcId"
#     value = var.vpc_id
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = false
#   }

#   set {
#     name  = "image.repository"
#     value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
#   }
#   set {
#     name  = "image.tag"
#     value = "1.1.6"
#   }
#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   depends_on = [
#     aws_eks_cluster.cluster
#   ]
# }

# # Generate a kubeconfig file for the EKS cluster to use in provisioners
# data "template_file" "kubeconfig" {
#   template = <<-EOF
#     apiVersion: v1
#     kind: Config
#     current-context: terraform
#     clusters:
#     - name: ${data.aws_eks_cluster.selected[0].name}
#       cluster:
#         certificate-authority-data: ${data.aws_eks_cluster.selected[0].certificate_authority.0.data}
#         server: ${data.aws_eks_cluster.selected[0].endpoint}
#     contexts:
#     - name: terraform
#       context:
#         cluster: ${data.aws_eks_cluster.selected[0].name}
#         user: terraform
#     users:
#     - name: terraform
#       user:
#         token: ${data.aws_eks_cluster_auth.selected[0].token}
#   EOF
# }

# Since the kubernetes_provider cannot yet handle CRDs, we need to set any
# supplied TargetGroupBinding using a null_resource.
#
# The method used below for securely specifying the kubeconfig to provisioners
# without spilling secrets into the logs comes from:
# https://medium.com/citihub/a-more-secure-way-to-call-kubectl-from-terraform-1052adf37af8

# resource "null_resource" "supply_target_group_arns" {
#   count = (length(var.target_groups) > 0) ? length(var.target_groups) : 0
#   provisioner "local-exec" {
#     interpreter = ["/bin/bash", "-c"]
#     environment = {
#       KUBECONFIG = base64encode(data.template_file.kubeconfig.rendered)
#     }
#     command = <<-EOF
#       cat <<YAML | kubectl -n ${var.k8s_namespace} --kubeconfig <(echo $KUBECONFIG | base64 --decode) apply -f -
#       apiVersion: elbv2.k8s.aws/v1beta1
#       kind: TargetGroupBinding
#       metadata:
#         name: ${lookup(var.target_groups[count.index], "name", "")}-tgb
#       spec:
#         serviceRef:
#           name: ${lookup(var.target_groups[count.index], "name", "")}
#           port: ${lookup(var.target_groups[count.index], "backend_port", "")}
#         targetGroupARN: ${lookup(var.target_groups[count.index], "target_group_arn", "")}
#       YAML
#     EOF
#   }
#   depends_on = [helm_release.alb_controller]
# }

# data "template_file" "hello_world_template_pod" {
#   template = file("${path.module}/hello-world.yaml")
# }

# resource "null_resource" "your_deployment" {
#   triggers = {
#     manifest_sha1 = "${sha1("${data.template_file.hello_world_template_pod.rendered}")}"
#   }
#   provisioner "local-exec" {
#     command = "kubectl create -f -<<EOF\n${data.template_file.hello_world_template_pod.rendered}\nEOF"
#   }

#   depends_on = [
#     aws_eks_cluster.cluster
#   ]
# }



# resource "kubernetes_pod" "hello_world" {
#   metadata {
#     name = "hello-world"
#   }

#   spec {
#     container {
#       image = "docker.io/hello-world:latest"
#       name  = "hello-world-pod"
#     }

#     # image_pull_secrets {
#     #   name = "docker-hub"
#     # }
#   }

#   depends_on = [
#     aws_eks_cluster.cluster
#   ]
# }







# resource "helm_release" "hello-world" {
#   chart      = "aws-load-balancer-controller"
#   name       = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   repository = "https://aws.github.io/eks-charts"
#   timeout    = 300
#   wait       = true

#   set {
#     name  = "clusterName"
#     value = var.cluster_name
#   }
#   set {
#     name  = "image.repository"
#     value = "602401143452.dkr.ecr.us-east-1.amazonaws.com/amazon/aws-load-balancer-controller"
#   }
#   set {
#     name  = "image.tag"
#     value = "v2.2.0"
#   }
#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }
# }

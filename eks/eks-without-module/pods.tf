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





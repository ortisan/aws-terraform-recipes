provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.9"
}


module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "v14.0.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  subnets                         = [aws_subnet.eks_1a.id, aws_subnet.eks_1b.id]
  vpc_id                          = var.vpc_id
  cluster_endpoint_private_access = true
  enable_irsa                     = true


  # node_groups = {
  #   ng1 = {
  #     desired_capacity = 1
  #     max_capacity     = 3
  #     min_capacity     = 1

  #     launch_template_id      = aws_launch_template.default.id
  #     launch_template_version = aws_launch_template.default.default_version

  #     additional_tags = {
  #       CustomTag = "EKS example"
  #     }
  #   }
  # }

  #   worker_groups_launch_template = [
  #     {
  #       name                                 = "refresh"
  #       asg_max_size                         = 2
  #       asg_desired_capacity                 = 2
  #       instance_refresh_enabled             = true
  #       instance_refresh_instance_warmup     = 60
  #       public_ip                            = false
  #       metadata_http_put_response_hop_limit = 3
  #       update_default_version               = true
  #       instance_refresh_triggers            = ["tag"]
  #       tags = [
  #         {
  #           key                 = "aws-node-termination-handler/managed"
  #           value               = ""
  #           propagate_at_launch = true
  #         },
  #         {
  #           key                 = "foo"
  #           value               = "buzz"
  #           propagate_at_launch = true
  #         }
  #       ]
  #     }
  #   ]

  #   worker_groups = [
  #     {
  #       instance_type = var.instance_type_worker_nodes
  #       asg_max_size  = 5
  #     }
  #   ]



  fargate_profiles = {
    default = {
      namespace = "default"

      # Kubernetes labels for selection
      # labels = {
      #   Environment = "test"
      #   GithubRepo  = "terraform-aws-eks"
      #   GithubOrg   = "terraform-aws-modules"
      # }

      # using specific subnets instead of all the ones configured in eks
      # subnets = ["subnet-0ca3e3d1234a56c78"]

      tags = {
        Owner = "test"
      }
    }

    istio = {
      namespace = "istio-system"

      # Kubernetes labels for selection
      # labels = {
      #   Environment = "test"
      #   GithubRepo  = "terraform-aws-eks"
      #   GithubOrg   = "terraform-aws-modules"
      # }

      # using specific subnets instead of all the ones configured in eks
      # subnets = ["subnet-0ca3e3d1234a56c78"]

      tags = {
        Owner = "test"
      }
    }
  }

}
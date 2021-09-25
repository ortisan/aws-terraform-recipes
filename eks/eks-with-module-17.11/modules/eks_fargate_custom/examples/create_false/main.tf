provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster" {
  count = 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = 0
  name  = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, [""]), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, [""]), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, [""]), 0)
  load_config_file       = false
}

module "eks" {
  source          = "../.."
  create_eks      = false
  cluster_version = ""

  vpc_id       = ""
  cluster_name = ""
  subnets      = []
}

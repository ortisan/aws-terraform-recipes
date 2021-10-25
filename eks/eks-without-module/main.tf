### EKS cluster for private subnets

#Docs 
## 1. https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html
## 2 https://aws.amazon.com/pt/blogs/containers/upcoming-changes-to-ip-assignment-for-eks-managed-node-groups/ 
## 3 https://docs.aws.amazon.com/eks/latest/userguide/create-public-private-vpc.html

provider "aws" {
  region = var.region
}

# 1. Network 
# 2. Cluster
# 3. Nodegroup
# 4. Kubernetes
# 5. Helm
# 6. Istio
# 7. Bastion

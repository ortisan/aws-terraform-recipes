# EKS With Module

This demo demonstrate how create EKS manually, without module.

## Prerequisites

Mirror repository:

docker pull istio/proxyv2:1.18.0
docker pull istio/pilot:1.18.0
docker pull istio/install-cni:1.18.0
docker pull public.ecr.aws/eks/aws-load-balancer-controller:v2.5.3

aws ecr create-repository --repository-name istio/proxyv2
aws ecr create-repository --repository-name istio/pilot
aws ecr create-repository --repository-name istio/install-cni
aws ecr create-repository --repository-name eks/aws-load-balancer-controller

docker tag istio/proxyv2:1.18.0 779882487479.dkr.ecr.us-east-1.amazonaws.com/istio/proxyv2:1.18.0
docker tag istio/pilot:1.18.0 779882487479.dkr.ecr.us-east-1.amazonaws.com/istio/pilot:1.18.0
docker tag istio/install-cni:1.18.0 779882487479.dkr.ecr.us-east-1.amazonaws.com/istio/install-cni:1.18.0
docker tag public.ecr.aws/eks/aws-load-balancer-controller:v2.5.3 779882487479.dkr.ecr.us-east-1.amazonaws.com/eks/aws-load-balancer-controller:v2.5.3

aws-load-balancer-controller:v2.5.3

docker push 779882487479.dkr.ecr.us-east-1.amazonaws.com/istio/proxyv2:1.18.0
docker push 779882487479.dkr.ecr.us-east-1.amazonaws.com/istio/pilot:1.18.0
docker push 779882487479.dkr.ecr.us-east-1.amazonaws.com/istio/install-cni:1.18.0
docker push 779882487479.dkr.ecr.us-east-1.amazonaws.com/eks/aws-load-balancer-controller:v2.5.3

pip install ecr-mirror
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 779882487479.dkr.ecr.us-east-1.amazonaws.com/ecr-public
ecr-mirror copy "istio/proxyv2:1.18.\*" 779882487479.dkr.ecr.us-east-1.amazonaws.com/proxyv2
ecr-mirror copy "nginx" 779882487479.dkr.ecr.us-east-1.amazonaws.com/nginx

ecr-mirror --registry-id 779882487479 copy "istio/proxyv2:1.6.\*" 779882487479.dkr.ecr.us-east-1.amazonaws.com/proxyv2

## Create EKS Cluster

```sh
terraform init
terraform apply -auto-approve
```

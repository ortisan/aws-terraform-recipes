# IAM
resource "aws_iam_role" "workers" {
  count = var.create_eks ? 1 : 0
  name  = "eks_workers_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers[0].name
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers[0].name
}


# Network

resource "aws_security_group" "workers" {
  count       = var.create_eks ? 1 : 0
  name_prefix = var.cluster_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                      = "${var.cluster_name}-eks_workers_sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers[0].id
  cidr_blocks       = var.workers_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers[0].id
  source_security_group_id = aws_security_group.workers[0].id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description       = "Allow workers pods to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers[0].id
  cidr_blocks       = var.workers_ingress_cidrs
  from_port         = 1025
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  description       = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers[0].id
  cidr_blocks       = var.workers_ingress_cidrs
  from_port         = 10250
  to_port           = 10250
  type              = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description       = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers[0].id
  cidr_blocks       = var.workers_ingress_cidrs
  from_port         = 443
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_primary" {
  description       = "Allow pods running on workers to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol          = "all"
  security_group_id = aws_security_group.workers[0].id
  cidr_blocks       = var.workers_ingress_cidrs
  from_port         = 0
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster[0].id
  source_security_group_id = aws_security_group.workers[0].id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

# Fix annotation of computing to only EC2
resource "null_resource" "patch_coredns_deployment" {
  provisioner "local-exec" {
    when        = create
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(data.template_file.kubeconfig.rendered)
    }
    command = <<EOF
kubectl patch deployment coredns -n kube-system --type json -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]' --kubeconfig <(echo $KUBECONFIG | base64 -d)
kubectl rollout restart deployments -n kube-system --kubeconfig <(echo $KUBECONFIG | base64 -d)
EOF
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    module.eks,
    data.aws_eks_cluster_auth.cluster,
    module.eks.fargate_profile_ids
  ]
}
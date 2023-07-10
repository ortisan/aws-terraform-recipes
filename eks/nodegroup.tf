# Cluster Nodegroup

## IAM Role
## SG
## Launch Template
## Nodegroup


resource "aws_iam_role" "workers" {
  name = "eks_workers_role"

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
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.workers.name
}

resource "aws_iam_role_policy_attachment" "workers-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.workers.name
}

# Give to workers ec2 permission to ssm
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.workers.name
  policy_arn = aws_iam_policy.bastion.arn
}


resource "aws_security_group" "workers" {
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
  security_group_id = aws_security_group.workers.id
  cidr_blocks       = var.workers_egress_cidrs
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description       = "Allow workers pods to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  # source_security_group_id = aws_security_group.cluster.id
  cidr_blocks = var.workers_ingress_cidrs
  from_port   = 1025
  to_port     = 65535
  type        = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  description       = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  # source_security_group_id = aws_security_group.cluster.id
  cidr_blocks = var.workers_ingress_cidrs
  from_port   = 10250
  to_port     = 10250
  type        = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description       = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol          = "tcp"
  security_group_id = aws_security_group.workers.id
  # source_security_group_id = join("", aws_security_group.cluster.*.id)
  cidr_blocks = var.workers_ingress_cidrs
  from_port   = 443
  to_port     = 443
  type        = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_primary" {
  description       = "Allow pods running on workers to receive communication from cluster primary security group (e.g. Fargate pods)."
  protocol          = "all"
  security_group_id = aws_security_group.workers.id
  # source_security_group_id = local.cluster_primary_security_group_id
  cidr_blocks = var.workers_ingress_cidrs
  from_port   = 0
  to_port     = 65535
  type        = "ingress"
}

# resource "aws_security_group_rule" "cluster_primary_ingress_workers" {
#   description       = "Allow pods running on workers to send communication to cluster primary security group (e.g. Fargate pods)."
#   protocol          = "all"
#   security_group_id = local.cluster_primary_security_group_id
#   # source_security_group_id = join("", aws_security_group.workers.*.id)
#   from_port = 0
#   to_port   = 65535
#   type      = "ingress"
# }

data "aws_ami" "eks_ami_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }
}

resource "aws_launch_template" "workers" {

  name_prefix = var.cluster_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = true
    }
  }

  # iam_instance_profile {
  #   name = aws_iam_instance_profile.workers.name
  # }

  image_id = data.aws_ami.eks_ami_latest.image_id

  instance_type = var.instance_type_worker_nodes

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = var.worker_public_ip
    delete_on_termination       = var.worker_eni_delete
    security_groups             = [aws_security_group.workers.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "true"
      },
    )
  }

  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex
B64_CLUSTER_CA=${aws_eks_cluster.cluster.certificate_authority[0].data}
API_SERVER_URL=${aws_eks_cluster.cluster.endpoint}
K8S_CLUSTER_DNS_IP=10.100.0.10
/etc/eks/bootstrap.sh ${var.cluster_name} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${var.ami_worker_nodes},eks.amazonaws.com/capacityType=ON_DEMAND,eks.amazonaws.com/nodegroup=${var.nodegroup_name}' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP

--//--\
  EOF
  )
}

resource "aws_iam_instance_profile" "workers" {
  name_prefix = var.cluster_name
  role        = aws_iam_role.workers.name
  path        = "/"
  tags        = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "ng" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.nodegroup_name
  node_role_arn   = aws_iam_role.workers.arn
  subnet_ids      = local.subnets

  launch_template {
    id      = aws_launch_template.workers.id
    version = aws_launch_template.workers.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_cluster.cluster,
    kubernetes_config_map.aws_auth,
    aws_iam_role_policy_attachment.workers-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.workers-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.workers-AmazonEC2ContainerRegistryReadOnly,
  ]
}

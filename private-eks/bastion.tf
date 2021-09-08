resource "aws_iam_role" "bastion" {
  name = "iam_bastion"

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

resource "aws_iam_policy" "bastion" {
  name   = "iam_policy_bastion"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:PutMetricData",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams",
        "logs:DescribeLogGroups",
        "logs:CreateLogStream",
        "logs:CreateLogGroup"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["ssm:GetParameter"],
      "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["eks:DescribeCluster", "eks:ListClusters"],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = aws_iam_policy.bastion.arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = "instance_profile_bastion2"
  role = aws_iam_role.bastion.name
}

resource "aws_security_group" "bastion" {
  name_prefix = var.cluster_name
  description = "Bastion security group."
  vpc_id      = var.vpc_id
  tags = merge(
    var.tags,
    {
      "Name"                                      = "${var.cluster_name}-bastion_eks"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    },
  )
}

resource "aws_security_group_rule" "bastion" {
  description       = "Allow bastion egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "bastion_ssh" {
  description       = "Allow pods to communicate with the EKS cluster API."
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  type              = "ingress"
}


# resource "aws_instance" "bastion" {

#   ami                         = var.ami_bastion
#   instance_type               = var.instance_type_bastion
#   associate_public_ip_address = true
#   subnet_id                   = aws_subnet.eks_1a.id
#   iam_instance_profile        = aws_iam_instance_profile.bastion.id
#   vpc_security_group_ids      = [aws_security_group.bastion.id]
#   user_data = base64encode(<<-EOF
#   MIME-Version: 1.0
#   Content-Type: multipart/mixed; boundary="//"

#   --//
#   Content-Type: text/x-shellscript; charset="us-ascii"
#   #!/bin/bash
#   yum install curl
#   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#   kubectl version --client
#   mkdir -p ~/.kube
#   ~/.kube/config-eks-demo
#   # export KUBECONFIG=$KUBECONFIG:~/.kube/config-eks-demo
#   # echo 'export KUBECONFIG=$KUBECONFIG:~/.kube/config-eks-demo' >> ~/.bashrc

#   --//--\
#     EOF
#   )

#   tags = {
#     Name = "Eks Bastion Host"
#   }

# }

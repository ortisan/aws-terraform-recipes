# Network

## VPC
## Subnets
## Routetables
## VPC Endpoints

# Comentado
# resource "aws_vpc" "vpc_eks" {
#   cidr_block           = "192.168.0.0/20"
#   enable_dns_support   = true
#   enable_dns_hostnames = true
#   tags = {
#     Name = "vpc_eks"
#   }
# }

# resource "aws_internet_gateway" "igw_eks" {
#   vpc_id = var.vpc_id

#   tags = {
#     Name = "igw_eks"
#   }
# }

resource "aws_route_table" "rt_eks" {
  vpc_id = var.vpc_id
  tags = {
    Name = "rt_eks"
  }
}

# resource "aws_route" "igw" {
#   route_table_id         = aws_route_table.rt_eks.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw_eks.id
# }

resource "aws_subnet" "eks_1a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.96.0/20"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    "Name"                                      = "eks-1a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_subnet" "eks_1b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.112.0/20"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = {
    "Name"                                      = "eks-1b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

# resource "aws_subnet" "eks_1a" {
#   vpc_id                  = var.vpc_id
#   cidr_block              = "192.168.0.0/24"
#   availability_zone       = "${var.region}a"
#   map_public_ip_on_launch = false
#   tags = {
#     "Name"                            = "eks-1a"
#     "kubernetes.io/role/internal-elb" = "1"
#   }
# }

# resource "aws_subnet" "eks_1b" {
#   vpc_id                  = var.vpc_id
#   cidr_block              = "192.168.1.0/24"
#   availability_zone       = "${var.region}b"
#   map_public_ip_on_launch = false

#   tags = {
#     "Name"                            = "eks-1b"
#     "kubernetes.io/role/internal-elb" = "1"
#   }
# }

resource "aws_route_table_association" "eks_1a" {
  subnet_id      = aws_subnet.eks_1a.id
  route_table_id = aws_route_table.rt_eks.id
}

resource "aws_route_table_association" "eks_1b" {
  subnet_id      = aws_subnet.eks_1b.id
  route_table_id = aws_route_table.rt_eks.id
}

# https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html#vpc-endpoints-private-clusters

resource "aws_security_group" "endpoints" {
  name        = "terraform-eks-demo-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "Security group to govern who can access the endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [aws_vpc.vpc_eks.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc endpoints sg"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.rt_eks.id]
  vpc_id            = var.vpc_id
}

resource "aws_vpc_endpoint" "ecr_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = local.subnets
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = local.subnets
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "logs_endpoint" {
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = local.subnets
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "sts_endpoint" {
  service_name        = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = local.subnets
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ec2_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = local.subnets
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ec2messages_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = local.subnets
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = local.subnets
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ssmmessages_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.endpoints.id]
  subnet_ids          = local.subnets
  vpc_id              = var.vpc_id
}


# resource "aws_vpc_endpoint" "elb_endpoint" {
#   service_name        = "com.amazonaws.${var.region}.elasticloadbalancing"
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true
#   security_group_ids  = [aws_security_group.endpoints.id]
#   subnet_ids          = local.subnets
#   vpc_id              = var.vpc_id
# }

# resource "aws_vpc_endpoint" "autoscaling_endpoint" {
#   service_name        = "com.amazonaws.${var.region}.autoscaling"
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true
#   security_group_ids  = [aws_security_group.endpoints.id]
#   subnet_ids          = local.subnets
#   vpc_id              = var.vpc_id
# }

# resource "aws_vpc_endpoint" "appmesh_envoy_management_endpoint" {
#   service_name        = "com.amazonaws.${var.region}.appmesh-envoy-management"
#   vpc_endpoint_type   = "Interface"
#   private_dns_enabled = true
#   security_group_ids  = [aws_security_group.endpoints.id]
#   subnet_ids          = local.subnets
#   vpc_id              = var.vpc_id
# }



# Network

resource "aws_subnet" "eks_1a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.96.0/20"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    "Name"                                      = "eks-1a"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "eks_1b" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.112.0/20"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false

  tags = {
    "Name"                                      = "eks-1b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_eip" "eks" {
  vpc = true
}

resource "aws_nat_gateway" "eks" {
  allocation_id = aws_eip.eks.id
  subnet_id     = var.public_subnet_nat_id
}

resource "aws_route_table" "rt_eks" {
  vpc_id = var.vpc_id
  tags = {
    Name = "rt_nat"
  }
}

resource "aws_route" "nat" {
  route_table_id         = aws_route_table.rt_eks.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks.id
}

resource "aws_route_table_association" "eks_1a" {
  subnet_id      = aws_subnet.eks_1a.id
  route_table_id = aws_route_table.rt_eks.id
}

resource "aws_route_table_association" "eks_1b" {
  subnet_id      = aws_subnet.eks_1b.id
  route_table_id = aws_route_table.rt_eks.id
}

resource "aws_security_group" "endpoints" {
  name        = "eks_endpoints"
  description = "Cluster vpc endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "Security group to govern who can access the endpoints"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg vpc endpoints"
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

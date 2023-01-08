provider "aws" {
  region = var.region
}

resource "aws_security_group" "vpc_endpoint" {
  name_prefix = "vpc-endpoint"
  description = "Bastion security group."
  vpc_id      = aws_vpc.internal.id
  tags = merge(
    var.tags,
    {
      "Name" = "bastion"
    },
  )
}

resource "aws_security_group_rule" "vpc_endpoint_egress" {
  description       = "Allow bastion egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.vpc_endpoint.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "vpc_endpoint_ingress" {
  description       = "Allow communication with vpc endpoint."
  protocol          = "tcp"
  security_group_id = aws_security_group.vpc_endpoint.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

resource "aws_vpc_endpoint" "s3" {
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.internal.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.internal.id
}

resource "aws_vpc_endpoint" "logs_endpoint" {
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.internal.id
  subnet_ids          = local.subnets
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "ec2" {
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.internal.id
  subnet_ids          = local.subnets
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "ec2messages_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.internal.id
  subnet_ids          = local.subnets
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.internal.id
  subnet_ids          = local.subnets
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "ssmmessages_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.internal.id
  subnet_ids          = local.subnets
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "ecr" {
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.internal.id
  subnet_ids          = local.subnets
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}

resource "aws_vpc_endpoint" "sts" {
  service_name        = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  vpc_id              = aws_vpc.internal.id
  subnet_ids          = local.subnets
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
}
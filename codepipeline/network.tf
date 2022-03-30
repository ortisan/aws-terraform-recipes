resource "aws_subnet" "codepipeline_1" {
  vpc_id                  = var.vpc_id
  cidr_block              = "172.31.96.0/20"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = {
    "Name" = "codepipeline-1"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_id]
  vpc_id            = var.vpc_id
}

resource "aws_vpc_endpoint" "ecr_endpoint_api" {
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = var.security_group_ids
  subnet_ids          = [aws_subnet.codepipeline_1.id]
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ecr_dkr_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = var.security_group_ids
  subnet_ids          = [aws_subnet.codepipeline_1.id]
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "logs_endpoint" {
  service_name        = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = var.security_group_ids
  subnet_ids          = [aws_subnet.codepipeline_1.id]
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "sts_endpoint" {
  service_name        = "com.amazonaws.${var.region}.sts"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = var.security_group_ids
  subnet_ids          = [aws_subnet.codepipeline_1.id]
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ssm_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = var.security_group_ids
  subnet_ids          = [aws_subnet.codepipeline_1.id]
  vpc_id              = var.vpc_id
}

resource "aws_vpc_endpoint" "ssmmessages_endpoint" {
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = var.security_group_ids
  subnet_ids          = [aws_subnet.codepipeline_1.id]
  vpc_id              = var.vpc_id
}

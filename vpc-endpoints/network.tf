resource "aws_vpc" "internal" {
  cidr_block           = "192.168.0.0/20"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.tags,
    {
      "Name" = "internal"
    },
  )
}

resource "aws_route_table" "internal" {
  vpc_id = aws_vpc.internal.id
  tags = merge(
    var.tags,
    {
      "Name" = "internal"
    },
  )
}

resource "aws_subnet" "internal_a" {
  vpc_id                  = aws_vpc.internal.id
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = false
  tags = merge(
    var.tags,
    {
      "Name" = "subnet-internal-a"
    },
  )
}

resource "aws_subnet" "internal_b" {
  vpc_id                  = aws_vpc.internal.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = false
  tags = merge(
    var.tags,
    {
      "Name" = "subnet-internal-b"
    },
  )
}

resource "aws_subnet" "internal_c" {
  vpc_id                  = aws_vpc.internal.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = false
  tags = merge(
    var.tags,
    {
      "Name" = "subnet-internal-c"
    },
  )
}

resource "aws_route_table_association" "internal_a" {
  subnet_id      = aws_subnet.internal_a.id
  route_table_id = aws_route_table.internal.id
}

resource "aws_route_table_association" "internal_b" {
  subnet_id      = aws_subnet.internal_b.id
  route_table_id = aws_route_table.internal.id
}

resource "aws_route_table_association" "internal_c" {
  subnet_id      = aws_subnet.internal_c.id
  route_table_id = aws_route_table.internal.id
}
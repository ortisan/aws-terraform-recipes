locals {
  subnets = [aws_subnet.internal_a.id, aws_subnet.internal_b.id, aws_subnet.internal_c.id]
}
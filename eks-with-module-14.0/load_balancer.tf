resource "aws_lb" "testing_istio" {
  name               = "testing-istio"
  internal           = false
  load_balancer_type = "network"
  subnets            = local.subnets

  enable_deletion_protection = false

  tags = {
    Environment = "test"
  }
}

resource "aws_lb_target_group" "testing_istio_80_31381" {
  name     = "testing-istio-80-31381"
  port     = 31381
  protocol = "TCP"
  vpc_id   = var.vpc_id
  target_type = "ip" # instance for ec2, ip for fargate

  health_check {
    path = "/healthz/ready"
    port = "31371"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.testing_istio.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.testing_istio_80_31381.arn
  }
}


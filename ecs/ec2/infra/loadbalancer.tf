resource "aws_security_group" "elb" {
  description = "elb-router"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    protocol    = "tcp"
    to_port     = 8080
  }

  name = "elb-router"

  tags = {
    Env  = "development"
    Name = "sg-elb-router"
  }

  vpc_id = data.aws_vpc.router.id
}


resource "aws_lb" "router" {
  name               = "router"
  internal           = true
  load_balancer_type = "network"
  # security_groups            = [aws_security_group.elb.id] # Disable if type "network"
  subnets                    = var.subnets
  enable_deletion_protection = false
  tags = {
    Environment = "development"
  }
}

resource "aws_lb_target_group" "router" {
  name        = "router"
  target_type = "instance"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.router.id
}

resource "aws_lb_listener" "router" {
  load_balancer_arn = aws_lb.router.arn
  port              = "8080"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.router.arn
  }

  depends_on = [
    aws_lb.router,
    aws_lb_target_group.router
  ]
}
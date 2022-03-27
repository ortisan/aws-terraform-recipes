resource "aws_lb" "nginx_app" {
  name                       = "nginx-app"
  internal                   = true
  load_balancer_type         = "application"
  subnets                    = var.subnet_ids
  enable_deletion_protection = false
  tags = {
    Environment = "test"
  }
}

resource "aws_lb_target_group" "nginx_app_blue" {
  name        = "nginx-app-blue"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group" "nginx_app_green" {
  name        = "nginx-app-green"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}


resource "aws_lb_listener" "nginx_app_blue" {
  load_balancer_arn = aws_lb.nginx_app.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_app_blue.arn
  }
}

resource "aws_lb_listener" "nginx_app_green" {
  load_balancer_arn = aws_lb.nginx_app.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_app_green.arn
  }
}
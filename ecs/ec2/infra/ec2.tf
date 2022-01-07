resource "aws_security_group" "ec2_router" {
  description = "router-ec2"
  name        = "router-ec2"
  vpc_id      = data.aws_vpc.router.id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    from_port = 0
    protocol  = "tcp"
    # security_groups = [aws_security_group.elb.id]
    cidr_blocks = [data.aws_vpc.router.cidr_block]
    to_port     = 65535
  }

  tags = {
    Env  = "development"
    Name = "sg-router-ec2"
  }
}

data "aws_iam_policy_document" "ec2_router" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "ec2_router" {
  assume_role_policy = data.aws_iam_policy_document.ec2_router.json
  name               = "ec2-router-role"
}

resource "aws_iam_role_policy_attachment" "ec2_router" {
  role       = aws_iam_role.ec2_router.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "router" {
  name = "ec2-router-instance-profile"
  role = aws_iam_role.ec2_router.name
}

data "aws_ssm_parameter" "ami_ecs" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# data "aws_ami" "router" {
#   filter {
#     name   = "name"
#     values = data.aws_ssm_parameter.ami_ecs.value
#   }
#   most_recent = true
#   owners      = ["amazon"]
# }

resource "aws_placement_group" "router" {
  name     = "router"
  strategy = "spread" # More available
}

resource "aws_launch_configuration" "router" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.router.id
  # image_id                    = data.aws_ami.router.id
  image_id      = data.aws_ssm_parameter.ami_ecs.value
  instance_type = "t3.large"
  # key_name      = "EC2-Router"

  lifecycle {
    create_before_destroy = true
  }

  name_prefix = "lauch-configuration-"

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  security_groups = [aws_security_group.ec2_router.id]
  user_data       = file("./templates/user_data.sh")
}

resource "aws_autoscaling_group" "router" {
  desired_capacity     = 1
  health_check_type    = "EC2"
  placement_group      = aws_placement_group.router.id
  launch_configuration = aws_launch_configuration.router.name
  max_size             = 2
  min_size             = 1
  name                 = "auto-scaling-group"

  tag {
    key                 = "Env"
    propagate_at_launch = true
    value               = "development"
  }

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "Router"
  }

  target_group_arns    = [aws_lb_target_group.router.arn]
  termination_policies = ["OldestInstance"]

  vpc_zone_identifier = var.subnets
}
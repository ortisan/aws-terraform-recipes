resource "aws_iam_role" "router_task" {
  name = "router-task-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "router_task" {
  name        = "router-task-policy"
  path        = "/"
  description = "Policies for ecs task"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "secretsmanager:DescribeSecret",
              "secretsmanager:*",
              "logs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "router_task_role_attachment" {
  policy_arn = aws_iam_policy.router_task.arn
  role       = aws_iam_role.router_task.name
}

resource "aws_ecs_cluster" "router" {
  name = "router"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_cloudwatch_log_group" "router" {
  name = "/ecs/router"

  tags = {
    Name        = "Router-App"
    Environment = "Dev"
  }
}

resource "aws_ecs_task_definition" "router" {
  family             = "router"
  # network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.router_task.arn
  execution_role_arn = aws_iam_role.router_task.arn
  cpu                = 1024
  memory             = 2048


  container_definitions = jsonencode([
    {
      name      = "router"
      image     = var.task_image
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-stream-prefix = "ecs"
          awslogs-group         = aws_cloudwatch_log_group.router.name
          awslogs-region        = var.region
        }
      }
    }
  ])

  depends_on = [
    aws_cloudwatch_log_group.router
  ]
}

resource "aws_security_group" "router" {
  name        = "router"
  description = "ECS service"
  vpc_id      = data.aws_vpc.router.id

  ingress {
    description = "Security group to govern who can access the endpoints"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_ecs_service" "router" {
  name            = "router"
  cluster         = aws_ecs_cluster.router.id
  task_definition = aws_ecs_task_definition.router.arn
  desired_count   = 1

  # network_configuration {
  #   subnets          = var.subnets
  #   assign_public_ip = false
  #   security_groups  = [aws_security_group.router.id]
  # }

  load_balancer {
    target_group_arn = aws_lb_target_group.router.arn
    container_name   = "router"
    container_port   = 8080
  }

  depends_on = [
    aws_cloudwatch_log_group.router,
    aws_lb_target_group.router
  ]
}
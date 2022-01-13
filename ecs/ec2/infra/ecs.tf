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
              "ecr:*",
              "kms:*",
              "logs:*",
              "secretsmanager:*",
              "sqs:*",
              "ssm:*"
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

resource "aws_cloudwatch_log_group" "router" {
  name = "/ecs/router"

  tags = {
    Name        = "Router-App"
    Environment = "Dev"
  }
}

resource "aws_ecs_cluster" "router" {
  name = "router"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "router" {
  family                   = "router"
  network_mode             = "bridge"
  task_role_arn            = aws_iam_role.router_task.arn
  execution_role_arn       = aws_iam_role.router_task.arn
  cpu                      = 256
  memory                   = 1024
  requires_compatibilities = ["EC2"]
  container_definitions = jsonencode([
    {
      name      = "router"
      image     = var.task_image
      cpu       = 10
      memory    = 512
      essential = true
      "environment" : [
        { "name" : "PARAM_STORE_NAME", "value" : "my-string" }
      ],
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
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

resource "aws_ecs_service" "router" {
  name            = "router"
  cluster         = aws_ecs_cluster.router.id
  task_definition = aws_ecs_task_definition.router.arn
  desired_count   = 1
  launch_type     = "EC2"

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
    aws_lb_target_group.router,
    aws_lb_listener.router
  ]
}



resource "aws_iam_role" "router_scaling" {
  name = "router-scaling-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "router_scaling" {
  name        = "router-scaling-policy"
  path        = "/"
  description = "Policies for ecs scaling"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
              "ecs:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "router_scaling" {
  policy_arn = aws_iam_policy.router_scaling.arn
  role       = aws_iam_role.router_scaling.name
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.router.name}/${aws_ecs_service.router.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  role_arn           = aws_iam_role.router_scaling.arn
}
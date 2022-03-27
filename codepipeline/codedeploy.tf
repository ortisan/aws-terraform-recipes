resource "aws_codedeploy_app" "nginx_app" {
  compute_platform = "ECS"
  name             = "nginx_app"
}

resource "aws_codedeploy_deployment_config" "nginx_app" {
  deployment_config_name = "nginx_app"
  compute_platform       = "ECS"
  traffic_routing_config {
    type = "TimeBasedCanary"
    time_based_canary {
      interval   = 10
      percentage = 10
    }
  }
}


resource "aws_iam_role" "custom_role_codedeploy" {
  name = "custom-role-codedeploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.custom_role_codedeploy.name
}


resource "aws_iam_policy" "ecs" {
  name   = "ecs-policyr"
  path   = "/"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs" {
  policy_arn = aws_iam_policy.ecs.arn
  role       = aws_iam_role.custom_role_codedeploy.name
}


resource "aws_sns_topic" "codedeploy_sns_notifier" {
  name = "codedeploy-sns-notifier"
}

resource "aws_codedeploy_deployment_group" "nginx_app" {
  app_name               = aws_codedeploy_app.nginx_app.name
  deployment_group_name  = "nginx-app"
  service_role_arn       = aws_iam_role.custom_role_codedeploy.arn
  deployment_config_name = aws_codedeploy_deployment_config.nginx_app.id
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }
  ecs_service {
    cluster_name = aws_ecs_cluster.nginx_app.name
    service_name = aws_ecs_service.nginx_app.name
  }
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.nginx_app_blue.arn]
      }
      test_traffic_route {
        listener_arns = [aws_lb_listener.nginx_app_green.arn]
      }
      target_group {
        name = aws_lb_target_group.nginx_app_blue.name
      }
      target_group {
        name = aws_lb_target_group.nginx_app_green.name
      }
    }
  }
  trigger_configuration {
    trigger_events     = ["DeploymentFailure"]
    trigger_name       = "nginx-app-trigger"
    trigger_target_arn = aws_sns_topic.codedeploy_sns_notifier.arn
  }
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
  alarm_configuration {
    alarms  = ["nginx-app-alarm"]
    enabled = true
  }
}

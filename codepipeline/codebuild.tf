resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "ortisan-codebuild"
}

resource "aws_s3_bucket_acl" "codebuild" {
  bucket = aws_s3_bucket.codebuild_bucket.id
  acl    = "private"
}

resource "aws_iam_role" "codebuild" {
  name = "codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": "arn:aws:ec2:us-east-1:${data.aws_caller_identity.current.account_id}:network-interface/*",
      "Condition": {
        "StringEquals": {
            "ec2:AuthorizedService": "codebuild.amazonaws.com",
            "ec2:Subnet": "${aws_subnet.codepipeline_1.arn}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild_bucket.arn}",
        "${aws_s3_bucket.codebuild_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    }
  ]
}
POLICY
}

data "template_file" "buildspec_codecommit" {
  template = file("${path.module}/buildspec.yaml")
}

resource "aws_codebuild_project" "nginx_app" {
  name          = var.project_name
  build_timeout = "10"
  service_role  = aws_iam_role.codebuild.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  cache {
    type     = "S3"
    location = aws_s3_bucket.codebuild_bucket.bucket
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.codebuild_bucket.id}/build-log"
    }
  }
  source {
    buildspec           = data.template_file.buildspec_codecommit.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = [aws_subnet.codepipeline_1.id]
    security_group_ids = var.security_group_ids
  }

  tags = {
    Environment = "Test"
  }
}

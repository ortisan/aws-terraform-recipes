data "template_file" "backend_service_account_assume_role_policy" {
  template = file("${path.module}/templates/backend-service-account-assume-role-policy.json.tpl")
  vars = {
    oidc_arn = module.eks.oidc_provider_arn
    oidc_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  }
}

resource "aws_iam_role" "eks_services" {
  name               = "eks-services-role"
  assume_role_policy = data.template_file.backend_service_account_assume_role_policy.rendered
}

resource "aws_iam_policy" "eks_services" {
  name        = "eks-services-policy"
  description = "Policies for Services EKS"

  policy = <<EOF
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
                "ssm:UpdateInstanceInformation",
                "ssm:ListInstanceAssociations",
                "ssm:DescribeInstanceProperties",
                "ssm:GetParameter",
                "ssm:GetParameters",
                "ssm:GetParametersByPath",
                "ssm:UpdateInstanceInformation",
                "ssm:ListInstanceAssociations",
                "ssm:DescribeDocumentParameters",
                "ssm:DescribeDocumentParameters",
                "ssm:DescribeParameters",
                "ssm:GetParameterHistory",
                "ssm:GetParametersByPath",
                "ssm:ListAssociations",
                "ssm:PutParameter",
                "secretsmanager:GetSecretValue",
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:ListSecrets",
                "secretsmanager:DescribeSecret",
                "secretsmanager:GetRandomPassword",
                "secretsmanager:GetResourcePolicy",
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:GenerateDataKey",
                "kms:ReEncryptTo",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:DescribeKey",
                "kms:GenerateDataKeyPairWithoutPlaintext",
                "kms:GenerateDataKeyPair",
                "kms:CreateGrant",
                "kms:ReEncryptFrom",
                "kms:ListGrants",
                "dynamodb:PutItem",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Query",
                "dynamodb:Scan",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancerPolicies",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetLoadBalancerPoliciesOfListener",
                "secretsmanager:*",
                "ec2:*",
                "ec2messages:*",
                "cloudwatch:*",
                "s3:*",
                "cassandra:*",
                "eks:*",
                "ecr:*",
                "sqs:*",
                "dkr:*"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_service_attachment" {
  role       = aws_iam_role.eks_services.name
  policy_arn = aws_iam_policy.eks_services.arn
}

resource "kubernetes_namespace" "applications" {
  metadata {
    name = "applications"
    labels = {
      istio-injection = "true"
    }
  }
  depends_on = [
    module.eks,
    data.aws_eks_cluster_auth.cluster
  ]
}


data "template_file" "backend_service_account" {
  template = file("${path.module}/templates/backend-service-account.yml.tpl")
  vars = {
    service_role_arn = aws_iam_role.eks_services.arn
  }
}

resource "kubectl_manifest" "backend_service_account" {
  yaml_body = data.template_file.backend_service_account.rendered
  depends_on = [
    module.eks,
    aws_iam_role.eks_services,
    kubernetes_namespace.applications
  ]
}



resource "aws_codecommit_repository" "nginx_app" {
  repository_name = "nginx-app-repo"
  default_branch = var.branch_name
}
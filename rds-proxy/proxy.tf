resource "aws_db_proxy" "rds_proxy" {
  name                   = "rds-proxy"
  debug_logging          = false
  engine_family          = "POSTGRESQL"
  idle_client_timeout    = 1800
  require_tls            = true
  role_arn               = aws_iam_role.rds_proxy.arn
  vpc_security_group_ids = var.rds_allowed_security_groups
  vpc_subnet_ids         = var.rds_subnet_ids

  auth {
    auth_scheme = "SECRETS"
    description = "example"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.rds_proxy.arn
  }
}

resource "aws_db_proxy_default_target_group" "rds_proxy" {
  db_proxy_name = aws_db_proxy.rds_proxy.name
  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 100
    max_idle_connections_percent = 50
  }
}
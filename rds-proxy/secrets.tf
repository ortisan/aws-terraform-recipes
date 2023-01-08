resource "aws_secretsmanager_secret" "rds_proxy" {
  name = "rds-proxy-2"
}

resource "aws_secretsmanager_secret_version" "rds_proxy" {
  depends_on = [
    module.cluster
  ]
  secret_id = aws_secretsmanager_secret.rds_proxy.id
  secret_string = jsonencode({
    username            = module.cluster.cluster_master_username
    password            = module.cluster.cluster_master_password
    engine              = "postgres"
    host                = module.cluster.cluster_endpoint
    port                = module.cluster.cluster_port
    dbClusterIdentifier = module.cluster.cluster_id
  })
}
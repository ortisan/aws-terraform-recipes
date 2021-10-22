resource "aws_security_group" "rds_user" {
  name_prefix = "rds_cluster_user"
  description = "RDS Cluster User security group."
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "rds_cluster_user"
  }
}

resource "aws_security_group_rule" "rds_user_egress" {
  description       = "Allow RDS egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.rds_user.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "rds_user_ingress" {
  description       = "Allow all VPC comunicate with RDS User."
  protocol          = "tcp"
  security_group_id = aws_security_group.rds_user.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "ingress"
}

resource "aws_rds_cluster" "user" {
  cluster_identifier              = "user"
  database_name                   = "user"
  engine                          = "aurora-mysql"
  engine_version                  = "5.7.mysql_aurora.2.07.2"
  availability_zones              = ["us-east-1a", "us-east-1b", "us-east-1c"]
  master_username                 = "ortisan"
  master_password                 = "ortisan123"
  storage_encrypted               = true
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
}

resource "aws_rds_cluster_instance" "user" {
  count              = 2
  identifier         = "user-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.user.id
  instance_class     = "db.r5.large"
  engine             = aws_rds_cluster.user.engine
  engine_version     = aws_rds_cluster.user.engine_version
}
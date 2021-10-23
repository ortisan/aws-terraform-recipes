resource "aws_security_group" "rds_user" {
  name_prefix = "rds_instance_user"
  description = "RDS User security group."
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "rds_instance_user"
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
  from_port         = 3306
  to_port           = 3306
  type              = "ingress"
}

resource "aws_db_parameter_group" "default" {
  name   = "default-mysql-pg"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_instance" "user" {
  engine                          = "mysql"
  engine_version                  = "8.0.23"
  instance_class                  = "db.t3.medium"
  name                            = "userdb"
  identifier                      = "userdb"
  username                        = "ortisan"
  password                        = "ortisan123"
  parameter_group_name            = aws_db_parameter_group.default.id
  skip_final_snapshot             = true
  multi_az                        = true
  allocated_storage               = 50
  max_allocated_storage           = 100
  storage_type                    = "gp2"
  storage_encrypted               = true
  publicly_accessible             = true
  enabled_cloudwatch_logs_exports = ["error", "slowquery"]
  auto_minor_version_upgrade      = true
  vpc_security_group_ids          = [aws_security_group.rds_user.id]
  depends_on = [
    aws_security_group.rds_user
  ]
}

output "rds_endpoint" {
  value = aws_db_instance.user.endpoint
}
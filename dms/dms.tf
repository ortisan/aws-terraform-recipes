# Create a new replication subnet group
resource "aws_dms_replication_subnet_group" "userdb" {
  count                                = local.dms_count
  replication_subnet_group_description = "Subnet replication subnet group for userdb"
  replication_subnet_group_id          = "userdb"

  subnet_ids = var.subnet_ids
  tags = {
    Name = "Subnet group userdb"
  }
}

# Create a new replication instance
resource "aws_dms_replication_instance" "replication_userdb" {
  count                        = local.dms_count
  allocated_storage            = 100
  apply_immediately            = false
  auto_minor_version_upgrade   = true
  availability_zone            = "us-east-1b"
  engine_version               = "3.4.5"
  multi_az                     = false
  preferred_maintenance_window = "sun:23:00-sun:23:59"
  publicly_accessible          = false
  replication_instance_class   = "dms.t2.micro"
  replication_instance_id      = "replication-userdb"
  replication_subnet_group_id  = aws_dms_replication_subnet_group.userdb[0].id
  tags = {
    Name = "replication-userdb"
  }
  vpc_security_group_ids = var.security_group_ids
  depends_on = [
    aws_dms_replication_subnet_group.userdb
  ]
}

# Source endpoint
resource "aws_dms_endpoint" "source_userdb" {
  count                       = local.dms_count
  database_name               = var.source_attributes.database_name
  endpoint_id                 = var.source_attributes.endpoint_id
  endpoint_type               = var.source_attributes.endpoint_type
  engine_name                 = var.source_attributes.engine
  server_name                 = var.source_attributes.host
  port                        = var.source_attributes.port
  username                    = var.source_attributes.username
  password                    = var.source_attributes.password
  extra_connection_attributes = ""
  ssl_mode                    = "none"
  tags = {
    Name = "source_userdb_endpoint"
  }
  depends_on = [
    aws_dms_replication_instance.replication_userdb
  ]
}

# Target endpoint
resource "aws_dms_endpoint" "target_userdb" {
  count                       = local.dms_count
  database_name               = var.target_attributes.database_name
  endpoint_id                 = var.target_attributes.endpoint_id
  endpoint_type               = var.target_attributes.endpoint_type
  engine_name                 = var.target_attributes.engine
  server_name                 = var.target_attributes.host
  port                        = var.target_attributes.port
  username                    = var.target_attributes.username
  password                    = var.target_attributes.password
  extra_connection_attributes = ""
  ssl_mode                    = "none"
  tags = {
    Name = "target_useraurora_endpoint"
  }
  depends_on = [
    aws_dms_replication_instance.replication_userdb
  ]
}

# Read table template https://github.com/amazon-archives/aws-database-migration-tools/blob/master/Blogs/DMS%20Automation%20Framework/S3Files/table-mappings.json
data "template_file" "table_mapping" {
  template = file("${path.module}/templates/table_mapping.json")
}

data "template_file" "task_settings" {
  template = file("${path.module}/templates/task_settings.json")
}

# Create a new replication task
resource "aws_dms_replication_task" "userdb" {
  count                    = local.dms_count
  migration_type           = "full-load-and-cdc"
  replication_instance_arn = aws_dms_replication_instance.replication_userdb[0].replication_instance_arn
  replication_task_id      = "userdb-task"
  // https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TableMapping.SelectionTransformation.Tablesettings.html
  table_mappings = data.template_file.table_mapping.rendered
  //https://docs.aws.amazon.com/dms/latest/userguide/CHAP_Tasks.CustomizingTasks.TaskSettings.html  
  replication_task_settings = data.template_file.task_settings.rendered
  source_endpoint_arn       = aws_dms_endpoint.source_userdb[0].endpoint_arn
  tags = {
    Name = "replication task userdb"
  }
  target_endpoint_arn = aws_dms_endpoint.target_userdb[0].endpoint_arn
  depends_on = [
    aws_dms_replication_instance.replication_userdb
  ]
}
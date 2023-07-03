resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name        = "KDADatabaseName"
  description = "Database for KDA Application Source and Target Tables"
}
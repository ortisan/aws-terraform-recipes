


# resource "aws_iam_policy" "exporter_importer_rds_snapshots" {
#   name        = "exporter_importer_rds_snapshots"
#   path        = "/"
#   description = "Policy to export RDS snapshots to S3"
#   policy      = <<POLICY
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": [
#                 "s3:PutObject*",
#                 "s3:ListBucket",
#                 "s3:GetObject*",
#                 "s3:DeleteObject*",
#                 "s3:GetBucketLocation"
#             ],
#             "Resource": [
#                 "${aws_s3_bucket.dbs_snapshots_ortisan}",
#                 "${aws_s3_bucket.dbs_snapshots_ortisan}/*"
#             ],
#             "Effect": "Allow"
#         }
#     ]
# }
# POLICY
#   depends_on = [
#     aws_s3_bucket.dbs_snapshots_ortisan
#   ]
# }

# resource "aws_iam_role" "exporter_rds_snapshots" {
#   name = "exporter_rds_snapshots"

#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid":"Exporter",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "export.rds.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     },
#     {
#       "Sid":"Importer",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "rds.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }

#   ]
# }
# POLICY
# }
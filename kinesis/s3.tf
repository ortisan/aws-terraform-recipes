resource "aws_s3_bucket" "taxi_trip_dataset" {
  bucket = "nyctaxitrips-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "curated_dataset" {
  bucket = "curateddatav-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
}
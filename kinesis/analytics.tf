resource "aws_s3_bucket" "example" {
  bucket = "example-flink-application"
}

resource "aws_s3_object" "example" {
  bucket = aws_s3_bucket.example.bucket
  key    = "example-flink-application"
  source = "flink-app.jar"
}
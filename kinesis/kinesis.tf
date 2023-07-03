resource "aws_kinesis_stream" "input_stream" {
  name        = "input-stream"
  stream_mode = "ON_DEMAND"
  #   shard_count      = 1 # Required if PROVISIONED MODE
  retention_period = 24 # Default 24 hours

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Environment = "prod"
  }
}
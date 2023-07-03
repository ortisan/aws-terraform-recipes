resource "aws_cloud9_environment_ec2" "kinesis_realtime_streaming" {
  instance_type               = "m5.large"
  name                        = "kinesis-realtime-streaming"
  description                 = "Real Time Streaming with Amazon Kinesis Cloud9 IDE"
  automatic_stop_time_minutes = 30
  image_id                    = "amazonlinux-2-x86_64"
}
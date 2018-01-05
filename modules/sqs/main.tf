resource "aws_sqs_queue" "queue" {
  name                       = "${var.name}-previews"
  visibility_timeout_seconds = 365
}

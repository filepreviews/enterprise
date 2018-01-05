resource "aws_iam_role" "ec2_role" {
  name = "${var.name}-ec2-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ec2_sqs_broker" {
  name = "${var.name}-sqs-broker"
  role = "${aws_iam_role.ec2_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": "*",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:ListQueues",
        "sqs:GetQueueUrl",
        "sqs:PurgeQueue",
        "sqs:ReceiveMessage",
        "sqs:SendMessage",
        "sqs:GetQueueAttributes",
        "sqs:CreateQueue"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}-ec2-instance-profile"
  path = "/"
  role = "${aws_iam_role.ec2_role.name}"
}

output "instance_profile" {
  value = "${aws_iam_instance_profile.instance_profile.id}"
}

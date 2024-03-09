resource "aws_iam_role" "role" {
  name = var.role_name
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
  )
  managed_policy_arns = var.policy_arn

  tags = {
    role_name = var.role_name
  }
}





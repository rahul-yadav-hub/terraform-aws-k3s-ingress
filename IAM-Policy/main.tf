resource "aws_iam_policy" "policy" {
  name        = var.policy_name
  path        = "/"
  description = "Custom policy for K3S EC2 Nodes"

  policy = file(var.json_policy_path)

}



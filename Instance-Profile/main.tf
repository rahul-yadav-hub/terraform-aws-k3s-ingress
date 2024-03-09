// instance profile created
resource "aws_iam_instance_profile" "instance-profile-name" {
  role = var.instance_profile_name
}


resource "aws_instance" "master" {
  count                       = var.counts
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = var.sg_id
  subnet_id                   = var.subnet_id
  iam_instance_profile        = var.iam_role
  tags = {
    Name = var.tag
    "kubernetes.io/cluster/mycluster" = "owned"
  }
  user_data = var.script_path
}


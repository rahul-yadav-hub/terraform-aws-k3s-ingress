variable "region" {
  description = "Value of the aws region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_name" {
  description = "Value of the vpc name"
  type        = string
}

variable "cidr_block_vpc" {
  description = "Value of the CIDR Block in VPC"
  type        = string

}

variable "tag" {
  description = "Tag all resource with this value"
  type        = string
}

variable "public_subnet_count" {
  description = "Value of the no. public subnet to create"
  type = number
}

variable "private_subnet_count" {
  description = "Value of the no. private subnet to create"
  type = number
}

variable "ami_id" {
  description = "Value of the AMI for the K3s EC2 instance"
  type        = string
}

variable "instance_type_master" {
  description = "Value of the instance type for the K3s Master EC2 instance"
  type        = string

}

variable "instance_type_worker" {
  description = "Value of the instance type for the K3s Worker EC2 instance"
  type        = string

}

variable "key_name" {
  description = "key pair name for the EC2 instance"
  type        = string

}


variable "master_tag" {
  description = "Value of the tag for the master EC2 instance"
  type        = string

}

variable "master_iam_role" {
  description = "Master IAM role name for the Master EC2 instance"
  type        = string

}

variable "worker_tag" {
  description = "Value of tag for the worker EC2 instance"
  type        = string

}
variable "worker_iam_role" {
  description = "Worker IAM Role name for the worker EC2 instance"
  type        = string

}


variable "access_key" {
  description = "Value of the access key of AWS account"
  type        = string

}

variable "secret_key" {
  description = "Value of the secret key of AWS account"
  type        = string

}

variable "master_policy_name" {
  description = "Name of IAM Role Policy"
  type        = string
}

variable "master_json_policy_path" {
  description = "JSON policy path"
  type        = string
}

variable "worker_policy_name" {
  description = "Name of IAM Role Policy"
  type        = string
}

variable "worker_json_policy_path" {
  description = "JSON policy path"
  type        = string
}


variable "worker_count" {
  description = "Number of worker nodes"
  type        = string
}
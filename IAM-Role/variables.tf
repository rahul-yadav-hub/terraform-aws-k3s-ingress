variable "role_name" {
  description = "Name of IAM Role"
  type        = string
}

variable "policy_arn" {
  description = "ARN ID of policy"
  type        = list(string)
}
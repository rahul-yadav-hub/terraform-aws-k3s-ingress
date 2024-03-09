output "VPC_ID" {
  description = "ID of the our VPC"
  value       = aws_vpc.my_vpc.id
}

output "Subnet_IDs" {
  description = "ID of our Public Subnet 1"
  value       = aws_subnet.subnet[*].id
}


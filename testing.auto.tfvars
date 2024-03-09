// General Variables
key_name                 = "Project_AWS_K3S" // Generate a key pair for K3s EC2 Nodes
tag                      = "Project_AWS_K3S"  // General tag value for all resources

// Provider Variables
region                   = "us-east-1"
access_key               = ""                // provide aws acess key here
secret_key               = ""                // provide awd secret key here

// VPC Variables
vpc_name                 = "DEV"
cidr_block_vpc           = "10.0.0.0/16"     // CIDR Range
public_subnet_count      = 1                 // First creates n no. of public subnet
private_subnet_count     = 2

// EC2 Variables

ami_id                   = "ami-06aa3f7caf3a30282" // Ubuntu 20.04 amd64 x86_64
instance_type_master     = "t2.small"
instance_type_worker     = "t2.small"
master_tag               = "K3s-Master"
worker_tag               = "K3s-Worker"
worker_count             = "1"              // Provide number of worker node (As per supported no.)

// Role & Policy Variables
master_policy_name       = "Project_AWS_K3S_Master_Policy"
master_json_policy_path  = "./IAM-Policy/master.json"
worker_policy_name       = "Project_AWS_K3S_Worker_Policy"
worker_json_policy_path  = "./IAM-Policy/worker.json"
master_iam_role          = "Master-Role"
worker_iam_role          = "Worker-Role"
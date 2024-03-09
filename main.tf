terraform {
  required_providers {
    aws = {
      source         =    "hashicorp/aws"
      version        =    "~> 5.38.0" 
    }
  }

  required_version   =    ">= 0.14.9"
}

// Define provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region             =    var.region
}

module "myPolicyMaster" {
  source                =    "./IAM-Policy"
  policy_name           =    var.master_policy_name
  json_policy_path      =    var.master_json_policy_path
}

module "myPolicyWorker" {
  source                =    "./IAM-Policy"
  policy_name           =    var.worker_policy_name
  json_policy_path      =    var.worker_json_policy_path
}

module "myRoleMaster" {
  source                =    "./IAM-Role"
  role_name             =    var.master_iam_role
  policy_arn            =    [module.myPolicyMaster.POLICY_ARN]
}

module "myRoleWorker" {
  source                =    "./IAM-Role"
  role_name             =    var.worker_iam_role
  policy_arn            =    [module.myPolicyWorker.POLICY_ARN]
}


module "myVPC" { 
  source                =    "./VPC"
  vpc_name              =    "${var.vpc_name}-VPC"
  cidr_block_vpc        =    var.cidr_block_vpc
  public_subnet_count   =    var.public_subnet_count
  private_subnet_count  =    var.private_subnet_count
  tag_name              =    "${var.tag}-VPC"
}

module "mySecurity" { 
  source             =    "./Security Group"
  tag                =    "${var.tag}-sg"
  vpc_id             =    module.myVPC.VPC_ID 
}

module "EC2-Master" { 
  depends_on = [
    module.myRoleMaster
  ]
  source              =     "./EC2"
  counts              =     1
  subnet_id           =     "${module.myVPC.Subnet_IDs[0]}"   // (Public) starting n public, ending private subnets
  vpc_id              =     module.myVPC.VPC_ID  
  sg_id               =     ["${module.mySecurity.K3S-SG}"]
  key_name            =     var.key_name
  ami_id              =     var.ami_id
  instance_type       =     var.instance_type_master
  tag                 =     var.master_tag
  iam_role            =     module.master_instance_profile.INSTANCE_PROFILE 
  script_path         =     file("./EC2/master-script.sh")
}

data "template_file" "init" {
  depends_on = [
    module.EC2-Master
  ]
  template = "${file("./EC2/worker-script.sh")}"
  vars = {
    master_ip = "${module.EC2-Master.instance_private_ip}"
  }
}


module "EC2-WorkerAZ1" { 
  depends_on = [
    data.template_file.init,
    module.myRoleWorker
  ]
  source              =     "./EC2"
  counts              =     var.worker_count
  subnet_id           =     "${module.myVPC.Subnet_IDs[1]}" // (Private AZ 1) starting n public subnets, ending private
  vpc_id              =     module.myVPC.VPC_ID  
  sg_id               =     ["${module.mySecurity.K3S-SG}"]
  key_name            =     var.key_name
  ami_id              =     var.ami_id
  instance_type       =     var.instance_type_worker
  tag                 =     var.worker_tag
  iam_role            =     module.worker_instance_profile.INSTANCE_PROFILE 
  script_path         =     data.template_file.init.rendered
}

module "EC2-WorkerAZ2" { 
  depends_on = [
    data.template_file.init,
    module.myRoleWorker
  ]
  source              =     "./EC2"
  counts              =     var.worker_count
  subnet_id           =     "${module.myVPC.Subnet_IDs[2]}" // (Private AZ 2) starting n public subnets, ending private
  vpc_id              =     module.myVPC.VPC_ID  
  sg_id               =     ["${module.mySecurity.K3S-SG}"]
  key_name            =     var.key_name
  ami_id              =     var.ami_id
  instance_type       =     var.instance_type_worker
  tag                 =     var.worker_tag
  iam_role            =     module.worker_instance_profile.INSTANCE_PROFILE 
  script_path         =     data.template_file.init.rendered
}



module "master_instance_profile" {
  source                  = "./Instance-Profile"
  instance_profile_name   = module.myRoleMaster.role-name 
}


module "worker_instance_profile" {
  source                  = "./Instance-Profile"
  instance_profile_name   = module.myRoleWorker.role-name 
}
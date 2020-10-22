# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# sandbox/hyperscience-alb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  required_version = ">= 0.12.26"
}
provider "aws" {
  version = "~> 3.0"
  region  = var.region
}

##############################
# get state of sandbox/app-vpc
##############################
data "terraform_remote_state" "tfstate" {
  backend = "s3"
  config = {
    region = var.region
    key    = "app-vpc/terraform.tfstate"
    bucket = "ses-ide-sandb-terraform-state"
  }
}

locals {
  vpc_id                      = data.terraform_remote_state.tfstate.outputs.vpc_id
  public_subnet_ids           = data.terraform_remote_state.tfstate.outputs.public_subnets
  public_subnets_cidr_blocks  = data.terraform_remote_state.tfstate.outputs.public_subnets_cidr_blocks
  private_subnet_ids          = data.terraform_remote_state.tfstate.outputs.private_subnets
  private_subnets_cidr_blocks = data.terraform_remote_state.tfstate.outputs.private_subnets_cidr_blocks
  database_subnets_ids        = data.terraform_remote_state.tfstate.outputs.database_subnets
}

locals {
  hyperscience_data = {
    "${var.name_prefix}-01" = {
      ami           = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-532f1632
      instance_type = "t3.2xlarge",   # 8 vcpu 32gb Ram
      subnet_id     = local.private_subnet_ids[0]
    },
    "${var.name_prefix}-02" = {
      ami           = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-532f1632
      instance_type = "t3.2xlarge",   # 8 vcpu 32gb Ram
      subnet_id     = local.private_subnet_ids[1]
    },
    "${var.name_prefix}-03" = {
      ami           = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-532f1632
      instance_type = "t3.2xlarge",   # 8 vcpu 32gb Ram
      subnet_id     = local.private_subnet_ids[2]
    }
    "${var.name_prefix}-04" = {
      ami           = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-532f1632
      instance_type = "t3.2xlarge",   # 8 vcpu 32gb Ram
      subnet_id     = local.private_subnet_ids[0]
    }
  }
}

locals {
  trainer_data = {
    "${var.name_prefix}-trainer-01" = {
      ami           = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type - ami-532f1632
      instance_type = "c5.4xlarge",   # 16 vcpu 32gb Ram
      subnet_id     = local.private_subnet_ids[0]
    }
  }
}

#############################
# hyperscience-ec2s instances
#############################
module "hyperscience_ec2" {
  source = "../../../modules/ec2"

  instance_data = local.hyperscience_data

  name_prefix          = var.name_prefix
  key_name             = var.key_name
  iam_instance_profile = "ide-sandb-hyperscience01-iam-instance-profile"
  vpc_id               = local.vpc_id # for security group
}
#######################
# trainer-ec2 instances
#######################
module "trainer_ec2" {
  source = "../../../modules/ec2"

  instance_data = local.trainer_data

  name_prefix          = "${var.name_prefix}-trainier"
  key_name             = var.key_name
  iam_instance_profile = "ide-sandb-hyperscience01-iam-instance-profile"
  vpc_id               = local.vpc_id # for security group
}
###########################
# application load balancer
###########################
module "alb" {
  source            = "../../../modules/alb"
  name_prefix       = var.name_prefix
  vpc_id            = local.vpc_id
  instance_ids      = module.hyperscience_ec2.instance_ids
  public_subnet_ids = local.public_subnet_ids
}



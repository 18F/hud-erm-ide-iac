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
# get state data
##############################
data "terraform_remote_state" "hyperscience_s3" {
  backend = "s3"
  config = {
    region = var.region
    key    = "hyperscience-s3/terraform.tfstate"
    bucket = "ses-ide-sandb-terraform-state"
  }
}
locals {
  aws_iam_s3_instance_profile = data.terraform_remote_state.hyperscience_s3.outputs.aws_iam_s3_instance_profile
}

data "terraform_remote_state" "mgmt" {
  backend = "s3"
  config = {
    region = var.region
    key    = "mgmt/terraform.tfstate"
    bucket = "ses-ide-sandb-terraform-state"
  }
}
locals {
  linux_bastion_private_ip = data.terraform_remote_state.mgmt.outputs.linux_bastion_private_ip
}

data "terraform_remote_state" "app_vpc" {
  backend = "s3"
  config = {
    region = var.region
    key    = "app-vpc/terraform.tfstate"
    bucket = "ses-ide-sandb-terraform-state"
  }
}

locals {
  vpc_id                      = data.terraform_remote_state.app_vpc.outputs.vpc_id
  public_subnet_ids           = data.terraform_remote_state.app_vpc.outputs.public_subnets
  public_subnets_cidr_blocks  = data.terraform_remote_state.app_vpc.outputs.public_subnets_cidr_blocks
  private_subnet_ids          = data.terraform_remote_state.app_vpc.outputs.private_subnets
  private_subnets_cidr_blocks = data.terraform_remote_state.app_vpc.outputs.private_subnets_cidr_blocks
  database_subnets_ids        = data.terraform_remote_state.app_vpc.outputs.database_subnets
}

##############################
# setup maps for instance data
##############################
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
# hyperscience-ec2 instances
#############################
module "hyperscience_ec2" {
  # source = "../../../modules/ide-ec2"
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//ide-ec2"

  instance_data = local.hyperscience_data

  name_prefix             = var.name_prefix
  key_name                = var.key_name
  iam_instance_profile    = local.aws_iam_s3_instance_profile 
  vpc_id                  = local.vpc_id                    # for security group
  cidr_blocks_ingress_ssh = ["${local.linux_bastion_private_ip[0]}/32"] 
  root_block_device_size = "100" 
}
########################
# trainer-ec2 instances
########################
module "trainer_ec2" {
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//ide-ec2"

  instance_data = local.trainer_data

  name_prefix             = "${var.name_prefix}-trainier"
  key_name                = var.key_name
  iam_instance_profile    = local.aws_iam_s3_instance_profile 
  vpc_id                  = local.vpc_id                    # for security group
  cidr_blocks_ingress_ssh = ["${local.linux_bastion_private_ip[0]}/32"] 
  root_block_device_size = "100"
}
############################
# application load balancer
############################
module "alb" {
  source            = "git@github.com:18F/hud-erm-ide-iac-modules.git//alb"
  name_prefix       = var.name_prefix
  vpc_id            = local.vpc_id
  instance_ids      = module.hyperscience_ec2.instance_ids
  public_subnet_ids = local.public_subnet_ids
  certificate_arn   = "arn:aws-us-gov:acm:us-gov-west-1:508864297691:certificate/89f91cb7-7a37-4e05-9d29-c78c665ce02a"
}



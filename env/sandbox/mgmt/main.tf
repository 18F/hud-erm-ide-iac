# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# sandbox/mgmt
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
  database_subnets            = data.terraform_remote_state.app_vpc.outputs.database_subnets
}

###############
# Bastion Linux
###############
module "ec2_linux" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"

  name           = "${var.name_prefix}--linux-bastion"
  instance_count = 1

  ami           = "ami-a9b38ac8" # amzn-ami-hvm-2018.03.0.20200918.0-x86_64-gp2 (ami-a9b38ac8)
  instance_type = "t2.medium"   # 

  subnet_id              = local.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.linux_bastion.id]
  key_name              = var.key_pair

  # root_block_device = [
  #   {
  #     volume_size = "50"
  #     volume_type = "gp2"
  #   },
  # ]

  # ebs_block_device = [
  #   {
  #     device_name           = "/dev/xvdz"
  #     volume_type           = "gp2"
  #     volume_size           = "50"
  #     delete_on_termination = true
  #   }
  # ]

  tags = {
    "Env"  = "Private"
    "Name" = "${var.name_prefix}-linux-bastion"
  }
}
###################################
# security group for linux bastions
###################################
resource "aws_security_group" "linux_bastion" {
  name        = "${var.name_prefix}-linux-bastion-sg"
  description = "Allow ssh and rdp connections"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["73.39.184.79/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-bastion-linux-sg"
  }
}
#################
# Bastion Windows
#################
module "ec2_windows" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.15.0"

  name           = "${var.name_prefix}-windows-bastion"
  instance_count = 1

  ami           = "ami-d11c25b0" # Windows_Server-2016-English-Full-Base-2020.09.09 (ami-d11c25b0)
  instance_type = "t3a.medium"   # 

  subnet_id              = local.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.win_bastion.id]
  key_name              = var.key_pair

  tags = {
    "Env"  = "Private"
    "Name" = "${var.name_prefix}--windows-bastion"
  }
}
###################################
# security group for windows bastions
###################################
resource "aws_security_group" "win_bastion" {
  name        = "${var.name_prefix}-win-bastion-sg"
  description = "Allow ssh and rdp connections"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["73.39.184.79/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-bastion-win-sg"
  }
}

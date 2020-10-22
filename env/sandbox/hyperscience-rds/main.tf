# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# sandbox/hyperscience-rds
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
####################################
# security group for Agency Postgres
####################################
resource "aws_security_group" "postgres-sg" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow ssh from bastion and private subnets and TLS over 5432"
  vpc_id      = local.vpc_id

  ingress {
    description = "TLS from VPC private subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.private_subnets_cidr_blocks
  }
  ingress {
    description = "TLS from Bastions"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.20.1.171/32", "10.20.1.97/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-rds-sg"
  }
}
####################################
# Variables common to both instanceces
####################################
locals {
  engine            = "postgres"
  engine_version    = "9.5.22"
  instance_class    = "db.t2.2xlarge"
  allocated_storage = 100
  port              = "5432"
}
###########
# Master DB
###########
module "master" {
  source  = "terraform-aws-modules/rds/aws"
  version = "2.20.0"

  ca_cert_identifier = "rds-ca-2017"

  identifier = "${var.name_prefix}-master-postgres"

  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage

  name     = "hyperscience"
  username = var.db_username
  password = var.db_password
  port     = local.port
  multi_az = true

  vpc_security_group_ids = [aws_security_group.postgres-sg.id]
  subnet_ids             = local.database_subnets_ids

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # Backups are required in order to create a replica
  backup_retention_period = 7

  create_db_option_group    = false
  create_db_parameter_group = false
}
############
# Replica DB
############
module "replica" {
  source             = "terraform-aws-modules/rds/aws"
  ca_cert_identifier = "rds-ca-2017"

  identifier = "${var.name_prefix}-replica-postgres"

  # Source database. For cross-region use this_db_instance_arn
  replicate_source_db = module.master.this_db_instance_id

  engine            = local.engine
  engine_version    = local.engine_version
  instance_class    = local.instance_class
  allocated_storage = local.allocated_storage

  # Username and password must not be set for replicas
  username = ""
  password = ""
  port     = local.port

  vpc_security_group_ids = [aws_security_group.postgres-sg.id]

  maintenance_window = "Tue:00:00-Tue:03:00"
  backup_window      = "03:00-06:00"

  # disable backups to create DB faster
  backup_retention_period = 0

  # Not allowed to specify a subnet group for replicas in the same region
  create_db_subnet_group = false

  create_db_option_group    = false
  create_db_parameter_group = false
}

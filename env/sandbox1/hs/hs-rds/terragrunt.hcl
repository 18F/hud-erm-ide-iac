locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"
  region  = local.region_vars.locals.aws_region
}

## MODULE
terraform {
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//rds-postgres"
}

include {
  path = find_in_parent_folders()
}

# dependencies
dependencies { paths = ["../hs-vpc/"] }
dependency "vpc" { config_path = "../hs-vpc/" }
dependency "mgmt-hosts" { config_path = "../../../sandbox2/mgmt/mgmt-hosts/" }



## MAIN
inputs = {
  ca_cert_identifier = "rds-ca-2017"
  name_prefix        = "${local.name_prefix}-hyperscience-rds"

  engine            = "postgres"
  engine_version    = "10.13"
  instance_class    = "db.t2.xlarge"
  allocated_storage = 50 # in GBs

  database_name = "hyperscience"
  db_username   = get_env("TF_VAR_db_username") # get from env variables TF_VAR_db_username
  db_password   = get_env("TF_VAR_db_password") # get from env variables TF_VAR_db_password
  db_port       = "5432"
  multi_az      = true

  database_subnet_ids             = dependency.vpc.outputs.database_subnet_ids

  # for security group
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnets_cidr_blocks = dependency.vpc.outputs.private_subnets_cidr_blocks
  
  mgmt_subnet_cidr_blocks = [
    "${dependency.mgmt-hosts.outputs.linux_bastion_private_ip[0]}/32", 
    "10.1.0.0/16"
  ]
}
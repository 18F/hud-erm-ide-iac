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
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//microservice-eks"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies
dependencies { paths = ["../../hs/hs-vpc"] }
dependency "vpc" { config_path = "../../hs/hs-vpc" }



# MAIN
inputs = {
  name_prefix  = "${local.name_prefix}"
  cluster_name  = "${local.name_prefix}-microservice-eks"
  
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnet_ids = dependency.vpc.outputs.private_subnet_ids
  key_name = "ses-ide-sandb-bastion"
  
  ssh_ingress_cidr_blocks = [      
    "10.1.0.0/16", # mgmt vpc
    "10.30.0.0/16", # local vpc traffic
  ]

  map_users = [
    {
      userarn  = "arn:aws-us-gov:iam::508864297691:user/test.user"
      username = "test.user"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws-us-gov:iam::508864297691:user/rajagopal.Allam"
      username = "rajagopal.Allam"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws-us-gov:iam::508864297691:user/amit.sharma"
      username = "amit.sharma"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws-us-gov:iam::508864297691:user/michael.jones-ermide-sandbox"
      username = "michael.jones-ermide-sandbox"
      groups   = ["system:masters"]
    },
  ]

  map_roles = [
    {
      rolearn  = "arn:aws-us-gov:iam::508864297691:role/eksClusterRole"
      username = "eksClusterRole"
      groups   = ["system:masters"]
    },
  ]

}

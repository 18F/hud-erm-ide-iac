locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"
}

terraform {
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//app-vpc"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name_prefix = "${local.name_prefix}-hs-vpc"
  vpc_cidr = "10.10.0.0/16"
  single_nat_gateway = true # set to false for one NAT gateway per subnet
}

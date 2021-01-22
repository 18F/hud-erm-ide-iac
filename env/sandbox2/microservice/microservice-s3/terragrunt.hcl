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
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//microservice-s3"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

# dependencies


# MAIN
inputs = {
  name_prefix  = "${local.name_prefix}"
}
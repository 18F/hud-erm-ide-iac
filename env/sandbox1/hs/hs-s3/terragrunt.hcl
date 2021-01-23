locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"
}

terraform {
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//hs-s3"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

## MAIN
inputs = {
  name_prefix = "${local.name_prefix}"
}

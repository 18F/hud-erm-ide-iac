# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account_name   = "tfuser-ermide-sandb"
  aws_account_id = "508864297691" # TODO: replace me with your AWS account ID!
  aws_profile    = "tfuser-ermide-sandb"
}
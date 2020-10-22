# sandbox/terragrunt.hcl
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "ses-ide-sandb-terraform-state"

    key = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-gov-west-1"
    encrypt        = true
    dynamodb_table = "ses-ide-sandb-terraform-state-locks"
  }
}
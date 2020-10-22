# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# sandbox/app-vpc
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  required_version = ">= 0.12.26"
}
provider "aws" {
  version = "~> 3.0"
  region  = var.region
}



module "app_vpc" {
  source = "../../../modules/app-vpc"

  appname_construct = "ide-sandb-app-vpc"
  vpc_cidr          = "10.20.0.0/16"
  azs               = ["us-gov-west-1a", "us-gov-west-1b", "us-gov-west-1c"]
  public_subnets    = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
  private_subnets   = ["10.20.11.0/24", "10.20.12.0/24", "10.20.13.0/24"]
  database_subnets  = ["10.20.21.0/24", "10.20.22.0/24", "10.20.23.0/24"]
}





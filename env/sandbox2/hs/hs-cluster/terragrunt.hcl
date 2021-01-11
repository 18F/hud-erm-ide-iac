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
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//hs-cluster"
}

include {
  path = find_in_parent_folders()
}

# dependencies
dependencies { paths = ["../hs-vpc/", "../hs-s3/"] }
dependency "vpc" { config_path = "../hs-vpc/" }
dependency "hs-s3" { config_path = "../hs-s3/" }
dependency "mgmt-hosts" { config_path = "../../mgmt/mgmt-hosts/" }



## MAIN
inputs = {
  name_prefix           = "${local.name_prefix}-hs-cluster"

  image_id              = "ami-0e9ca78385a9b4759" # custom AMI hyperscience-28.0.8
  # image_id              = "ami-532f1632", # Ubuntu Server 18.04 LTS (HVM), SSD Volume Type


  instance_type         = "t3.2xlarge",   # 8 vcpu 32gb Ram
  key_name              = "ses-ide-sandb-bastion"
  iam_instance_profile  = dependency.hs-s3.outputs.aws_iam_s3_instance_profile
  private_subnet_ids    = dependency.vpc.outputs.private_subnet_ids

  public_subnet_ids    = dependency.vpc.outputs.public_subnet_ids

  user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" $HOSTNAME > index.html
        nohup busybox httpd -f -p 80 &
        EOF

#   user_data = <<-EOF
# #!/bin/bash
# sudo mount /tmp -o remount,exec
# sudo bash cd /opt/hs/hyperscience-trainer-28.0.8
# sudo bash run.sh init     
# sudo bash run.sh         
#         EOF

  # for security group
  vpc_id                = dependency.vpc.outputs.vpc_id
  cidr_blocks_ingress_ssh = [
    "${dependency.mgmt-hosts.outputs.linux_bastion_private_ip[0]}/32", 
    "10.1.0.0/16"
  ]
}
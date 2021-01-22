locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env         = local.environment_vars.locals.environment
  project     = local.environment_vars.locals.project
  name_prefix = "${local.project}-${local.env}"
  region  = local.region_vars.locals.aws_region
}

## MODULE
terraform {
  source = "git@github.com:18F/hud-erm-ide-iac-modules.git//hs-cluster-alb"
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
  image_id              = "ami-00b71c90f6df521da" # custom AMI hs-28.0.8

  instance_type         = "t3.2xlarge",   # 8 vcpu 32gb Ram
  key_name              = "ses-ide-sandb-bastion"
  iam_instance_profile  = dependency.hs-s3.outputs.aws_iam_s3_instance_profile
  private_subnet_ids    = dependency.vpc.outputs.private_subnet_ids
  public_subnet_ids    = dependency.vpc.outputs.public_subnet_ids
  
  min_size = 3
  max_size = 10
  desired_capacity = 3

  # user_data = <<-EOF
  #       #!/bin/bash
  #       echo "Hello, World" $HOSTNAME > index.html
  #       nohup busybox httpd -f -p 80 &
  #       EOF

  user_data = <<-EOF
#!/bin/bash
sudo mount /tmp -o remount,exec
sudo ufw allow 80
sudo su
cd /opt/hs/hyperscience-trainer-28.0.8
./run.sh init     
./run.sh         
        EOF

  ## security groups
  vpc_id                = dependency.vpc.outputs.vpc_id
  cidr_blocks_ingress_ssh = [
    "${dependency.mgmt-hosts.outputs.linux_bastion_private_ip[0]}/32", 
    "10.1.0.0/16"
  ]
  cidr_blocks_ingress_http = dependency.vpc.outputs.private_subnets_cidr_blocks

  certificate_arn   = "arn:aws-us-gov:acm:us-gov-west-1:508864297691:certificate/9722b24c-f53a-4c9a-9040-91cdb070a853"

  ## hs trainer
  trainer_image_id = "ami-0aed131facd2fcd22" # custom AMI hs-trainer-28.0.8
  trainer_instance_type = "c5.4xlarge" # 16 vcpu 32gb Ram 
   
  trainer_user_data = <<-EOF
    #!/bin/bash
    sudo su
    mount /tmp -o remount,exec
    ufw allow 80
    cd /opt/hs/hyperscience-trainer-28.0.8
    rm .env
    touch .env
    mkdir -p /mnt/hs/media
            EOF
}
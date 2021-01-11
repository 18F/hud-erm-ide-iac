# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# sandbox/temp-microservice
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
terraform {
  required_version = ">= 0.12.26"
}
provider "aws" {
  version = "~> 3.0"
  region  = var.region
}

##############################
# get state of sandbox/app-vpc
##############################
data "terraform_remote_state" "app_vpc" {
  backend = "s3"
  config = {
    region = var.region
    key    = "app-vpc/terraform.tfstate"
    bucket = "ses-ide-sandb-terraform-state"
  }
}

locals {
  vpc_id                      = data.terraform_remote_state.app_vpc.outputs.vpc_id
  public_subnet_ids           = data.terraform_remote_state.app_vpc.outputs.public_subnets
  public_subnets_cidr_blocks  = data.terraform_remote_state.app_vpc.outputs.public_subnets_cidr_blocks
  private_subnet_ids          = data.terraform_remote_state.app_vpc.outputs.private_subnets
  private_subnets_cidr_blocks = data.terraform_remote_state.app_vpc.outputs.private_subnets_cidr_blocks
  database_subnets            = data.terraform_remote_state.app_vpc.outputs.database_subnets
}
#####################################
# s3 policiy, role & instance profile
#####################################
resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "${var.name_prefix}-s3-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "policy" {
  name        = "${var.name_prefix}-bucket-policy"
  description = "A test policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketMultipartUploads",
                "s3:ListBucket"
            ],
            "Resource": [
                "${module.s3_bucket.this_s3_bucket_arn}"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:AbortMultipartUpload"
            ],
            "Resource": [
                "${module.s3_bucket.this_s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "${var.name_prefix}-bucket-attachment"
  roles      = ["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "test_profile" {
  name = "${var.name_prefix}-iam-s3-instance-profile"
  role = "${aws_iam_role.ec2_s3_access_role.name}"
}
############
# s3 Bucket
############
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.name_prefix}-bucket"
  acl    = "private"

  versioning = {
    enabled = false
  }
}

###########################
# ec2 for temp-microservice
###########################
module "my_ec2" {
  source = "../../../modules/ec2"

  instance_data = {
    "${var.name_prefix}-ec2-01" = {
      ami           = "ami-8684bce7", # Amazon Linux 2 AMI (HVM), SSD Volume Type
      instance_type = "t2.xlarge",   # 4 vcpu 16gb Ram
      subnet_id     = local.public_subnet_ids[0]
    },
    "${var.name_prefix}-ec2-02" = {
      ami           = "ami-8684bce7", # Amazon Linux 2 AMI (HVM), SSD Volume Type - ami-8684bce7
      instance_type = "t2.medium",   # 2 vcpu 4gb Ram
      subnet_id     = local.public_subnet_ids[1]
    }
  }
  

  key_name                = var.key_name
  vpc_security_group_ids      = [aws_security_group.allow_http_ssh.id]
  iam_instance_profile    = aws_iam_instance_profile.test_profile.id
  #root_block_device_size = "100" 
}

##############################
# security group for ec2
##############################
resource "aws_security_group" "allow_http_ssh" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Allow HTTP and ssh inbound connections"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["173.66.219.96/32","73.129.7.91/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-ec2-sg"
  }
}

####################################
# ECR Container Registry
####################################

resource "aws_ecr_repository" "default" {
  name                 = "${var.name_prefix}/ms"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

####################################
# EKS Cluster
####################################

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_availability_zones" "available" {
# }

# resource "aws_security_group" "worker_group_mgmt_one" {
#   name_prefix = "worker_group_mgmt_one"
#   vpc_id      = local.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = ["10.20.1.77/32"]
#   }
#   tags = { Name = "${var.name_prefix}-worker_group_mgmt"}
# }

# resource "aws_security_group" "all_worker_mgmt" {
#   name_prefix = "all_worker_management"
#   vpc_id      = local.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = ["10.20.1.77/32"]
#   }
#   tags = { Name = "${var.name_prefix}-all_worker_mgmt"}
# }

# module "eks" {
#   source       = "terraform-aws-modules/eks/aws"
#   version       = "13.2.1"
#   cluster_name    = "${var.name_prefix}-eks"
#   cluster_version = "1.17"

#   vpc_id          = local.vpc_id
#   subnets         = local.private_subnet_ids
  
#   cluster_create_timeout = "1h"
#   cluster_endpoint_private_access = true 

#   worker_groups = [
#     {
#       name                          = "worker-group-1"
#       instance_type                 = "t3.large"
#       additional_userdata           = "echo foo bar"
#       asg_desired_capacity          = 3
#       key_name                      = var.key_name
#       additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
#     },
#   ]

#   worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]
#   map_roles                            = [
#     {
#       rolearn  = "arn:aws-us-gov:iam::508864297691:role/eksClusterRole"
#       username = "eksClusterRole"
#       groups   = ["system:masters"]
#     },
#   ]
#   map_users  =  [
#     {
#       userarn  = "arn:aws-us-gov:iam::508864297691:user/amit.sharma"
#       username = "amit.sharma"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws-us-gov:iam::508864297691:user/rajagopal.Allam"
#       username = "rajagopal.Allam"
#       groups   = ["system:masters"]
#     },
#   ]
#   # map_accounts                         = []

#   write_kubeconfig   = true
#   config_output_path = "./"
# }
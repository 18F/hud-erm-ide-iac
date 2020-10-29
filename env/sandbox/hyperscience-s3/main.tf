# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# sandbox/hyperscience-s3
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
    enabled = true
  }
}

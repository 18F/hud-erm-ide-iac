# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# variables for modules/web-cluster
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# required
variable "vpc_id" {
  type        = string
  description = "ID of vpc to place cluster"
}
variable "public_subnet_ids" {
  type    = list(string)
}
variable "private_subnet_ids" {
  type    = list(string)
}
variable "image_id" {
  type        = string
  description = "AMI id of instance"
}
variable "instance_type" {
  type        = string
  description = "e.g. t2.micro"
}

# optional
variable "name_prefix" {
  type        = string
  description = "Used for overall naming of resources"
  default     = "ide-sandb-hyperscience"
}
variable "key_pair" {
  type        = string
  description = "Key pair added to all created instances"
  default     = "ses-ide-sandb-bastion"
}
# variable "root_block_device" {
#   type        = map(string)
#   description = "optional - specify details of root block ebs device"
#   default = {
#     volume_size = "50"
#     volume_type = "gp2"
#   }
# }
# variable "ebs_block_device" {
#   type        = map(string)
#   description = "optional - specify details of additional ebs block device"
#   default = {
#     device_name           = "/dev/xvdz"
#     volume_type           = "gp2"
#     volume_size           = "50"
#     delete_on_termination = true
#   } 
# }
variable "asg_min_size" {
  type        = number
  description = "auto scaling group min size"
  default = "2"
}
variable "asg_max_size" {
  type        = number
  description = "auto scaling group max size"
  default = "2"
}
variable "asg_desired_capacity" {
  type        = number
  description = "auto scaling group desired_capacity size"
  default = "2"
}
variable "web_ingress_ssh_cidr" {
  type        = list(string)
  description = "cidr blocks for ssh access to instances"
  default = ["73.39.184.79/32"]
}









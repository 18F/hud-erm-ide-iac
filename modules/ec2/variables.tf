# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# varialbles for module ide-ec2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "instance_data" {}
variable "name_prefix" {}
variable "key_name" {}
variable "vpc_id" {}


# variable "ami" {}
# variable "instance_type" {}
# variable "subnet_id" {}

variable "iam_instance_profile" {
  description = "iam instance profile name"
  default     = ""
}
variable "root_block_device_size" {
  default = "50"
}

variable "cidr_blocks_ingress_ssh" {
  type        = list(string)
  description = "ssh ingress from mgmt hosts"
  default     = ["10.20.1.171/32"]
}





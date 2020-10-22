# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# variables for sandbox/hyperscience
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
variable "region" {
  type    = string
  default = "us-gov-west-1"
}

variable "name_prefix" {
  type        = string
  description = "Used for overall naming of resources"
  default     = "ide-sandb-hyperscience01"
}

variable "key_pair" {
  type        = string
  description = "Key pair added to all created instances"
  default     = "ses-ide-sandb-bastion"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# variables for sandbox/microservice-rds
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# variable "region" {
#   type    = string
#   default = "us-gov-west-1"
# }

# variable "env" {
#   type    = string
#   default = "dev"
# }


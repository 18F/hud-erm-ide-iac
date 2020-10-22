# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# outputs for sandbox/app-vpc
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# vpc
output "vpc_id" {
  description = "The ID of the vpc"
  value       = module.app_vpc.vpc_id
}

# Subnets
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.app_vpc.public_subnets
}
output "public_subnets_cidr_blocks" {
  description = "List of cidr blocks for public subnets"
  value       = module.app_vpc.public_subnets_cidr_blocks
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.app_vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr blocks for private subnets"
  value       = module.app_vpc.private_subnets_cidr_blocks
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.app_vpc.database_subnets
}
output "database_subnets_cidr_blocks" {
  description = "List of cidr blocks for database subnets"
  value       = module.app_vpc.database_subnets_cidr_blocks
}


# NAT gateways
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.app_vpc.nat_public_ips
}

# app_vpc endpoints
output "app_vpc_endpoint_s3_id" {
  description = "The ID of app_vpc endpoint for S3"
  value       = module.app_vpc.vpc_endpoint_s3_id
}

##############
# Network ACLs
##############
output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = module.app_vpc.default_network_acl_id
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = module.app_vpc.public_network_acl_id
}
output "public_network_acl_arn" {
  description = "ARN of the public network ACL"
  value       = module.app_vpc.public_network_acl_arn
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = module.app_vpc.private_network_acl_id
}
output "private_network_acl_arn" {
  description = "ARN of the private network ACL"
  value       = module.app_vpc.private_network_acl_arn
}

output "database_network_acl_id" {
  description = "ID of the database network ACL"
  value       = module.app_vpc.database_network_acl_id
}
output "database_network_acl_arn" {
  description = "ARN of the database network ACL"
  value       = module.app_vpc.database_network_acl_arn
}

output "module_vpc" {
  description = "Module VPC"
  value       = module.app_vpc
}


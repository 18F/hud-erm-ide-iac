# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# outputs for sandbox/hyperscience-alb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "all_instance_data" {
  value = module.hyperscience_ec2.all_instance_data
}

output "web_sg_id" {
  value = module.hyperscience_ec2.web_sg_id
}

output "instance_ids" {
  value = module.hyperscience_ec2.instance_ids
}

# output "lb_dns_name" {
#   value = module.my_alb.dns_name
# }


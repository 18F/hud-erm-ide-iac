# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# outputs for modules/web-cluster
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
output "elb_dns_name" {
  value = aws_elb.web_elb.dns_name
}

output "web_sg_id" {
  value = aws_security_group.allow_http_ssh.id
}

output "elb_sg_id" {
  value = aws_security_group.allow_http_https.id
}

# # Launch configuration
# output "this_launch_configuration_id" {
#   description = "The ID of the launch configuration"
#   value       = module.hyperscience_asg.this_launch_configuration_id
# }

# # Autoscaling group
# output "this_autoscaling_group_id" {
#   description = "The autoscaling group id"
#   value       = module.hyperscience_asg.this_autoscaling_group_id
# }

# # ELB DNS name
# output "this_elb_dns_name" {
#   description = "DNS Name of the ELB"
#   value       = module.elb.this_elb_dns_name
# }
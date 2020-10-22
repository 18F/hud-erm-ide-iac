# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# outputs for sandbox/mgmt
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
output "arn_linux_bastion" {
  value = module.ec2_linux.arn
}

output "arn_windows_bastion" {
  value = module.ec2_windows.arn
}


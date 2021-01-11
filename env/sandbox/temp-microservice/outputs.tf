# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# outputs for sandbox/temp-microservice
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
output "s3_arn" {
  value = module.s3_bucket.this_s3_bucket_arn
}

output "aws_iam_s3_instance_profile" {
  value = aws_iam_instance_profile.test_profile.name
}

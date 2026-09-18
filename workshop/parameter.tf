data "aws_ssm_parameter" "environment" {
  name = "/tf-shop/environment"
}

output "environment_from_parameter_store" {
  description = "Environment read from AWS SSM Parameter Store"
  value       = data.aws_ssm_parameter.environment.value
  sensitive   = true
}

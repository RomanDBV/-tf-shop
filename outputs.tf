# outputs.tf
output "public_ip" {
  value = aws_instance.web.public_ip
}

output "url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "subnet_ids" {
  value = module.network.subnet_ids
}


output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = {
    for k, s in aws_subnet.net :
    k => s.id
  }
}

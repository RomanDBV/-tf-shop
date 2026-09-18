output "bucket_name" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "policy_id" {
  description = "ID of the S3 bucket policy"
  value       = length(aws_s3_bucket_policy.read) > 0 ? aws_s3_bucket_policy.read[0].id : null
}

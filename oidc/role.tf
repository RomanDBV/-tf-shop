resource "aws_iam_role" "tfc" {
  name = "hcp-terraform-dev"

  assume_role_policy = data.aws_iam_policy_document.trust.json

  tags = {
    ManagedBy = "terraform"
    Project   = "tf-shop"
    Env       = "dev"
  }
}

output "role_arn" {
  value = aws_iam_role.tfc.arn
}


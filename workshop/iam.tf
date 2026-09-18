# Trust policy для EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM role для EC2
resource "aws_iam_role" "ec2_s3_read" {
  name = "workshop-ec2-s3-read-${terraform.workspace}"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Environment = terraform.workspace
  }
}



# Instance Profile для майбутньої EC2
resource "aws_iam_instance_profile" "ec2" {
  name = "workshop-ec2-profile-${terraform.workspace}"
  role = aws_iam_role.ec2_s3_read.name
}

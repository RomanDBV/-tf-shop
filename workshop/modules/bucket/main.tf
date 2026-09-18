resource "aws_s3_bucket" "this" {
  bucket = var.name_prefix

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

data "aws_iam_policy_document" "read" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.reader_arns
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.this.arn
    ]
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.reader_arns
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "read" {
  count = length(var.reader_arns) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.read.json
}

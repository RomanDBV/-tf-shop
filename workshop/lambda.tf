data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "lambda_s3_read" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${module.bucket.bucket_arn}/${aws_s3_object.hello.key}"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_s3_read" {
  name   = "${local.name_prefix}-lambda-s3-read"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_s3_read.json
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_lambda_function" "s3_reader" {
  function_name = "${local.name_prefix}-s3-reader"
  role          = aws_iam_role.lambda.arn

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  environment {
    variables = {
      BUCKET_NAME = module.bucket.bucket_name
      OBJECT_KEY  = aws_s3_object.hello.key
    }
  }

  # Lambda runs in private subnets. These subnets have no direct route to
  # the Internet Gateway, so the function loses direct Internet access.
  # In production, outbound Internet access is usually provided through
  # a NAT Gateway/NAT instance. For private access to supported AWS
  # services, VPC Endpoints/PrivateLink can be used instead of the Internet.


  vpc_config {
    subnet_ids = [
      module.network.subnet_ids["private-b"],
      module.network.subnet_ids["private-c"]
    ]

    security_group_ids = [
      aws_security_group.lambda.id
    ]
  }
  tags = local.common_tags
}

resource "aws_lambda_function_url" "s3_reader" {
  function_name      = aws_lambda_function.s3_reader.function_name
  authorization_type = "NONE"
}

output "lambda_url" {
  description = "Public URL for the S3 reader Lambda"
  value       = aws_lambda_function_url.s3_reader.function_url
}

resource "aws_security_group" "lambda" {
  name        = "${local.name_prefix}-lambda"
  description = "Security group for Lambda in VPC"
  vpc_id      = module.network.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-lambda"
  })
}

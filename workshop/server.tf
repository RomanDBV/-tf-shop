data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_security_group" "web" {
  name   = "${var.project}-sg"
  vpc_id = module.network.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_ports

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-sg"
  })
}

resource "aws_instance" "web" {
  ami                    = "ami-030f85e68f5db92a9"
  instance_type          = "t3.micro"
  subnet_id              = module.network.subnet_ids["public-a"]
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  key_name = "shop-key"

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    bucket_name = module.bucket.bucket_name
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-server"
  })

  lifecycle {
    ignore_changes = [tags["ExternalAutomation"]]
  }
}



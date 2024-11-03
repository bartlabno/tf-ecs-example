resource "aws_security_group" "allow_https" {
  name   = "${var.project}-${var.environment}-allow-https"
  vpc_id = module.vpc-react.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allow_cidr]
  }
}

resource "aws_security_group" "allow_internal" {
  name   = "${var.project}-${var.environment}-allow-internal"
  vpc_id = module.vpc-react.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.block_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.block_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
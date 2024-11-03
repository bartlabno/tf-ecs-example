data "aws_region" "current" {}

locals {
  subnets = cidrsubnets(var.block_cidr, 8, 8, 8, 8, 8, 8)
  azs     = formatlist("${data.aws_region.current.name}%s", ["a", "b"])
}

module "vpc-react" {
  source           = "terraform-aws-modules/vpc/aws"
  name             = "${var.project}-${var.environment}"
  azs              = local.azs
  cidr             = var.block_cidr
  database_subnets = [local.subnets[0], local.subnets[1]]
  private_subnets  = [local.subnets[2], local.subnets[3]]
  public_subnets   = [local.subnets[4], local.subnets[5]]

  enable_nat_gateway = true
}
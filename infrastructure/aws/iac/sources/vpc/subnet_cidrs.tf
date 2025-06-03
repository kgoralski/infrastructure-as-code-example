locals {
  public_subnet_cidrs  = null_resource.public_subnet_cidrs.*.triggers.cidr_block
  private_subnet_cidrs = null_resource.private_subnet_cidrs.*.triggers.cidr_block
}

resource "null_resource" "public_subnet_cidrs" {
  count = length(var.azs)

  triggers = {
    cidr_block = cidrsubnet(cidrsubnet(var.vpc_cidr, 2, 3), length(var.azs), count.index)
  }
}

resource "null_resource" "private_subnet_cidrs" {
  count = length(var.azs)

  triggers = {
    cidr_block = cidrsubnet(var.vpc_cidr, 2, count.index)
  }
}

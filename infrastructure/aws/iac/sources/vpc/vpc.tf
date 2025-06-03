module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                  = "${var.base_name}-main-vpc"
  cidr                  = var.vpc_cidr
  secondary_cidr_blocks = var.vpc_secondary_cidr


  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  map_public_ip_on_launch   = true

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  reuse_nat_ips          = true                    # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids    = aws_eip.nat.*.id        # <= IPs specified here as input to the module
  enable_vpn_gateway     = true
  enable_dns_hostnames   = true
  enable_dns_support     = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  tags = merge(
    var.tags,
    {
      Name = "${var.base_name}-main-vpc"
    }
  )
  vpc_tags = var.tags
}
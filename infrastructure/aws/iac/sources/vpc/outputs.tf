output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "public_subnet_cidrs" {
  value = local.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = local.private_subnet_cidrs
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "database_route_table_ids" {
  value = module.vpc.database_route_table_ids
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cidr" {
  value = var.vpc_cidr
}


output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_ids
}

output "azs" {
  value = module.vpc.azs
}


output "vgw_id" {
  value = module.vpc.vgw_id
}

output "vpc_sg_id" {
  value = module.vpc.default_security_group_id
}

output "vpc_database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}
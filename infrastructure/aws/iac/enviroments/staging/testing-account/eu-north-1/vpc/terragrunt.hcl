terraform {
  source = "../../../../../sources//vpc"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars      = yamldecode(file("${get_parent_terragrunt_dir()}/common_vars.yaml"))

  account_name = local.account_vars.locals.account_name
  aws_region   = local.region_vars.locals.aws_region
  environment  = local.environment_vars.locals.environment

  tags = merge(
    local.common_vars.tags,
    {
      "environment" : local.environment,
      "account_name" : local.account_name
    }
  )

}

# Amazon Virtual Private Cloud (VPC) gives you full control over your virtual
# networking environment, including resource placement, connectivity, and security.
inputs = {
  base_name = "${local.environment}-${local.account_name}-${local.aws_region}"
  tags      = local.tags
  region    = local.aws_region
}

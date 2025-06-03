terraform {
  source ="../../../../../sources//ecr"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars      = yamldecode(file("${get_parent_terragrunt_dir()}/common_vars.yaml"))
  ecrs             = yamldecode(file("../../global/ecr/ecrs.yaml"))

  account_name = local.account_vars.locals.account_name
  aws_region   = local.region_vars.locals.aws_region
  environment  = local.environment_vars.locals.environment

  tags = merge(
    local.common_vars.tags,
    {
      "environment" : local.environment
    }
  )
}

inputs = {
  tags         = local.tags
  repositories = local.ecrs
}

terraform {
  source = "../../../../../sources//eks"
}

dependency "vpc" {
  config_path = "../vpc"
}

include "root" {
  path = find_in_parent_folders()
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  common_vars      = yamldecode(file("${get_parent_terragrunt_dir()}/common_vars.yaml"))

  aws_account_id       = local.account_vars.locals.aws_account_id
  account_name         = local.account_vars.locals.account_name
  aws_region           = local.region_vars.locals.aws_region
  azs                  = local.region_vars.locals.azs
  environment          = local.environment_vars.locals.environment
  env_code             = local.environment_vars.locals.env_code

  tags = merge(
    local.common_vars.tags,
    {
      "environment" : local.environment,
      "account_name" : local.account_name
    }
  )

}

inputs = {
  cluster_name = "mycompany-01"
  cluster_type = "apps"

  env_code                  = local.env_code
  account_name              = local.account_name
  region                    = local.aws_region
  aws_account_id            = local.aws_account_id
  azs                       = local.azs
  vpc_id                    = dependency.vpc.outputs.vpc_id
  public_subnets            = dependency.vpc.outputs.public_subnets
  private_subnets           = dependency.vpc.outputs.private_subnets

  auth_provider_k8s_iam_role = "arn:aws:iam::${local.aws_account_id}:role/TerragruntDeploymentRole"
  auth_external_id           = "${get_env("EXTERNAL_ID", "Name of your best friend?")}"

  tags      = local.tags

}

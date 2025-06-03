locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  account_name          = local.account_vars.locals.account_name
  account_id            = local.account_vars.locals.aws_account_id
  environment           = local.environment_vars.locals.environment
  aws_region            = local.region_vars.locals.aws_region
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = "~> 1.3.7"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    http = {
      source  = "terraform-aws-modules/http"
      version = "2.4.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.13.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.13.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"
  allowed_account_ids = ["${local.account_id}"]
  assume_role {
      role_arn="arn:aws:iam::${local.account_id}:role/TerragruntDeploymentRole"
      external_id="${get_env("EXTERNAL_ID")}"
  }
}
EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${get_env("TG_BUCKET_PREFIX", "main")}-${local.environment}-iac-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Terragrunt will automatically retry the underlying Terraform commands if it fails
# You can configure custom errors to retry in the retryable_errors list
# and you can specify how ofter the retries occur
retry_max_attempts       = 10
retry_sleep_interval_sec = 60
retryable_errors = [
  "(?s).*Error installing provider.*tcp.*connection reset by peer.*",
  "(?s).*ssh_exchange_identification.*Connection closed by remote host.*",
  "(?s)Error: Failed to download module.*",
  "(?s).*read tcp .* read: connection reset by.*"
]

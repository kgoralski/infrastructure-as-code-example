locals {
  aws_region = "eu-north-1"
  azs        = ["private-a", "private-b", "private-c"]

  base_domain                 = "eu-north-1.aws.clickhouse.cloud"

  ecr_repository_url = "111729354111.dkr.ecr.eu-north-1.amazonaws.com"

  client_vpn_server_certificate_arn = ""
}

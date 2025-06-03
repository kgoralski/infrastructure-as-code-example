locals {
  irsa_provider_url   = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  irsa_annotation_key = "eks.amazonaws.com/role-arn"

  cluster_name = "${var.env_code}-${var.cluster_name}-${data.aws_region.current.name}-${var.cluster_type}"

  kubernetes_terraform_user = "terraform"


  default_map_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TerragruntDeploymentRole"
      username = "{{SessionName}}"
      groups   = ["system:authenticated", "system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKSAdminRole"
      username = "{{SessionName}}"
      groups   = ["system:authenticated", "system:masters"]
    },
  ]

  default_map_users = [
    {
      userarn  = "arn:aws:iam::111729354111:user/kgoralski"
      username = "kgoralski"
      groups   = ["system:masters"]
    },
  ]
}

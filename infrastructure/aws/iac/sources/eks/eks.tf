module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "= 19.21.0"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access = true
  enable_irsa                    = true

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
      most_recent       = true
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      most_recent       = true
    }
    vpc-cni = {
      resolve_conflicts    = "OVERWRITE"
      most_recent          = true
      configuration_values = jsonencode({
        env = {
          AWS_VPC_K8S_CNI_EXTERNALSNAT       = "false"
        }
      })
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  control_plane_subnet_ids = var.public_subnets


  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types             = var.default_instance_types
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    default_node_group = {
      min_size     = var.cluster_min_size
      max_size     = var.cluster_max_size
      desired_size = var.cluster_desired_size

      instance_types = var.cluster_instance_types
      capacity_type  = var.cluster_capacity_type
      disk_size      = var.cluster_disk_size
    }
  }

  # aws-auth configmap
  create_aws_auth_configmap = false
  manage_aws_auth_configmap = true
  aws_auth_roles            = concat(local.default_map_roles)
  aws_auth_users            = concat(local.default_map_users)
  iam_role_use_name_prefix  = false

  cluster_security_group_additional_rules = {
    ingress = {
      description                = "EKS Cluster allows 443 port to get API call"
      type                       = "ingress"
      from_port                  = 443
      to_port                    = 443
      protocol                   = "TCP"
      cidr_blocks                = ["0.0.0.0/0"]
      source_node_security_group = false
    }
    egress = {
      type                       = "egress"
      from_port                  = 0
      to_port                    = 0
      protocol                   = "-1"
      cidr_blocks                = ["0.0.0.0/0"]
      source_node_security_group = false
    }
  }



  tags = var.tags
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = [
      "eks", "get-token", "--cluster-name", module.eks.cluster_name, "--region", data.aws_region.current.name
    ]
    command     = "aws"
  }
}

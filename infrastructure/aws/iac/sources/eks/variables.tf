variable "cluster_name" {
  type        = string
  description = "The eks cluster name"
  default     = "mycompany"
}

variable "cluster_type" {
  type        = string
  description = "Type of cluster"
  validation {
    condition     = contains(["apps", "tooling"], var.cluster_type)
    error_message = "Valid values for var: cluster_type are (apps, tooling)."
  }
}

variable "cluster_version" {
  type        = string
  description = "The eks cluster version"
  default     = "1.28"
}

variable "default_instance_types" {
  type        = list(string)
  description = "The eks default nodegroup instance types"
  default     = ["t3.micro"]
}

variable "cluster_instance_types" {
  type        = list(string)
  description = "The eks nodegroup instance types"
  default     = ["t3.medium"]
}

variable "cluster_capacity_type" {
  type        = string
  description = "The eks cluster nodes capacity type"
  default     = "SPOT"
}

variable "cluster_disk_size" {
  type        = number
  description = "The eks cluster nodes disk size"
  default     = 50
}

variable "cluster_min_size" {
  type        = number
  description = "The eks cluster nodegroup nodes minimum number"
  default     = 1
}

variable "cluster_max_size" {
  type        = number
  description = "The eks cluster nodegroup nodes maximum number"
  default     = 5
}

variable "cluster_desired_size" {
  type        = number
  description = "The eks cluster nodegroup nodes desired number"
  default     = 3
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC for EKS"
}

variable "public_subnets" {
  type        = list(string)
  description = "The list of subnets"

  validation {
    condition = (
    length(var.public_subnets) > 0
    )

    error_message = "Subnets must not be empty."
  }
}

variable "private_subnets" {
  type        = list(string)
  description = "The list of subnets"

  validation {
    condition = (
    length(var.private_subnets) > 0
    )

    error_message = "Subnets must not be empty."
  }
}

variable "auth_provider_k8s_iam_role" {
  type        = string
  description = "The iam role to assume for K8S access"
  default = "AmazonEKSAdminRole"
}

variable "auth_use_aws_eks_cluster_auth" {
  type        = bool
  description = "Use 'use_aws_eks_cluster_auth' resource to authenticate. Run 'export TF_VAR_auth_use_aws_eks_cluster_auth=true' to set from cli."
  default     = false
}

variable "auth_external_id" {
  type        = string
  description = "Set auth_external_id. Run 'export TF_VAR_auth_external_id=xxx' to enable from cli. Required when 'auth_use_aws_eks_cluster_auth' is false."
  default     = ""
}


variable "eks_shared_namespaces" {
  description = "a map of infra-related kubernetes namespaces. These namespaces will be created and used by IRSA to restrict with serviceaccounts can assume iam roles for infra-related charts"
  type        = map(list(string))
  default = {
    dns        = ["external-dns"]
    infra      = ["infra-shared"]
    logging    = ["logging"]
    monitoring = ["monitoring"]
    ingress    = ["infra-ingress"]
    argo       = ["argo"]
  }
}

variable "env_code" {
  type        = string
  description = "The code of Environment"

  validation {
    condition     = contains(["prd", "stg", "dev"], var.env_code)
    error_message = "Valid values for var: account_name are (prd, stg, dev)."
  }
}

variable "tags" {
  type        = map(string)
  description = "The default map of tags"
}

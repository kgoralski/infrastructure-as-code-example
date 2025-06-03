locals {
  namespaces = flatten(
    [for n in var.eks_shared_namespaces : n]
  )

}

resource "kubernetes_namespace" "this" {
  for_each = toset(local.namespaces)
  metadata {
    annotations = {
      name = each.key
    }

    labels = {
      name    = each.key
      purpose = each.key
    }

    name = each.key
  }
}

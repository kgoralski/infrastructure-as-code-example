resource "aws_ecr_repository" "repo" {
  for_each             = var.repositories
  name                 = each.value.name
  image_tag_mutability = each.value.mutable ? "MUTABLE" : "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }

  tags = var.tags
}


resource "aws_ecr_lifecycle_policy" "repo-lifecycle-policy" {
  for_each   = var.repositories
  repository = aws_ecr_repository.repo[each.key].name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than ${each.value.expiration_days} days",
            "selection": {
                "tagStatus": "any",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": ${each.value.expiration_days}
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_replication_configuration" "replication-configuration" {
  count = var.replication_enabled ? 1 : 0
  replication_configuration {
    rule {
      destination {
        region      = "eu-central-1"
        registry_id = data.aws_caller_identity.current.account_id
      }

      destination {
        region      = "eu-west-1"
        registry_id = data.aws_caller_identity.current.account_id
      }

      destination {
        region      = "eu-west-2"
        registry_id = data.aws_caller_identity.current.account_id
      }

      destination {
        region      = "eu-north-1"
        registry_id = data.aws_caller_identity.current.account_id
      }
    }
  }
}

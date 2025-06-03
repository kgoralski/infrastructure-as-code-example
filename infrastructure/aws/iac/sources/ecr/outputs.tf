output "repositories" {
  value = tomap({
    for k, v in aws_ecr_repository.repo : k => {
      url                  = aws_ecr_repository.repo[k].repository_url
      arn                  = aws_ecr_repository.repo[k].arn
      image_tag_mutability = aws_ecr_repository.repo[k].image_tag_mutability
    }
  })
}

resource "aws_eip" "nat" {
  count = var.eip_count

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.base_name}-main-igw"
    }
  )
}
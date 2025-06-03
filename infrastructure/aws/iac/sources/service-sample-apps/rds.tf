resource "random_password" "master_password" {
  length  = 10
  special = false
}

resource "random_id" "snapshot_identifier" {
  keepers = {
    id = var.database_name
  }
  lifecycle {
    ignore_changes = all
  }
  byte_length = 4
}

module "database_cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name           = var.database_name
  database_name  = replace(var.database_name, "-", "_")
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  instances      = {
    one = {}
    #    two   = {}
  }

  autoscaling_enabled = true

  port = var.db_port

  publicly_accessible = var.is_public

  manage_master_user_password         = false
  master_password                     = random_password.master_password.result
  master_username                     = var.master_username
  iam_database_authentication_enabled = true

  vpc_id                 = var.vpc_id
  db_subnet_group_name   = var.db_subnet_group_name
  create_security_group   = false
  vpc_security_group_ids = [var.vpc_sg_id, aws_security_group.rds_aurora_sg.id]

  preferred_maintenance_window = "Mon:00:00-Mon:03:00"
  preferred_backup_window      = "03:00-06:00"

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = var.deletion_protection

  final_snapshot_identifier = "${replace(var.database_name, "_", "-")}-${random_id.snapshot_identifier.hex}-final"

  tags = var.tags

}

resource "aws_security_group" "rds_aurora_sg" {
  name_prefix = "${var.database_name}-"
  vpc_id      = var.vpc_id
  description = "Grants access to Aurora Cluster ${var.database_name}"
  tags        = merge({ "Name" = var.database_name }, var.tags)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "aurora_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_aurora_sg.id
}

resource "aws_security_group_rule" "eks_aurora" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "-1"
  security_group_id        = aws_security_group.rds_aurora_sg.id
  source_security_group_id = var.eks_sg_id
}

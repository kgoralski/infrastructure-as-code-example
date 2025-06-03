
output "master_password" {
  value     = random_password.master_password.result
  sensitive = true
}

output "master_username" {
  value = module.database_cluster.cluster_master_username
  sensitive = true
}

output "endpoint" {
  value = module.database_cluster.cluster_endpoint
}

output "database_name" {
  value = module.database_cluster.cluster_database_name
}

output "cluster_instances" {
  value = module.database_cluster.cluster_instances
}


output "cluster_resource_id" {
  value = module.database_cluster.cluster_resource_id
}

output "reader_endpoint" {
  value = module.database_cluster.cluster_reader_endpoint
}

output "additional_cluster_endpoints" {
  value = module.database_cluster.additional_cluster_endpoints
}

output "port" {
  value = module.database_cluster.cluster_port
}

output "security_group_id" {
  value = module.database_cluster.security_group_id
}

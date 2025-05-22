locals {
  my_ip_cidr              = "${trimspace(data.http.my_ip.response_body)}/32"
  container_registry_name = module.naming.container_registry.name_unique
}
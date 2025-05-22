locals {
  hub_name = module.naming.machine_learning_workspace.name_unique
  my_ip    = trimspace(data.http.my_ip.response_body)
}
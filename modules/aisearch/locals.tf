locals {
  search_service_name = module.naming.search_service.name_unique
  my_ip               = trimspace(data.http.my_ip.response_body)
}
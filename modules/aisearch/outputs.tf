output "ai_search_resource_id" {
  description = "The Resource ID of the AI Search Service."
  value = module.search_service.resource_id
}

output "ai_search_resource_name" {
  description = "The name of the AI Search Service."
  value = local.search_service_name
}
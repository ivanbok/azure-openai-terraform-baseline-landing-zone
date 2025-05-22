locals {
  my_ip       = trimspace(data.http.my_ip.response_body)
  openai_name = module.naming.cognitive_account.name_unique
}
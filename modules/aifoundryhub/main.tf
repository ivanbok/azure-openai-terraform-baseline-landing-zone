data "http" "my_ip" {
  url = "https://api.ipify.org"
}
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  prefix  = ["aihub"] # Generally, prefixes are not recommended. However, Hubs are part of ML workspaces and this identifies a Hub resource
  suffix  = [var.base_name]
}

# -- AI Hub --
#: https://registry.terraform.io/modules/Azure/avm-res-machinelearningservices-workspace/azurerm/latest
module "ai_hub" {
  source              = "Azure/avm-res-machinelearningservices-workspace/azurerm"
  version             = "0.6.0" # "0.4.1"
  name                = local.hub_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Hub"

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = []
  }

  workspace_friendly_name = "Azure OpenAI Chat Hub"
  workspace_description   = "Hub to support the Microsoft Learn Azure OpenAI baseline chat implementation."

  # Allow access only from SEED IPs
  ip_allowlist = concat([local.my_ip], var.ingress_client_ip)

  workspace_managed_network = {
    isolation_mode = "AllowOnlyApprovedOutbound"
    spark_ready    = false
    outbound_rules = {
      # Firewall rules are not created until FQDN outbound rules are added. Hence we add this outbound rule (in theory, it can be anything). 
      # Otherwise, the AOAI Private Endpoint connection below will not be activated.
      # https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/configure-managed-network?tabs=portal#select-an-azure-firewall-version-for-allowed-only-approved-outbound
      fqdn = merge(
        {
          "aoai-fqdn" = {
            destination = "${var.openai_resource_name}.openai.azure.com"
          }
        },
        var.provision_ai_search ? {
          "aisearch-fqdn" = {
            destination = "${var.ai_search_resource_name}.search.windows.net"
          }
        } : {}
      )
      private_endpoint = merge(
        {
          "aoai" = {
            resource_id         = var.openai_resource_id
            sub_resource_target = "account"
            spark_enabled       = false
          }
        },
        var.provision_ai_search ? {
          "aisearch" = {
            resource_id         = var.ai_search_resource_id
            sub_resource_target = "searchService"
            spark_enabled       = false
          }
        } : {}
      )
    }
  }

  storage_access_type = "identity"
  storage_account = {
    create_new  = false
    resource_id = var.ai_foundry_storage_account_id
  }

  key_vault = {
    create_new  = false
    resource_id = var.key_vault_id
  }

  container_registry = {
    create_new  = false
    resource_id = var.container_registry_id
  }

  application_insights = {
    create_new  = false
    resource_id = var.appinsights_id
  }

  tags = var.default_tags

  # # Removed as it is not supported for OpenAI, only Cognitive Services Account
  # # In turn, Cognitive services account cannot be used as public access must be enabled for this to work
  # # Can be added back in future if new AVM version supports it
  # aiservices = {
  #   resource_group_id         = var.resource_group_id
  #   name                      = var.openai_resource_name
  #   create_service_connection = true
  # }
}

# Create the OpenAI connection. AVM Module for AI Hub does not support connections using OpenAI, only Congitive Services Account
# Ref: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/2024-10-01/workspaces/connections
resource "azapi_resource" "aoai_connection" {
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-10-01-preview"
  name      = "aoai"
  parent_id = module.ai_hub.resource.id

  body = {
    properties = {
      authType       = "AAD"
      category       = "AzureOpenAI"
      isSharedToAll  = true
      sharedUserList = []
      metadata = {
        ApiType    = "Azure"
        ResourceId = var.openai_resource_id
      }
      target = var.openai_endpoint
    }
  }

  lifecycle {
    ignore_changes = [
      body["properties"]["error"],
      body["properties"]["metadata"],
      body["properties"]["provisioningState"]
    ]
  }
}


# Create the AI Search connection. AVM Module for AI Hub does not support connections using AI Search, only Congitive Services Account
# Ref: https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/2024-10-01/workspaces/connections
resource "azapi_resource" "ai_search_connection" {
  count     = var.provision_ai_search ? 1 : 0
  type      = "Microsoft.MachineLearningServices/workspaces/connections@2024-10-01-preview"
  name      = "aisearch"
  parent_id = module.ai_hub.resource.id

  body = {
    properties = {
      authType       = "AAD"
      category       = "CognitiveSearch"
      isSharedToAll  = true
      sharedUserList = []
      metadata = {
        ApiType    = "Azure"
        ResourceId = var.ai_search_resource_id
      }
      target = "https://${var.ai_search_resource_name}.search.windows.net/"
    }
  }

  lifecycle {
    ignore_changes = [
      body["properties"]["error"],
      body["properties"]["metadata"],
      body["properties"]["provisioningState"]
    ]
  }
}

# -- Diagnostics: AI Hub --
resource "azurerm_monitor_diagnostic_setting" "aihub" {
  name                       = "default"
  target_resource_id         = module.ai_hub.resource_id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}

# -- Private Endpoint for AI Hub --
resource "azurerm_private_endpoint" "ml_pe" {
  name                = "pep-${local.hub_name}"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  subnet_id = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-${local.hub_name}"
    private_connection_resource_id = module.ai_hub.resource_id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "pep-${local.hub_name}"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.ai_hub_dns_zone.id,
    ]
  }

  tags = var.default_tags
}

resource "azurerm_private_dns_zone" "ai_hub_dns_zone" {
  name                = "privatelink.api.azureml.ms"
  resource_group_name = var.virtual_network_resource_group_name
  tags                = var.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_dns_link" {
  name                  = "privatelink.api.azureml.ms-link"
  resource_group_name   = var.virtual_network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ai_hub_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.default_tags
}
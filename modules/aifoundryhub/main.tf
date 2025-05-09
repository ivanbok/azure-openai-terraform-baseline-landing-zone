# -- AI Hub --
module "ai_hub" {
  source  = "Azure/avm-res-machinelearningservices-workspace/azurerm"
  version = "0.4.1"
  name                = "aihub-${var.base_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Hub"

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = []
  }

  workspace_friendly_name = "Azure OpenAI Chat Hub"
  workspace_description   = "Hub to support the Microsoft Learn Azure OpenAI baseline chat implementation."

  ip_allowlist = var.ingress_client_ip

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

  # # Removed as it is not supported for OpenAI, only Cognitive Services Account
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
      authType                    = "AAD"
      category                    = "AzureOpenAI"
      isSharedToAll               = true
      sharedUserList              = []
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
      authType                    = "AAD"
      category                    = "CognitiveSearch"
      isSharedToAll               = true
      sharedUserList              = []
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
  name                = "pep-aiproj-${var.base_name}"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  subnet_id = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-aiproj-${var.base_name}"
    private_connection_resource_id = module.ai_hub.resource_id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }
}
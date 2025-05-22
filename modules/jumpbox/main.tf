module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [var.base_name]
}

resource "azurerm_monitor_data_collection_rule" "vm_insights" {
  name                = "dcr-${local.jump_box_name}" # Resource not supported by naming module
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "Windows"
  data_sources {
    performance_counter {
      name                          = "VMInsightsPerfCounters"
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\VMInsights\\DetailedMetrics"]
    }

    extension {
      name           = "DependencyAgentDataSource"
      extension_name = "DependencyAgent"
      streams        = ["Microsoft-ServiceMap"]
      extension_json = jsonencode({})
    }
  }

  destinations {
    log_analytics {
      name                  = var.log_workspace_name
      workspace_resource_id = var.log_workspace_id
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-ServiceMap"]
    destinations = [var.log_workspace_name]
  }

  tags = var.default_tags
}

resource "azurerm_network_interface" "jumpbox_nic" {
  name                = "nic-${local.jump_box_name}"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.jumpbox_subnet_id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
  }

  tags = var.default_tags
}

resource "random_password" "jump_box_admin_password" {
  length  = 16
  special = true
}

resource "azurerm_key_vault_secret" "jump_box_admin_password" {
  name            = var.jump_box_admin_name
  value           = local.jump_box_admin_password
  key_vault_id    = var.key_vault_id
  content_type    = "text/plain"
  expiration_date = timeadd(timestamp(), "8760h") # Default to 1 year as per IM8
  tags = merge(
    var.default_tags,
    {
      vm_name        = local.jump_box_name
      admin_username = var.jump_box_admin_name
    }
  )
}

resource "azurerm_windows_virtual_machine" "jumpbox" {
  name                  = local.jump_box_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = "Standard_D2s_v3"
  admin_username        = var.jump_box_admin_name
  admin_password        = local.jump_box_admin_password
  network_interface_ids = [azurerm_network_interface.jumpbox_nic.id]
  zone                  = "1"

  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 127
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-pro"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  provision_vm_agent       = true
  enable_automatic_updates = true
  patch_mode               = "AutomaticByOS"
  secure_boot_enabled      = true # This enables secure boot and trusted launch
  vtpm_enabled             = true # This enables vTPM and trusted launch

  tags = var.default_tags
}

resource "azurerm_virtual_machine_extension" "ama" {
  name                       = "AzureMonitorWindowsAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.jumpbox.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.21"
  auto_upgrade_minor_version = true
  tags                       = var.default_tags
}

resource "azurerm_virtual_machine_extension" "dependency_agent" {
  name                       = "DependencyAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.jumpbox.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  tags                       = var.default_tags
  auto_upgrade_minor_version = true
  settings = jsonencode({
    enableAMA = "true"
  })
}

resource "azurerm_monitor_data_collection_rule_association" "jumpbox_dcra" {
  depends_on              = [azurerm_virtual_machine_extension.dependency_agent]
  name                    = "dcra-vminsights"
  description             = "VM Insights DCR association with the jump box."
  target_resource_id      = azurerm_windows_virtual_machine.jumpbox.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.vm_insights.id
}
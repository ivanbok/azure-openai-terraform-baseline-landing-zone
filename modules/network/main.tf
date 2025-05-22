# ---------------- DATA SOURCES ---------------- #

# Fetch the existing UDR if provided
data "azurerm_route_table" "internet_udr" {
  count               = var.existing_udr_for_internet_traffic_name != "" ? 1 : 0
  name                = var.existing_udr_for_internet_traffic_name
  resource_group_name = var.virtual_network_resource_group_name
}

# ------------------ RESOURCES ------------------ #

module "app_services_naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [local.app_services_suffix]
}

# App Services Subnet
resource "azurerm_subnet" "app_services" {
  name                 = module.app_services_naming.subnet.name
  resource_group_name  = var.virtual_network_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.app_services_subnet_prefix]
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "app_services" {
  subnet_id                 = azurerm_subnet.app_services.id
  network_security_group_id = azurerm_network_security_group.app_services_nsg.id
}

resource "azurerm_subnet_route_table_association" "app_services" {
  count          = local.internet_udr_id != null ? 1 : 0
  subnet_id      = azurerm_subnet.app_services.id
  route_table_id = local.internet_udr_id
}

resource "azurerm_network_security_group" "app_services_nsg" {
  name                = module.app_services_naming.network_security_group.name
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  security_rule {
    name                       = "AppPlan.Out.Allow.PrivateEndpoints"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.app_services_subnet_prefix
    destination_address_prefix = var.private_endpoints_subnet_prefix
  }

  security_rule {
    name                       = "AppPlan.Out.Allow.AzureMonitor"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.app_services_subnet_prefix
    destination_address_prefix = "AzureMonitor"
  }
}

# Private Endpoints Subnet

module "private_endpoints_naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [local.private_endpoints_suffix]
}

resource "azurerm_subnet" "private_endpoints" {
  name                                          = module.private_endpoints_naming.subnet.name
  resource_group_name                           = var.virtual_network_resource_group_name
  virtual_network_name                          = var.vnet_name
  address_prefixes                              = [var.private_endpoints_subnet_prefix]
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.private_endpoints_nsg.id
}

resource "azurerm_subnet_route_table_association" "private_endpoints" {
  count          = local.internet_udr_id != null ? 1 : 0
  subnet_id      = azurerm_subnet.private_endpoints.id
  route_table_id = local.internet_udr_id
}

resource "azurerm_network_security_group" "private_endpoints_nsg" {
  name                = module.private_endpoints_naming.network_security_group.name
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.private_endpoints_subnet_prefix
    destination_address_prefix = "*"
  }
}

# Agents Subnet

module "agents_naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [local.agents_suffix]
}

resource "azurerm_subnet" "agents" {
  name                                          = module.agents_naming.subnet.name
  resource_group_name                           = var.virtual_network_resource_group_name
  virtual_network_name                          = var.vnet_name
  address_prefixes                              = [var.agents_subnet_prefix]
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
}

resource "azurerm_subnet_network_security_group_association" "agents" {
  subnet_id                 = azurerm_subnet.agents.id
  network_security_group_id = azurerm_network_security_group.agents_nsg.id
}

resource "azurerm_subnet_route_table_association" "agents" {
  count          = local.internet_udr_id != null ? 1 : 0
  subnet_id      = azurerm_subnet.agents.id
  route_table_id = local.internet_udr_id
}

resource "azurerm_network_security_group" "agents_nsg" {
  name                = module.agents_naming.network_security_group.name
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.agents_subnet_prefix
    destination_address_prefix = "*"
  }
}

# Jumpbox Subnet

module "jumpbox_naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [local.jumpbox_suffix]
}

resource "azurerm_subnet" "jumpbox" {
  name                                          = module.jumpbox_naming.subnet.name
  resource_group_name                           = var.virtual_network_resource_group_name
  virtual_network_name                          = var.vnet_name
  address_prefixes                              = [var.jumpbox_subnet_prefix]
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
}

resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = azurerm_subnet.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox_nsg.id
}

resource "azurerm_subnet_route_table_association" "jumpbox" {
  count          = local.internet_udr_id != null ? 1 : 0
  subnet_id      = azurerm_subnet.jumpbox.id
  route_table_id = local.internet_udr_id
}

resource "azurerm_network_security_group" "jumpbox_nsg" {
  name                = module.jumpbox_naming.network_security_group.name
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  security_rule {
    name                       = "Jumpbox.In.Allow.SshRdp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "3389"]
    source_address_prefix      = var.bastion_subnet_prefix
    destination_address_prefix = var.jumpbox_subnet_prefix
  }

  security_rule {
    name                       = "Jumpbox.Out.Allow.PrivateEndpoints"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.jumpbox_subnet_prefix
    destination_address_prefix = var.private_endpoints_subnet_prefix
  }

  security_rule {
    name                       = "Jumpbox.Out.Allow.Internet"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.jumpbox_subnet_prefix
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "DenyAllOutBound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.jumpbox_subnet_prefix
    destination_address_prefix = "*"
  }
}

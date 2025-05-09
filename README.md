# Azure OpenAI Baseline Terraform Landing Zone Accelerator

## 1 Overview

The Azure OpenAI Baseline Terraform Landing Zone Accelerator builds upon the concept of the [CAF Azure Verified Modules (AVM) Landing Zone](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/deploy-landing-zones-with-terraform) to automate the creation of a baseline infrastructure for Azure AI workloads. As of publication, most of the IaC patterns for AI Accelerators provided by Azure are written in Bicep, which may not fit the needs of many organizations. This build provides a Terraform-based alternative, following closely the same patterns provided by the Bicep-based counterparts, and utilizing Azure Verified Modules (AVM) for Microsoft support. 

This repository follows the application landing zone pattern, distinct from the broader platform landing zone strategy. For background, refer to [Platform Landing Zones vs. Application Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/).

It integrates with pre-existing management groups, governance structures, and Azure subscriptions. It is designed to support AI workloads by offering a structured, extensible, and secure environment aligned with the Azure Cloud Adoption Framework.

This deployment assumes a pre-provisioned Virtual Network (VNet) and Azure subscription, which may or may not be within a broader construct of CAF compliant Azure Platform Landing Zone

The segregation in terms of technical constructs is described below, showing where the AI Landing Zone Accelerator sits in an end-to-end setup:

![Design Construct](assets/construct.png "Design Construct")

## 2 High Level Design

### 2.1 Architecture Diagram

The diagram illustrates the core components of the AI Acceleration Space, including data ingress/egress, compute resources, networking, and security layers.

![Architecture Diagram](assets/architecture.png "Architecture Diagram")

#### Key Design Elements

* Modular Infrastructure-as-Code: Each major functional domain is encapsulated as a Terraform module (e.g., AI Project, Foundry Hub, ACR).

* Separation of Concerns: Modules isolate responsibilities for reusability and ease of maintenance.

* Security by Default: Network isolation, RBAC principles, and configuration of private endpoints where possible. Due to the complexity of setting up secure infrastructure, having these repeatable patterns in terraform abstracts away the complexity and enables AI Developers in agencies to focus on innovation

* Scalable Network Model: Assumes integration into a hub-spoke or mesh architecture using a pre-existing VNet.

* Composable Deployment: Designed to be run independently or as part of a CI/CD pipeline, with the option for partial deployments.

#### Platform Landing Zone Integration

![Platform Landing Zone](assets/landing_zones.png "Platform Landing Zones")

In the context of [Platform Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/), this AI Accelerator acts as a ready-made application landing zone that can be deployed in a subscription that leverages on an empty spoke VNet. 

### 2.2 Prerequisite Resources

1. This setup assumes that a VNet and optional User-Defined Route (UDR) Table is already provisioned. 
2. Two resource groups must be created. One for networking resources (including the VNet and UDR above), and another to deploy non-networking resources

Before deploying this solution, ensure the following are in place:

* An existing VNet with no subnets

* User-defined route (UDR) table (Optional)

### 2.3 Baseline Modules

| Module Folder | Descriptive Name         | Purpose                                                             |
| ------------- | ------------------------ | ------------------------------------------------------------------- |
| acr           | Azure Container Registry | Provisions ACR to support Container Apps and AI Foundry Deployments |
| aifoundryhub  | AI Foundry Hub           | Provisions AI Foundry Hub resource and AI resource connectors       |
| aisearch*     | AI Search                | Provisions AI Search resource for RAG use cases (optional)          |
| jumpbox       | jumpbox                  | Provisions JumpBox for secure Network Access                        |
| keyvault      | Azure Key Vault          | Provisions common AKV for AI Foundry and misc usage                 |
| monitoring    | Monitoring               | Provisions Log Analytics Workspace for general monitoring           |
| network       | Networking               | Provisions subnets and network security groups                      |
| openai        | Azure OpenAI Service     | Provisions Azure OpenAI Account and Model Deployments               |
| storage       | Storage Account          | Provisions App Deployment and ML Storage Accounts                   |

*This is an optional deployment, and can be toggled using the ```var.provision_ai_search``` variable. Note that AI Search will have some baseline cost (i.e. it is not pay-as-you go, but has provisioned units) even if unused. 

### 2.4 Add-On Modules

Add-on Modules are designed such that they can be provisioned more than once, and sit at a layer above the baseline modules. For example, in a single AI Foundry Hub, you may want to have multiple AI Foundry Projects for different use cases. 

The aiproject module enables you to provision projects with preconfigured managed online endpoints to abstract away the complexity of setting up networking and RBAC assignments to all the necessary AI services. 

Similarly, each User onboarded into the subscription will require <b>data plane</b> access for the provisioned AI and Storage services. These are not inherited by default even with owner privileges. The roleassignments module can be called on-demand for each User to automatically assign all required permissions to seamlessly use AI Foundry as a developer and access all AI services. 

| Module Folder   | Descriptive Name      | Purpose                                                              |
| --------------- | --------------------- | -------------------------------------------------------------------- |
| aiproject       | AI Foundry Projects   | Provisions a Foundry project/workspace, and managed online endpoints |
| roleassignments | User Role Assignments | Provisions all required data plane RBACs to develop on AI Foundry    |

### 2.5 Resources not Created by Terraform

The following resources are not created by Terraform:

| Resource          | Reason                                                                                      |
| ----------------- | ------------------------------------------------------------------------------------------- |
| App Service       | Provides developers options for alternative services for app hosting (e.g. AKS, ACA)        |
| App Gateway       | This requires existing targets (e.g. App Service). A Gateway Subnet is still created        |
| Embedding Models  | These can be deployed via Foundry or in OpenAI Service, and depend on regional availability |
| Prompt Flow Flows | These are part of AI Developer/Engineer's responsibility to build in Foundry                |
| Other AI Services | These are part of AI Developer/Engineer's responsibility to deploy based on custom use case |

## 3 IaC Design

### 3.1 Notes for Deployment

The sample code for review contains a parent main.tf. For demonstration purposes, the parent main.tf is designed for a single-click deployment, although this is not meant to be done in practice as mentioned in the previous section, there are certain modules that are designed to be deployed as part of baseline and others that are meant to be deployed as repeatable modules. 

For simplicity, the parent main.tf orchestrates a sample end-to-end deployment that provisions two (2) AI workspace projects, and onboards a list of predefined used into the subscription for AI Foundry access. In practice, these are reusable modules that can be provisioned multiple times after the baseline modules are provisioned. 

To deploy, navigate your terminal to the parent folder and run the following (assuming terraform is installed):

```
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 3.2 Input Variables

| Variable                            | Type         | Description/Purpose                            |
| ----------------------------------- | ------------ | ---------------------------------------------- |
| subscription_id                     | string       | ID of the subscription                         |
| workload_resource_group_name        | string       | Name of the resource group to deploy resources |
| base_name                           | string       | Base name for naming Azure resources           |
| openai_location                     | string       | For development, to use non-SG OpenAI Accounts |
| openai_models                       | list(string) | To provision OpenAI models. Can be left empty  |
| openai_version_map                  | map(string)  | Map of OpenAI models to their Version IDs      |
| provision_ai_search                 | bool         | Toggle whether or not to provision AI Search   |
| existing_resource_id_for_spoke_vnet | string       | Resource ID of the existing VNet               |
| existing_resource_id_for_udr        | string       | Resource ID of the existing UDR (optional)     |
| ingress_client_ip                   | list(string) | Optional, if your organization has fixed IPs   |
| bastion_subnet_prefix               | string       | CIDR for Bastion Subnet                        |
| app_services_subnet_prefix          | string       | CIDR for App Services Subnet                   |
| app_gateway_subnet_prefix           | string       | CIDR for App Gateway Subnet                    |
| private_endpoints_subnet_prefix     | string       | CIDR for Private Endpoints Subnet              |
| agents_subnet_prefix                | string       | CIDR for Agents Subnet                         |
| jumpbox_subnet_prefix               | string       | CIDR for Jumpbox Subnet                        |
| your_principal_id                   | string       | Your User Principal ID (to access Foundry)     |
| telemetry_opt_out                   | bool         | To opt out of sending telemetry                |
| jump_box_admin_name                 | string       | Set the admin name for the Jumpbox             |
| jump_box_admin_password             | string       | Set the password for Jumpbox (securestring)    |

### 3.3 Design Considerations

#### 3.3.1 AI Search

AI Search is now included as part of the baseline instead of an add-on module. This is because adding AI Search requires configuring connections in AI Foundry. Creating AI Search <i>after</i> the AI Foundry Hub Module is provisioned requires making a PATCH request via AzAPI, which is not supported. If agencies decide to opt out of provisioning AI Search (since there is a fixed cost associated with it), there is an option to be switched off. 

#### 3.3.2 Access Control

Azure AI Foundry acts as a portal, and does not inherently have any service based permissions. When you access AI services, such as Azure OpenAI or Azure AI Search in AI Foundry, the authentical principal depends on the mechanism used. 

As an AI Developer accessing the Foundry Portal, you will need to have RBAC permissions assigned to your user identity in order to access AI Services connected to Foundry Hub. Even if your user identity is granted owner privileges at the subscription level, this does not automatically confer data plane access to Storage and AI services. To simplify these role assignments, you will need to call the roleassignments terraform module, passing in your user principal ID in the process, to assign all the required data plane permissions. 

Once your project is published to a managed online endpoint, the managed online endpoint will be associated with a system-assigned managed identity. When your web application makes an API call to the managed online endpoint, the compute instances hosting the endpoint will need to make API calls on behalf of the calling application to various AI services. In the Terraform code, these RBAC assignments for the managed online endpoints have already been preconfigured. AI developers publishing their projects to managed online endpoints are therefore recommended to use the preprovisioned endpoints rather than creating their own to avoid the complexity of configuring these permissions. 

### 3.4 Future Enhancements and Considerations

1. Instead of using base_name for naming, all resources will be migrated to align with using the azurerm_naming module for automated naming
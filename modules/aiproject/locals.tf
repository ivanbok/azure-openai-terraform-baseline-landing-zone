locals {
    project = {
        name                    = "${module.naming.machine_learning_workspace.name_unique}"
        workspace_friendly_name = "prj-${module.naming.machine_learning_workspace.name_unique}" # "AI Studio Project ${var.project_name}"
        workspace_description   = "This is a project to contain your prompt flow implementation, created by GCC AI Acceleration Space."
    }

    storage_blob_data_contributor_id         = "/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
    storage_file_data_contributor_id         = "/providers/Microsoft.Authorization/roleDefinitions/69566ab7-960f-475b-8e7c-b3118f30c6bd"
    aml_workspace_secrets_reader_role_id     = "/providers/Microsoft.Authorization/roleDefinitions/ea01e6af-a1c1-4350-9563-ad00f8c72ec5"
    cognitive_services_openai_user_id        = "/providers/Microsoft.Authorization/roleDefinitions/5e0bd9bd-7b93-4f28-af87-19fc36ad61bd"
    cognitive_services_openai_contributor_id = "/providers/Microsoft.Authorization/roleDefinitions/a001fd3d-188f-4b5d-821b-7da978bf7442"
    search_index_data_contributor_id         = "/providers/Microsoft.Authorization/roleDefinitions/8ebe5a00-799e-43f5-93ac-243d3dce84a7"
    search_index_data_reader_id              = "/providers/Microsoft.Authorization/roleDefinitions/1407120a-92aa-4202-b7e9-c0e197c71c8f"
}
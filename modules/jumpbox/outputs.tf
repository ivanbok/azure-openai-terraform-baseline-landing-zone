output "jumpbox_vm_id" {
  value = azurerm_windows_virtual_machine.jumpbox.id
}

output "jumpbox_managed_identity_id" {
  value = azurerm_windows_virtual_machine.jumpbox.identity[0].principal_id
}
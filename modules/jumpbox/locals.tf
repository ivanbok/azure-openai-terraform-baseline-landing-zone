locals {
  jump_box_name           = module.naming.windows_virtual_machine.name
  jump_box_admin_password = random_password.jump_box_admin_password.result
}
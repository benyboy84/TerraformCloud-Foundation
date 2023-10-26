# The following code block is used to create workspace resources in project.

module "workspaces" {
  source = "./modules/notification"

  for_each = { for notification in local.workspace_notifications : "${notification.workspace} ${notification.name}" => notification }

  name             = each.value.name
  destination_type = each.value.destination_type
  workspace_id     = module.workspaces[each.value.workspace].id
  email_user_ids   = try(each.value.emails,null) 
  enabled          = try(each.value.enabled, true)
  token            = try(each.value.token, null)
  triggers         = try(each.value.triggers,null)
  url              = try(each.value.url, null)
}
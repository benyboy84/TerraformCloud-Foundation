# The following code block is used to create variable resources.
resource "tfe_variable" "variable_set" {
  for_each = { for variable in local.variable_sets_variables : "${variable.variable_set} ${variable.key}" => variable }

  key             = each.value.key
  value           = each.value.value
  category        = each.value.category
  description     = try(each.value.description, null)
  hcl             = try(each.value.hcl, null)
  sensitive       = try(each.value.sensitive, null)
  variable_set_id = tfe_variable_set.this[each.value.variable_set].id

}

resource "tfe_variable" "workspace" {
  for_each = { for variable in local.workspace_variables : "${variable.workspace} ${variable.key}" => variable }

  key          = each.value.key
  value        = each.value.value
  category     = each.value.category
  description  = try(each.value.description, null)
  hcl          = try(each.value.hcl, null)
  sensitive    = try(each.value.sensitive, null)
  workspace_id = module.workspaces[each.value.workspace].id

}
# The following code block is used to create variable sets resources.

resource "tfe_variable_set" "this" {
  for_each = local.variable_sets

  name         = lower(replace(each.key, "/\\W|_|\\s/", "_"))
  description  = try(each.value.description, null)
  global       = try(each.value.global, null)
  organization = data.tfe_organization.this.name

  lifecycle {
    precondition {
      condition     = try(each.value.global, false) ? try(each.value.workspaces, null) == null && try(each.value.projects, null) == null ? true : false : true
      error_message = "`global` cannot be set to true if `workspaces` or `projects` is defined."
    }
  }
}

resource "tfe_project_variable_set" "this" {
  for_each = local.project_variable_sets

  variable_set_id = tfe_variable_set.this[each.value.name].id
  project_id      = tfe_project.project[each.value.project].id
}

resource "tfe_workspace_variable_set" "this" {
  for_each = local.workspace_variable_sets

  variable_set_id = tfe_variable_set.this[each.value.name].id
  workspace_id    = try(module.workspaces[each.value.workspace].id, null)
}
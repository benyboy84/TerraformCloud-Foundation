locals {

  # The following locals use logic to determine the variable sets at project level.
  project_variable_sets_tuple = flatten([for project_key, project in local.projects :
    flatten([for variable_set_key, variable_set in project.variable_sets :
      merge(
        variable_set,
        {
          name    = variable_set_key
          project = project_key
        }
      )
    ])
    if try(project.variable_sets, null) != null
  ])
  project_variable_sets = { for object in local.project_variable_sets_tuple : "${object.name} ${object.project}" => object }

  # This is to merge all variable_set.
  variable_sets = merge(local.organization_variable_sets, local.project_variable_sets)

  # The following locals use logic to determine the project associate with each variable sets at the organization level.
  organization_variable_sets_project = flatten([for key, variable_set in local.variable_sets :
    flatten([for project in flatten(variable_set.projects) :
      merge(variable_set,
        {
          name    = key
          project = project
        }
      )
    ])
    if try(variable_set.projects, null) != null
  ])

  # The following locals use logic to determine the workspace associate with each variable sets at the organization level.
  organization_variable_sets_workspace = flatten([for key, variable_set in local.variable_sets :
    flatten([for workspace in flatten(variable_set.workspaces) :
      merge(variable_set,
        {
          name      = key
          workspace = workspace
        }
      )
    ])
    if try(variable_set.workspaces, null) != null
  ])

}
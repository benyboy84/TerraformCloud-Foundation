# The following variables are used to create team resources (`tfe_team`).

variable "name" {
  description = "(Required) Name of the team."
  type        = string
}

variable "organization" {
  description = "(Required) Name of the organization. If omitted, organization must be defined in the provider config."
  type        = string
}

variable "visibility" {
  description = "(Optional) The visibility of the team (`secret` or `organization`)."
  type        = string
  default     = "organization"

  validation {
    condition     = var.visibility != null ? contains(["secret", "organization"], var.visibility) ? true : false : true
    error_message = "Valid values are `secret` or `organization`."
  }
}

variable "sso_team_id" {
  description = "(Optional) Unique Identifier to control team membership via SAML."
  type        = string
  default     = null
}

variable "organization_access" {
  description = <<EOT
  (Optional) Settings for the team's organization access.
    read_projects           : (Optional) Allow members to view all projects within the organization. Requires read_workspaces to be set to true.
    manage_projects         : (Optional) Allow members to create and administrate all projects within the organization.
    read_workspaces         : (Optional) Allow members to view all workspaces in this organization.
    manage_workspaces       : (Optional) Allows members to create and administrate all workspaces within the organization.
    manage_policies         : (Optional) Allows members to create, edit, and delete the organization's Sentinel policies.
    manage_policy_overrides : (Optional) Allows members to override soft-mandatory policy checks.
    manage_run_tasks        : (Optional) Allow members to create, edit, and delete the organization's run tasks.
    manage_vcs_settings     : (Optional) Allows members to manage the organization's VCS Providers and SSH keys.
    manage_membership       : (Optional) Allow members to add/remove users from the organization, and to add/remove users from visible teams.
    manage_modules          : (Optional) Allow members to publish and delete modules in the organization's private registry.
    manage_providers        : (Optional) Allow members to publish and delete providers in the organization's private registry.
  EOT
  type = object({
    read_projects           = optional(bool, false)
    manage_projects         = optional(bool, false)
    read_workspaces         = optional(bool, false)
    manage_workspaces       = optional(bool, false)
    manage_policies         = optional(bool, false)
    manage_policy_overrides = optional(bool, false)
    manage_run_tasks        = optional(bool, false)
    manage_vcs_settings     = optional(bool, false)
    manage_membership       = optional(bool, false)
    manage_modules          = optional(bool, false)
    manage_providers        = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.organization_access != null ? var.organization_access.read_projects != false && var.organization_access.manage_projects != false ? false : true : true
    error_message = "Project access must be `read` or `manage`."
  }

  validation {
    condition     = var.organization_access != null ? var.organization_access.read_workspaces != false && var.organization_access.manage_workspaces != false ? false : true : true
    error_message = "Workspaces access must be `read` or `manage`."
  }

  validation {
    condition     = var.organization_access != null ? var.organization_access.manage_projects == true && var.organization_access.manage_workspaces != true ? false : true : true
    error_message = "`manage_projects` requires `manage_workspaces` to be set to `true`."
  }
}

# The following variables are used to create token resources (`tfe_team_token`).

variable "token" {
  description = "(Optional) If set to `true`, a team token will be generated."
  type        = bool
  default     = false
}

variable "token_force_regenerate" {
  description = "(Optional) If set to `true`, a new token will be generated even if a token already exists. This will invalidate the existing token!"
  type        = bool
  default     = false
}

variable "token_expired_at" {
  description = "(Optional) The token's expiration date. The expiration date must be a date/time string in RFC3339 format (e.g., '2024-12-31T23:59:59Z'). If no expiration date is supplied, the expiration date will default to null and never expire."
  type        = string
  default     = null

  validation {
    condition     = var.token_expired_at != null ? length(regexall("^((?:(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}))Z)$", var.token_expired_at)) > 0 ? true : false : true
    error_message = "The expiration date must be a date/time string in RFC3339 format (e.g., '2024-12-31T23:59:59Z')."
  }
}

# The following variables are used to create team organization members resources (`tfe_team_organization_members`).

variable "members" {
  description = "(Optional) Email of the organization's members to be added."
  type        = list(string)
  default     = null

  validation {
    condition     = var.members != null ? can([for member in var.members : regex("^([a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})$", member)]) ? true : false : true
    error_message = "Each member must be in a valid email address format (e.g., 'user@company.com')."
  }
}

# The following variables are used to create team project access resources (`tfe_team_project_access`).

variable "project_name" {
  description = "(Optional) Name of the project to which the team will be added."
  type        = string
  default     = null
}

variable "project_id" {
  description = "(Optional) ID of the project to which the team will be added."
  type        = string
  default     = null
}

variable "project_access" {
  description = "(Optional) Type of fixed access to grant. Valid values are `admin`, `maintain`, `write`, `read`, or `custom`."
  type        = string
  default     = "read"

  validation {
    condition     = var.project_access != null ? contains(["admin", "maintain", "write", "read", "custom"], var.project_access) ? true : false : true
    error_message = "Valid values are `admin`, `maintain`, `write`, `read`, or `custom`."
  }
}

variable "custom_project_access" {
  description = <<EOT
  (Optional) Settings for the team's project access.
    settings : (Optional) The permission to grant for the project's settings. Valid strings: `read`, `update`, or `delete`.
    teams	   : (Optional) The permission to grant for the project's teams. Valid strings: `none`, `read`, or `manage`.
  EOT
  type = object({
    settings = optional(string, "read")
    teams    = optional(string, "none")
  })
  default = null

  validation {
    condition     = var.custom_project_access != null ? contains(["read", "update", "delete"], var.custom_project_access.settings) ? true : false : true
    error_message = "Valid strings: `read`, `update`, or `delete`."
  }

  validation {
    condition     = var.custom_project_access != null ? contains(["none", "read", "manage"], var.custom_project_access.teams) ? true : false : true
    error_message = "Valid strings: `none`, `read`, or `manage`."
  }
}

variable "custom_workspace_access" {
  description = <<EOT
    runs	         : (Optional) The permission to grant project's workspaces' runs. Valid strings: `read`, `plan`, or `apply`.
    sentinel_mocks : (Optional) The permission to grant project's workspaces' Sentinel mocks. Valid strings: `none`, or `read`.
    state_versions : (Optional) The permission to grant project's workspaces' state versions. Valid strings: `none`, `read-outputs`, `read`, or `write`.
    variables      : (Optional) The permission to grant project's workspaces' variables. Valid strings: `none`, `read`, or `write`.
    create         : (Optional) The permission to create project's workspaces in the project.
    locking        : (Optional) The permission to manually lock or unlock the project's workspaces.
    delete	       : (Optional) The permission to delete the project's workspaces.
    move           : (Optional) This permission to move workspaces into and out of the project. The team must also have permissions to the project(s) receiving the the workspace(s).
    run_tasks      : (Optional) The permission to manage run tasks within the project's workspaces.
  EOT
  type = object({
    runs           = optional(string, "read")
    sentinel_mocks = optional(string, "none")
    state_versions = optional(string, "none")
    variables      = optional(string, "none")
    create         = optional(bool, false)
    locking        = optional(bool, false)
    delete         = optional(bool, false)
    move           = optional(bool, false)
    run_tasks      = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.custom_workspace_access != null ? contains(["read", "plan", "apply"], var.custom_workspace_access.runs) ? true : false : true
    error_message = "Valid strings: `read`, `plan`, or `apply`."
  }

  validation {
    condition     = var.custom_workspace_access != null ? contains(["none", "read"], var.custom_workspace_access.sentinel_mocks) ? true : false : true
    error_message = "Valid strings: `none`, or `read`."
  }

  validation {
    condition     = var.custom_workspace_access != null ? contains(["none", "read-outputs", "read", "write"], var.custom_workspace_access.state_versions) ? true : false : true
    error_message = "Valid strings: `none`, `read-outputs`, `read`, or `write`."
  }

  validation {
    condition     = var.custom_workspace_access != null ? contains(["none", "read", "write"], var.custom_workspace_access.variables) ? true : false : true
    error_message = "Valid strings: `none`, `read`, or `write`."
  }
}

# The following variables are used to create team workspace access resources (`tfe_team_access`).

variable "workspace_name" {
  description = "(Optional) Name of the workspace to which the team will be added."
  type        = string
  default     = null
}

variable "workspace_id" {
  description = "(Optional) ID of the workspace to which the team will be added."
  type        = string
  default     = null
}

variable "workspace_access" {
  description = "(Optional) Type of fixed access to grant. Valid values are `admin`, `read`, `plan`, or `write`. To use custom permissions, use a `workspace_permission` block instead."
  type        = string
  default     = null

  validation {
    condition     = var.workspace_access != null ? contains(["admin", "read", "plan", "write"], var.workspace_access) ? true : false : true
    error_message = "Valid values are `admin`, `read`, `plan`, or `write`."
  }
}

variable "workspace_permission" {
  description = <<EOT
  (Optional) Settings for the team's workspace access.
      runs              : (Optional) The permission to grant the team on the workspace's runs. Valid values are `read`, `plan`, or `apply`.
      variables         : (Optional) The permission to grant the team on the workspace's variables. Valid values are `none`, `read`, or `write`.
      state_versions    : (Optional) The permission to grant the team on the workspace's state versions. Valid values are `none`, `read`, `read-outputs`, or `write`.
      sentinel_mocks    : (Optional) The permission to grant the team on the workspace's generated Sentinel mocks, Valid values are `none` or `read`.
      workspace_locking : (Optional) Boolean determining whether or not to grant the team permission to manually lock/unlock the workspace.
      run_tasks         : (Optional) Boolean determining whether or not to grant the team permission to manage workspace run tasks.
  EOT
  type = object({
    runs              = optional(string, "read")
    variables         = optional(string, "none")
    state_versions    = optional(string, "none")
    sentinel_mocks    = optional(string, "none")
    workspace_locking = optional(bool, false)
    run_tasks         = optional(bool, false)
  })
  default = null

  validation {
    condition     = var.workspace_permission != null ? contains(["read", "plan", "apply"], var.workspace_permission.runs) ? true : false : true
    error_message = "Valid strings: `read`, `plan`, or `apply`."
  }

  validation {
    condition     = var.workspace_permission != null ? contains(["none", "read", "write"], var.workspace_permission.variables) ? true : false : true
    error_message = "Valid strings: `none`, `read`, or `write`."
  }

  validation {
    condition     = var.workspace_permission != null ? contains(["none", "read", "read-outputs", "write"], var.workspace_permission.state_versions) ? true : false : true
    error_message = "Valid strings: `none`, `read`, `read-outputs`, or `write`."
  }

  validation {
    condition     = var.workspace_permission != null ? contains(["none", "read"], var.workspace_permission.sentinel_mocks) ? true : false : true
    error_message = "Valid strings: `none`, or `read`."
  }
}

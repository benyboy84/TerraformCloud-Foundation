resource "github_repository" "this" {

  name                                    = var.name
  description                             = var.description
  homepage_url                            = var.homepage_url
  visibility                              = var.visibility
  has_issues                              = var.has_issues
  has_discussions                         = var.has_discussions
  has_projects                            = var.has_projects
  has_wiki                                = var.has_wiki
  is_template                             = var.is_template
  allow_merge_commit                      = var.allow_merge_commit
  allow_squash_merge                      = var.allow_squash_merge
  allow_rebase_merge                      = var.allow_rebase_merge
  allow_auto_merge                        = var.allow_auto_merge
  squash_merge_commit_title               = var.squash_merge_commit_title
  squash_merge_commit_message             = var.squash_merge_commit_message
  merge_commit_title                      = var.merge_commit_title
  merge_commit_message                    = var.merge_commit_message
  delete_branch_on_merge                  = var.delete_branch_on_merge
  auto_init                               = var.auto_init
  gitignore_template                      = var.gitignore_template
  license_template                        = var.license_template
  archived                                = var.archived
  archive_on_destroy                      = var.archive_on_destroy
  topics                                  = var.topics
  vulnerability_alerts                    = var.vulnerability_alerts
  ignore_vulnerability_alerts_during_read = var.ignore_vulnerability_alerts_during_read
  allow_update_branch                     = var.allow_update_branch

  dynamic "pages" {
    for_each = var.pages != null ? [true] : []
    content {
      dynamic "source" {
        for_each = var.pages.source != null ? [true] : []
        content {
          branch = var.pages.source.branch
          path   = var.pages.source.path
        }
      }
      build_type = var.pages.build_type
      cname      = var.pages.cname
    }
  }

  dynamic "security_and_analysis" {
    for_each = var.security_and_analysis != null ? [true] : []
    content {
      dynamic "advanced_security" {
        for_each = var.security_and_analysis.advanced_security != null ? [true] : []
        content {
          status = var.security_and_analysis.advanced_security.status
        }
      }
      dynamic "secret_scanning" {
        for_each = var.security_and_analysis.secret_scanning != null ? [true] : []
        content {
          status = var.security_and_analysis.secret_scanning.status
        }
      }
      dynamic "secret_scanning_push_protection" {
        for_each = var.security_and_analysis.secret_scanning_push_protection != null ? [true] : []
        content {
          status = var.security_and_analysis.secret_scanning_push_protection.status
        }
      }
    }
  }

  dynamic "template" {
    for_each = var.template != null ? [true] : []
    content {
      owner                = var.template.owner
      repository           = var.template.repository
      include_all_branches = var.template.include_all_branches
    }
  }

  lifecycle {
    precondition {
      condition     = var.squash_merge_commit_title != null ? var.allow_squash_merge ? true : false : true
      error_message = "`squash_merge_commit_title` is only applicable if `allow_squash_merge` is true."
    }

    precondition {
      condition     = var.squash_merge_commit_message != null ? var.allow_squash_merge ? true : false : true
      error_message = "`squash_merge_commit_message` is only applicable if `allow_squash_merge` is true."
    }

    precondition {
      condition     = var.merge_commit_title != null ? var.allow_merge_commit ? true : false : true
      error_message = "`merge_commit_title` is only applicable if `allow_merge_commit` is true."
    }

    precondition {
      condition     = var.merge_commit_message != null ? var.allow_merge_commit ? true : false : true
      error_message = "`merge_commit_message` is only applicable if `allow_merge_commit` is true."
    }
  }

}

resource "github_branch_protection_v3" "this" {
  repository                      = github_repository.this.name
  branch                          = var.branch
  enforce_admins                  = var.enforce_admins
  require_signed_commits          = var.require_signed_commits
  require_conversation_resolution = var.require_conversation_resolution

  dynamic "required_status_checks" {
    for_each = var.required_status_checks != null ? [true] : []
    content {
      strict = var.required_status_checks.strict
      checks = var.required_status_checks.checks
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = var.required_pull_request_reviews != null ? [true] : []
    content {
      dismiss_stale_reviews           = var.required_pull_request_reviews.dismiss_stale_reviews
      dismissal_users                 = var.required_pull_request_reviews.dismissal_users
      dismissal_teams                 = var.required_pull_request_reviews.dismissal_teams
      dismissal_apps                  = var.required_pull_request_reviews.dismissal_apps
      require_code_owner_reviews      = var.required_pull_request_reviews.require_code_owner_reviews
      required_approving_review_count = var.required_pull_request_reviews.required_approving_review_count
      dynamic "bypass_pull_request_allowances" {
        for_each = var.required_pull_request_reviews.bypass_pull_request_allowances != null ? [true] : []
        content {
          users = var.required_pull_request_reviews.bypass_pull_request_allowances.users
          teams = var.required_pull_request_reviews.bypass_pull_request_allowances.teams
          apps  = var.required_pull_request_reviews.bypass_pull_request_allowances.apps
        }
      }
    }
  }

  dynamic "restrictions" {
    for_each = var.restrictions != null ? [true] : []
    content {
      users = var.restrictions.users
      teams = var.restrictions.teams
      apps  = var.restrictions.apps
    }
  }

}

resource "github_actions_secret" "this" {
  for_each        = { for secret in var.secrets : "${secret.secret_name}" => secret }
  repository      = github_repository.this.name
  secret_name     = each.value.secret_name
  plaintext_value = each.value.plaintext_value
}
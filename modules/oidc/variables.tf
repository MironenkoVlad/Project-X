variable "github_org" {
  type        = string
  description = "GitHub organisation or username."
}

variable "roles" {
  description = "Map of role-name → { repo, branch, policy_arns }."
  type = map(object({
    repo        = string
    branch      = string
    policy_arns = list(string)
  }))
}

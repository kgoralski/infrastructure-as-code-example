variable "replication_enabled" {
  type        = bool
  description = "If replication should be enabled for this cluster"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "The default map of tags."

  validation {
    condition = (
      length(var.tags) > 0
    )

    error_message = "Tags must not be empty."
  }
}

variable "repositories" {
  type = map(object({
    name            = string
    mutable         = bool
    scan_on_push    = bool
    policy_template = string
    expiration_days = number
  }))

  description = "The map of repositories to create."

  validation {
    condition = can(
      flatten(
        [
          for k, v in var.repositories : [
            regex("^[a-z0-9-]{3,64}$", v.name),
            length(trimspace(v.policy_template)) > 0
          ]
        ]
      )
    )

    error_message = "Invalid format of the input. The values of `name` expected to be of the following format 'abc-abc'. The `policy_template` must not be empty."
  }
}

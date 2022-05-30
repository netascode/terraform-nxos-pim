variable "device" {
  description = "A device name from the provider configuration."
  type        = string
  default     = null
}

variable "vrfs" {
  description = <<EOT
  PIM VRF list.
  Default value `admin_state`: `true`.
  Default value `bfd`: `false`.
  Default value `bidir`: `false`.
  Default value `override`: `false`.
  Default value `interfaces.admin_state`: `true`.
  Choices `interfaces.bfd`: `unspecified`, `enabled`, `disabled`. Default value `interfaces.bfd`: `unspecified`.
  Allowed values `dr_priority`: `1`-`4294967295`. Default value `dr_priority`: `1`.
  Default value `passive`: `false`.
  Default value `sparse_mode`: `false`.
  EOT
  type = list(object({
    name        = string
    admin_state = optional(bool)
    bfd         = optional(bool)
    rps = optional(list(object({
      address     = string
      group_range = optional(string)
      bidir       = optional(bool)
      override    = optional(bool)
    })))
    anycast_rp_local_interface  = optional(string)
    anycast_rp_source_interface = optional(string)
    anycast_rps = optional(list(object({
      address     = string
      set_address = string
    })))
    interfaces = optional(list(object({
      interface   = string
      admin_state = optional(bool)
      bfd         = optional(string)
      dr_priority = optional(number)
      passive     = optional(bool)
      sparse_mode = optional(bool)
    })))
  }))
  default = []

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.rps == null ? [true] : [
        for v in value.rps : can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+$", v.address)) || v.address == null
      ]
    ]))
    error_message = "`rps.address`: Allowed formats are: `192.168.1.1`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.rps == null ? [true] : [
        for v in value.rps : can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+/\\d+$", v.group_range)) || v.group_range == null
      ]
    ]))
    error_message = "`rps.group_range`: Allowed formats are: `225.1.0.0/16`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.anycast_rps == null ? [true] : [
        for v in value.anycast_rps : can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+$", v.address)) || v.address == null
      ]
    ]))
    error_message = "`anycast_rps.address`: Allowed formats are: `10.1.1.1`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.anycast_rps == null ? [true] : [
        for v in value.anycast_rps : can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+$", v.set_address)) || v.set_address == null
      ]
    ]))
    error_message = "`anycast_rps.set_address`: Allowed formats are: `10.1.1.1`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(contains(["unspecified", "enabled", "disabled"], v.bfd), v.bfd == null)
      ]
    ]))
    error_message = "`interfaces.bfd`: Allowed values are: `unspecified`, `enabled` or `disabled`."
  }

  validation {
    condition = alltrue(flatten([
      for value in var.vrfs : value.interfaces == null ? [true] : [
        for v in value.interfaces : try(v.dr_priority >= 1 && v.dr_priority <= 4294967295, false) || v.dr_priority == null
      ]
    ]))
    error_message = "`dr_priority`: Allowed range: `1`-`4294967295`."
  }
}

variable virtual_machines {
  type        = map
  default     = {}
  description = "Identifies the object of virtual machines."
}
variable basename {
  type        = string
  description = "Base name for the resources"
}
variable proxmox_host {
  type        = string
  description = "Base name for the resources"
}
variable template_name {
  type        = string
  description = "Name of template to use for provisioning"
}
variable vmid {
  type        = string
  description = "Name of template to use for provisioning"
}
variable api_url {
  type        = string
  description = "Proxmox API URL"
}
variable api_token_id {
  type        = string
  description = "Proxmox API Token ID"
}
variable api_token_secret {
  type        = string
  description = "Proxmox API Token Secret"
}

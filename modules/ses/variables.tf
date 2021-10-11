variable "domains" {
  description = <<-EOT
    Distilled Map with respective key and values, see "local.domains" variable
  EOT
  default     = {}
}

variable "rule_set_name" {
  description = "Receipt Rule Set name"
  default     = ""
}

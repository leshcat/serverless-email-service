variable "domains" {
  description = <<-EOT
    Distilled Map with respective key and values, see "local.domains" variable
  EOT
  default     = {}
}

variable "code_uri" {
  description = "Code location uri"
  default     = "https://raw.githubusercontent.com/arithmetric/aws-lambda-ses-forwarder"
}

variable "code_tag" {
  description = "Code version tag"
  default     = ""
}

variable "zip_path" {
  description = "Path to zip archive to upload to lambda"
  default     = ""
}

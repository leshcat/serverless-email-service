variable "default_tags" {
  description = "Default resource tags"
  type        = map(string)
  default     = {}
}

variable "config" {
  description = "Map of Domain names as a keys and their respective lambda configs"
  default     = {}
}

variable "rule_set_name" {
  description = "Receipt Rule Set name"
  default     = ""
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

variable "lambda_postfix" {
  description = "AWS Lambda name"
  default     = ""
}

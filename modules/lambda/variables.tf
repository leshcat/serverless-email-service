variable "domains" {
  description = <<-EOT
    Distilled Map with respective key and values, see "local.domains" variable
  EOT
  default     = {}
}

variable "lambda_payloads" {
  description = <<-EOT
    A Map where:
    key: domain
    values: keys = output_path, output_base64sha256
    example.com = {
      output_base64sha256 = "S4Kn/nSfd8H3f+QhkYQCVqgAAA64KCxDix2Xa8hnwY0="
      output_path         = "/tmp/workbench/example.com-lambda.zip"
    }
  EOT
  default     = {}
}

variable "lambda_postfix" {
  description = "AWS Lambda name"
  default     = ""
}

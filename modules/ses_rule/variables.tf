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

variable "lambda_arns" {
  description = <<-EOT
    A Map where:
    key: domain
    values: keys = arn
    example.com = {
      arn = "arn:aws:lambda:us-east-1:45748384954:function:examplecom-us-east-1-SESForwarder"
    }
  EOT
  default     = {}
}

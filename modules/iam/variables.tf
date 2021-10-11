variable "users" {
  description = <<-EOT
    A Map where:
    key: IAM Group Name
    values: keys = iam_users
    us-east-1-example.com-ses = {
      iam_users = [
        "us-east-1-doge@example.com",
        "us-east-1-benita@example.com",
      ]
    }
  EOT
  default     = {}
}

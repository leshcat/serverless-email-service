terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  default_tags {
    tags = merge(
      var.default_tags,
      {
        ### you can add specific extra tags, example:
        #Owner = "the Doge"
      },
    )
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name

  domains = {
    for domain, payload in var.config : "${domain}" => {
      "bucket"        = var.config[domain].emailBucket
      "folder"        = var.config[domain].emailKeyPrefix
      "recipients"    = keys(var.config[domain].forwardMapping)
      "lambda_config" = var.config[domain]
    }
  }

  file_prefix  = "${local.aws_account_id}-${local.aws_region}"
  file_records = <<-EOT
    ${local.file_prefix}-dns-records.txt
  EOT
}

# output "debug_locals" {
#   value = {
#     domains     = local.domains
#     file_prefix = local.file_prefix
#   }
# }

module "s3" {
  source = "../../modules/s3"

  domains = local.domains
}

module "ses" {
  source = "../../modules/ses"

  domains       = local.domains
  rule_set_name = var.rule_set_name
}

resource "local_file" "this" {
  filename = "${path.module}/../../outputs/${chomp(local.file_records)}"
  content = jsonencode({
    for key, values in module.ses.verification_tokens : key =>
    merge(values, module.ses.dkim_tokens[key])
  })
}

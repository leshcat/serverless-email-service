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

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "${var.tfstate_bucket}"
    key    = "infra/terraform.tfstate"
  }
}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name

  domains       = data.terraform_remote_state.infra.outputs.domains
  rule_set_name = data.terraform_remote_state.infra.outputs.rule_set_name

  users = {
    for domain, payload in local.domains :
    "${local.aws_region}-${domain}-${local.rule_set_name}" => {
      "iam_users" = formatlist(
        "${local.aws_region}-%s",
        local.domains[domain].recipients
      )
    }
  }

  file_prefix  = "${local.aws_account_id}-${local.aws_region}"
  file_records = <<-EOT
    ${local.file_prefix}-ses-credentials.txt
  EOT
}

# output "debug_locals" {
#   value = {
#     domains       = local.domains
#     rule_set_name = local.rule_set_name
#     users         = local.users
#     file_prefix   = local.file_prefix
#     users         = local.users
#   }
# }

module "ses_rule" {
  source = "../../modules/ses_rule"

  domains       = local.domains
  rule_set_name = local.rule_set_name
  lambda_arns   = module.lambda.lambda_arns
}

module "iam" {
  source = "../../modules/iam"

  users = local.users
}

module "code" {
  source = "../../modules/code"

  domains  = local.domains
  code_uri = var.code_uri
  code_tag = var.code_tag
  zip_path = var.zip_path
}

module "lambda" {
  source = "../../modules/lambda"

  domains         = local.domains
  lambda_payloads = module.code.lambda_payloads
  lambda_postfix  = "${local.aws_region}-${var.lambda_postfix}"

  depends_on = [
    module.code
  ]
}

resource "local_file" "this" {
  filename = "${path.module}/../../outputs/${chomp(local.file_records)}"
  content  = jsonencode(merge(module.iam.smtp_server, module.iam.smtp_credentials))
}

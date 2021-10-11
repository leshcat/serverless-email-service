resource "aws_ses_receipt_rule" "rules" {
  for_each      = toset(keys(var.domains))
  name          = each.key
  rule_set_name = var.rule_set_name
  recipients    = var.domains[each.value].recipients

  enabled      = true
  tls_policy   = "Require"
  scan_enabled = true

  s3_action {
    bucket_name       = var.domains[each.key].bucket
    object_key_prefix = var.domains[each.key].folder
    position          = 1
  }

  lambda_action {
    function_arn    = var.lambda_arns[each.key].arn
    invocation_type = "Event"
    position        = 2
  }
}

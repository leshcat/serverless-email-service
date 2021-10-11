resource "aws_ses_domain_identity" "domains" {
  for_each = toset(keys(var.domains))
  domain   = each.key
}

resource "aws_ses_domain_dkim" "dkims" {
  for_each = toset(keys(var.domains))
  domain   = aws_ses_domain_identity.domains[each.key].domain
}

resource "aws_ses_receipt_rule_set" "this" {
  rule_set_name = var.rule_set_name
}

resource "aws_ses_active_receipt_rule_set" "this" {
  rule_set_name = var.rule_set_name

  depends_on = [
    aws_ses_receipt_rule_set.this,
  ]
}

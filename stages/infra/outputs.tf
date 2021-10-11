output "domains" {
  value = local.domains
}

output "rule_set_name" {
  value = module.ses.rule_set_name
}

output "verification_tokens" {
  value = module.ses.verification_tokens
}

output "dkim_tokens" {
  value = module.ses.dkim_tokens
}

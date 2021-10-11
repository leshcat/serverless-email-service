output "rule_set_name" {
  value = aws_ses_receipt_rule_set.this.id
}

output "verification_tokens" {
  value = {
    for index, domain in aws_ses_domain_identity.domains : index => {
      "verification" = {
        name    = "_amazonses.${aws_ses_domain_identity.domains[index].id}"
        type    = "TXT"
        ttl     = "600"
        record  = aws_ses_domain_identity.domains[index].verification_token
      }
    }
  }
}

output "dkim_tokens" {
  value = {
    for domain, info in aws_ses_domain_dkim.dkims : domain =>
    {
      for index, token in info.dkim_tokens : "dkim-${index}" => {
        name    = "${token}._domainkey"
        type    = "CNAME"
        ttl     = "600"
        record  = "${token}.dkim.amazonses.com"
      }
    }
  }
}

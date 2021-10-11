output "smtp_server" {
  value = {
    "smtp_server" = {
      name = "email-smtp.${local.aws_region}.amazonaws.com"
      port = "587"
    }
  }
}

output "smtp_credentials" {
  value = {
    for index, user in aws_iam_user.users : index => {
      email    = trimprefix("${user.id}", "${local.aws_region}-")
      login    = aws_iam_access_key.logins[index].id
      password = data.template_file.passwords[index].rendered
    }
  }
}

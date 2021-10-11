### create AWS IAM users and get their logins & smtp passwords
### NOTE: passwords are unencrypted, revise if necessary

data "aws_region" "current" {}

locals {
  aws_region = data.aws_region.current.name

  iam_users = flatten([
    for k, v in var.users : v.iam_users
  ])
}

resource "aws_iam_user" "users" {
  for_each = toset(local.iam_users)
  name     = each.key
}

resource "aws_iam_access_key" "logins" {
  for_each = toset(local.iam_users)
  user     = aws_iam_user.users[each.key].name
}

data "template_file" "passwords" {
  for_each = toset(local.iam_users)
  template = aws_iam_access_key.logins[each.key].ses_smtp_password_v4
}

resource "aws_iam_group" "groups" {
  for_each = toset(keys(var.users))
  name     = each.key

  depends_on = [
    aws_iam_user.users
  ]
}

resource "aws_iam_group_policy" "policies" {
  for_each = toset(keys(var.users))
  name     = "AmazonSesSendingAccess"
  group    = aws_iam_group.groups[each.key].name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "ses:SendRawEmail",
        "Resource" : "*"
      }
    ]
  })

  depends_on = [
    aws_iam_group.groups
  ]
}

resource "aws_iam_group_membership" "memberships" {
  for_each = toset(keys(var.users))

  name  = each.key
  users = toset((var.users[each.key].iam_users))
  group = each.key

  depends_on = [
    aws_iam_user.users,
    aws_iam_group.groups
  ]
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "functions" {
  for_each      = toset(keys(var.domains))
  filename      = var.lambda_payloads[each.key].output_path
  function_name = "${replace(tostring(each.key), ".", "")}-${var.lambda_postfix}"
  role          = aws_iam_role.roles[each.key].arn
  handler       = "index.handler"

  source_code_hash = var.lambda_payloads[each.key].output_base64sha256

  runtime = "nodejs12.x"

}

resource "aws_lambda_permission" "permissions" {
  for_each       = toset(keys(var.domains))
  statement_id   = "allowSesInvoke"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.functions[each.key].function_name
  principal      = "ses.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
}

resource "aws_iam_role" "roles" {
  for_each = toset(keys(var.domains))
  name     = "${replace(tostring(each.key), ".", "")}-${var.lambda_postfix}"

  assume_role_policy = <<-EOT
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
  EOT

  inline_policy {
    name = "${replace(tostring(each.key), ".", "")}-${var.lambda_postfix}"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "s3:PutStorageLensConfiguration",
            "s3:CreateJob",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "VisualEditor1",
          "Effect" : "Allow",
          "Action" : [
            "s3:PutObject",
            "s3:GetObject"
          ],
          "Resource" : [
            "arn:aws:ses:us-east-1:${data.aws_caller_identity.current.account_id}:identity/*",
            "arn:aws:s3:::${var.domains[each.key].bucket}/${var.domains[each.key].folder}*"
          ]
        },
        {
          "Sid" : "VisualEditor2",
          "Effect" : "Allow",
          "Action" : "ses:SendRawEmail",
          "Resource" : "arn:aws:ses:us-east-1:${data.aws_caller_identity.current.account_id}:identity/*"
        }
      ]
    })
  }

}

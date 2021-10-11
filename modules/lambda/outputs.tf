output "lambda_arns" {
  value = {
    for domain in toset(keys(var.domains)) : domain => {
      arn = aws_lambda_function.functions[domain].arn
    }
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "buckets" {
  for_each = toset(keys(var.domains))
  bucket   = var.domains[each.key].bucket
  acl      = "private"

  lifecycle_rule {
    id     = var.domains[each.key].folder
    prefix = var.domains[each.key].folder

    enabled = true
    expiration {
      days = 3
    }
  }

  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

}

resource "aws_s3_bucket_public_access_block" "accesses" {
  for_each = toset(keys(var.domains))
  bucket   = aws_s3_bucket.buckets[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.buckets
  ]
}

resource "aws_s3_bucket_object" "folders" {
  for_each = toset(keys(var.domains))
  bucket   = aws_s3_bucket.buckets[each.key].id
  acl      = "private"

  key = var.domains[each.key].folder

  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }

}

resource "aws_s3_bucket_policy" "policies" {
  for_each = toset(keys(var.domains))
  bucket   = aws_s3_bucket.buckets[each.key].id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowSESPuts-${aws_s3_bucket.buckets[each.key].id}",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ses.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.buckets[each.key].id}/${var.domains[each.key].folder}*"
        "Condition" : {
          "StringEquals" : {
            "aws:Referer" : "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}

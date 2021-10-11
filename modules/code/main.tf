data "http" "this" {
  url = "${var.code_uri}/${var.code_tag}/index.js"
}

resource "local_file" "cores" {
  for_each = toset(keys(var.domains))
  filename = "${dirname(var.zip_path)}/${each.key}-lambda/aws-lambda-ses-forwarder/index.js"
  content  = data.http.this.body
}

data "template_file" "overrides" {
  for_each = toset(keys(var.domains))
  template = file("${path.module}/templates/index.js.tpl")
  vars = {
    lambda_config = jsonencode(var.domains[each.key].lambda_config)
  }
}

resource "local_file" "overrides" {
  for_each = toset(keys(var.domains))
  filename = "${dirname(var.zip_path)}/${each.key}-lambda/index.js"
  content  = data.template_file.overrides[each.key].rendered
}

data "archive_file" "archives" {
  for_each         = toset(keys(var.domains))
  type             = "zip"
  source_dir       = "${dirname(var.zip_path)}/${each.key}-lambda"
  output_file_mode = "0666"
  output_path      = "${dirname(var.zip_path)}/${each.key}-${basename(var.zip_path)}"

  depends_on = [
    local_file.cores,
    local_file.overrides
  ]
}

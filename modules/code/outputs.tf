output "lambda_payloads" {
  value = {
    for key, values in data.archive_file.archives : key => {
      output_path         = values.output_path,
      output_base64sha256 = values.output_base64sha256
    }
  }
}

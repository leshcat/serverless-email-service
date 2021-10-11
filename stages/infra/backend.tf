terraform {
  backend "s3" {
    key     = "infra/terraform.tfstate"
    encrypt = true
  }
}

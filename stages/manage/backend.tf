terraform {
  backend "s3" {
    key     = "manage/terraform.tfstate"
    encrypt = true
  }
}

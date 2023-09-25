terraform {
  backend "s3" {
    bucket = "terraform-files-1"
    key = "terraform.tfstate"
    region = "eu-central-1"
  }
}

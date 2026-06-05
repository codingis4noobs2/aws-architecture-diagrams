terraform {
  backend "s3" {
    bucket         = "youholdbutter"
    key            = "bastion/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

terraform {
  backend "s3" {
    bucket = "terraform-state-backend-10072023"
    key    = "state/.tfstate"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "s3_backend" {
  bucket = "terraform-state-backend-10072023"
}


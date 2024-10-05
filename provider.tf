terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"  # Corrected region syntax
  # Other Configuration options (like access_key, secret_key, etc.)
}

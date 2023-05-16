# This file defines the basic terraform configurations like the terraform version to use
# the provider, and the AWS account to which the terraform commands should be applied


terraform {
 required_version = "1.3.7"
 required_providers {           # this ensures that the AWS provider is used by Terraform
  aws = {
   source  = "hashicorp/aws"
   version = "~> 4.33.0"
  }
 }
}

provider "aws" {
  allowed_account_ids = [
       "123XXX11X8XX"          # Your 12 digit AWS account ID
  ]                            # This ensures that the terraform commands you run will apply in the specified AWS account
}

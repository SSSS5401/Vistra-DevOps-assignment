# Using a single workspace:
terraform {
  #   backend "remote" {
  #     hostname     = "app.terraform.io"
  #     organization = "Nakiri-Self-Testing"

  #     workspaces {
  #       name = "AWS-IAM-Management"
  #     }
  #   }
  backend "local" {
  }
}
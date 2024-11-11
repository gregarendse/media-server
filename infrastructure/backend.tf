# Backend configurations, see: https://developer.hashicorp.com/terraform/language/backend
# https://thegeeklab.de/posts/2022/09/store-terraform-state-on-backblaze-s3/
terraform {
  backend "s3" {
    key = "state"

  }
}


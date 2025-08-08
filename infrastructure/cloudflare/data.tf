# Data source to read remote state from network project
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "gregarendse-terraform"
    key    = "network/state.json"

    # Using Backblaze B2 - these validations do not apply
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

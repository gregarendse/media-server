variable "cloudflare_api_token" {
  description = "The API token for your Cloudflare account."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "domain_name" {
  description = "The domain name to be managed by Cloudflare."
  type        = string
  nullable    = false
}

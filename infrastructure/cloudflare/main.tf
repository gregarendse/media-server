# This is the zone that will be managed by Cloudflare
# data "cloudflare_zones" "zones" {
#   name  = var.domain_name
#   match = "all"
# }

data "cloudflare_zone" "zone" {
  filter = {
    name = var.domain_name
  }
}

resource "cloudflare_dns_record" "echo" {
  zone_id = data.cloudflare_zone.zone.zone_id

  name    = "echo.${var.domain_name}"
  comment = "Echo service DNS record"
  content = data.terraform_remote_state.network.outputs.public_id.ip_address

  type    = "A"
  ttl     = 3600 # ttl must be set to 1 when proxied is true
  proxied = false
}

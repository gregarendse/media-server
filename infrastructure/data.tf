data "oci_identity_compartment" "root" {
  id = var.tenancy_ocid
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = data.oci_identity_compartment.root.id
}

data "oci_core_instance_pool_instances" "instances" {
  compartment_id   = oci_identity_compartment.homelab.id
  instance_pool_id = oci_core_instance_pool.ubuntu.id
}

# Get Admin public IP
data "http" "public_ip" {
  # curl \  
  # --http2 --header "accept: application/dns-json" "https://1.1.1.1/dns-query?name=cloudflare.com" \
  # --next --http2 --header "accept: application/dns-json" "https://1.1.1.1/dns-query?name=example.com"
  # request_headers = {
  # }
  
  url = "https://api.ipify.org?format=text"
}
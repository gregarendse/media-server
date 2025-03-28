# Outputs for the vcn module

output "nlb_ip_addresses" {
  value = oci_network_load_balancer_network_load_balancer.public.ip_addresses
}

output "compartment" {
  value = data.oci_identity_compartment.homelab
}

output "vcn" {
  value = data.oci_core_vcn.homelab
}

output "public_id" {
  value = oci_core_public_ip.kubernetes
}

data "oci_core_nat_gateways" "nat_gateways" {
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id
}

data "oci_core_nat_gateway" "nat_gateway" {
  nat_gateway_id = data.oci_core_nat_gateways.nat_gateways.nat_gateways[0].id
}

resource "oci_core_route_table" "public" {
  display_name = "public"

  # Required
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id

  # Route all traffic to internet gateway
  route_rules {
    description       = "Route to Internet Gateway"
    network_entity_id = data.oci_core_internet_gateways.internet_gateways.gateways[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = merge(var.tags, {})
}

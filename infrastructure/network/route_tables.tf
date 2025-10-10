data "oci_core_nat_gateways" "nat_gateways" {
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id
}

data "oci_core_nat_gateway" "nat_gateway" {
  nat_gateway_id = data.oci_core_nat_gateways.nat_gateways.nat_gateways[0].id
}

data "oci_core_drgs" "drgs" {
  compartment_id = data.oci_identity_compartment.homelab.id
}

output "drg_attachment" {
  value = data.oci_core_drgs.drgs
}

resource "oci_core_route_table" "public" {
  display_name = "public"

  # Required
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id

  route_rules {
    description       = "Home local network"
    destination       = "192.168.1.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_drgs.drgs.drgs[0].id # "ocid1.drg.oc1.uk-london-1.aaaaaaaascl6zj5ntokooatwsxwrm7nhswzczvsfqal2cyfxutab5nshuqgq"
  }

  # Route all traffic to internet gateway
  route_rules {
    description       = "Route to Internet Gateway"
    network_entity_id = data.oci_core_internet_gateways.internet_gateways.gateways[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  freeform_tags = merge(var.tags, {})
}

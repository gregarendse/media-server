# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "private" {
  display_name = "private"

  # Required
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id
  # module.vcn.vcn_id
  cidr_block = local.subnet_private_cdir

  # Optional
  # Caution: For the route table id, use module.vcn.nat_route_id.
  # Do not use module.vcn.nat_gateway_id, because it is the OCID for the gateway and not the route table.
  # route_table_id = module.vcn.nat_route_id
  security_list_ids = [
    oci_core_security_list.private.id,
  ]

  freeform_tags = merge(var.tags, {})

}

# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "public" {
  display_name = "public"

  # Required
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id
  # module.vcn.vcn_id
  cidr_block = local.subnet_public_cdir

  # Optional
  route_table_id = oci_core_route_table.public.id
  security_list_ids = [
    oci_core_security_list.public.id
  ]

  freeform_tags = merge(var.tags, {})

}

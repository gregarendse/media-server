data "oci_identity_compartments" "compartments" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  name                      = var.compartment_name
  state                     = "ACTIVE"
}

data "oci_identity_compartment" "homelab" {
  id = data.oci_identity_compartments.compartments.compartments[0].id
}

data "oci_core_vcns" "vcn" {
  compartment_id = data.oci_identity_compartment.homelab.id
  display_name   = "homelab"
  state          = "AVAILABLE"
}

data "oci_core_vcn" "homelab" {
  vcn_id = data.oci_core_vcns.vcn.virtual_networks[0].id
}

data "oci_core_internet_gateways" "internet_gateways" {
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id
}

data "oci_core_subnets" "public_subnets" {
  compartment_id = data.oci_identity_compartment.homelab.id

  vcn_id       = data.oci_core_vcn.homelab.id
  state        = "AVAILABLE"
  display_name = "public"
}

data "oci_core_subnet" "public" {
  subnet_id = data.oci_core_subnets.public_subnets.subnets[0].id
}

data "oci_core_subnets" "private_subnets" {
  compartment_id = data.oci_identity_compartment.homelab.id

  vcn_id       = data.oci_core_vcn.homelab.id
  state        = "AVAILABLE"
  display_name = "private"
}

data "oci_core_subnet" "private" {
  subnet_id = data.oci_core_subnets.private_subnets.subnets[0].id
}

data "oci_core_instances" "instances" {
  compartment_id = data.oci_identity_compartment.homelab.id
  filter {
    name   = "state"
    values = ["RUNNING"]
  }
}

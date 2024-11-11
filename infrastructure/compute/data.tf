data "oci_identity_compartment" "root" {
  id = var.tenancy_ocid
}

data "oci_identity_compartments" "compartments" {
  compartment_id            = var.tenancy_ocid
  compartment_id_in_subtree = true
  name                      = var.compartment_name
  state                     = "ACTIVE"
}

data "oci_identity_compartment" "homelab" {
  id = data.oci_identity_compartments.compartments.compartments[0].id
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = data.oci_identity_compartment.root.id
}

data "oci_core_vcns" "vcn" {
  compartment_id = data.oci_identity_compartment.homelab.id
  display_name   = "homelab"
  state          = "AVAILABLE"
}

data "oci_core_subnets" "subnets" {
  compartment_id = data.oci_identity_compartment.homelab.id

  vcn_id       = data.oci_core_vcns.vcn.virtual_networks[0].id
  state        = "AVAILABLE"
  display_name = "public"
}

data "oci_core_subnet" "public" {
  subnet_id = data.oci_core_subnets.subnets.subnets[0].id
}

data "oci_core_images" "images" {
  compartment_id           = data.oci_identity_compartment.root.id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  sort_by = "TIMECREATED"
  sort_order = "DESC"
  shape = var.shape
}

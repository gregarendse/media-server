data "oci_identity_compartment" "root" {
  id = var.tenancy_ocid
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = data.oci_identity_compartment.root.id
}

output "availability_domains" {
  value = data.oci_identity_availability_domains.availability_domains
}

output "root" {
  value = data.oci_identity_compartment.root
}

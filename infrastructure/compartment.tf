
resource "oci_identity_compartment" "homelab" {
  # Required
  compartment_id = data.oci_identity_compartment.root.compartment_id
  description    = "Compartment for Terraform resources."
  name           = var.compartment_name
}

output "compartment_homelab" {
  value = oci_identity_compartment.homelab
}
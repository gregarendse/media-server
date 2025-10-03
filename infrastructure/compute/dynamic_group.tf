resource "oci_identity_dynamic_group" "k3s_nodes" {
  compartment_id = data.oci_identity_compartment.root.id
  name           = "k3s-nodes"
  description    = "Dynamic group for self-managed k3s cluster nodes to connect to OCI"

  matching_rule = "ALL {instance.compartment.id = '${data.oci_identity_compartment.homelab.id}'}"
}

resource "oci_identity_policy" "k3s_nodes_policy" {
  compartment_id = data.oci_identity_compartment.homelab.id
  name           = "k3s-nodes"
  description    = "Policy to allow k3s nodes dynamic group to manage resources in homelab compartment"

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_nodes.name} to read instance-family in compartment ${data.oci_identity_compartment.homelab.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.k3s_nodes.name} to use virtual-network-family in compartment ${data.oci_identity_compartment.homelab.name}",
  ]
}

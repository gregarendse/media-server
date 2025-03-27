
resource "oci_core_public_ip" "kubernetes" {
  compartment_id = data.oci_identity_compartment.homelab.id
  display_name   = "Kubernetes"
  lifetime       = "RESERVED"

  freeform_tags = merge(var.tags, {})
}

# resource "oci_core_network_security_group" "kubernetes" {
#   compartment_id = data.oci_identity_compartment.homelab.id
#   vcn_id         = data.oci_core_vcn.homelab.id

#   display_name = "Kubernetes"

#   freeform_tags = merge(var.tags, {})
# }

# resource "oci_core_network_security_group_security_rule" "ingress_tcp" {
#   for_each = {
#     for port in local.public_ports : port.name => port
#   }

#   network_security_group_id = oci_core_network_security_group.kubernetes.id

#   direction = "INGRESS"
#   protocol  = local.protocol_numbers.TCP

#   source      = "0.0.0.0/0"
#   source_type = "CIDR_BLOCK"

#   tcp_options {
#     destination_port_range {
#       min = each.value.ports.listener
#       max = each.value.ports.listener
#     }
#   }
# }

# resource "oci_core_network_security_group_security_rule" "egress_tcp" {
#   network_security_group_id = oci_core_network_security_group.kubernetes.id

#   direction = "EGRESS"
#   protocol  = local.protocol_numbers.TCP

#   destination      = "0.0.0.0/0"
#   destination_type = "CIDR_BLOCK"
# }

resource "oci_network_load_balancer_network_load_balancer" "public" {
  compartment_id = data.oci_identity_compartment.homelab.id

  display_name = "public"

  subnet_id = data.oci_core_subnet.public.id

  is_private = false

  nlb_ip_version = "IPV4"
  # is_preserve_source_destination = false
  # is_symmetric_hash_enabled      = false

  # network_security_group_ids = [
  #   oci_core_network_security_group.kubernetes.id
  # ]

  # reserved_ips {
  #   id = oci_core_public_ip.kubernetes.id
  # }

  freeform_tags = merge(var.tags, {})
}


module "listeners" {
  source = "../modules/oracle/networking/network-load-balancer/listener"

  for_each = {
    for port in local.ports : port.name => port
    if port.public == true
  }

  load_balancer_id = oci_network_load_balancer_network_load_balancer.public.id

  name         = each.value.name
  protocol     = each.value.protocol
  health_check = each.value.health_check
  ports        = each.value.ports
  instances    = data.oci_core_instances.instances.instances
}

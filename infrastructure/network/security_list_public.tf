# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list

resource "oci_core_security_list" "public" {

  # Required
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id
  # module.vcn.vcn_id

  # Optional
  display_name = "public"


  # Allow all outbound traffic to any destination
  egress_security_rules {
    description      = "Egress ALL"
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  dynamic "ingress_security_rules" {
    for_each = {
      for i in local.ports : i.name => i
      if i.public == true
    }
    iterator = port_rule

    content {
      # Allow inbound Kube API traffic from any source
      description = port_rule.value.notes
      protocol    = port_rule.value.protocol == "HTTPS" ? local.protocol_numbers.TCP : (port_rule.value.protocol == "TCP" ? local.protocol_numbers.TCP : local.protocol_numbers.UDP)
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"

      dynamic "tcp_options" {
        for_each = port_rule.value.protocol == "TCP" || port_rule.value.protocol == "HTTPS" ? [1] : []
        content {
          min = port_rule.value.ports.listener
          max = port_rule.value.ports.listener
        }
      }

      dynamic "udp_options" {
        for_each = port_rule.value.protocol == "UDP" ? [1] : []
        content {
          min = port_rule.value.ports.listener
          max = port_rule.value.ports.listener
        }
      }
    }
  }


  ingress_security_rules {
    description = "Ingress ICMP Destination Unreachable"
    stateless   = false
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1  
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    description = "Allow all VCN traffic"
    source      = data.oci_core_vcn.homelab.cidr_block
    protocol    = "all"
  }

  freeform_tags = merge(var.tags, {})
}

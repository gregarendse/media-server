# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list

resource "oci_core_security_list" "private" {
  # Required
  compartment_id = data.oci_identity_compartment.homelab.id
  vcn_id         = data.oci_core_vcn.homelab.id

  # Optional
  display_name = "private"

  egress_security_rules {
    description      = "Egress ALL"
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  dynamic "ingress_security_rules" {
    for_each = local.ports
    iterator = port_rule
    content {
      description = port_rule.value.notes
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = port_rule.value.protocol == "HTTPS" ? local.protocol_numbers.TCP : (port_rule.value.protocol == "TCP" ? local.protocol_numbers.TCP : local.protocol_numbers.UDP)

      dynamic "tcp_options" {
        for_each = port_rule.value.protocol == "TCP" || port_rule.value.protocol == "HTTPS" ? [1] : []
        content {
          min = port_rule.value.port
          max = port_rule.value.port
        }
      }

      dynamic "udp_options" {
        for_each = port_rule.value.protocol == "UDP" ? [1] : []
        content {
          min = port_rule.value.port
          max = port_rule.value.port
        }
      }
    }
  }

  dynamic "ingress_security_rules" {
    for_each = {
      for i in local.ports : i.name => i
      if i.public == true
    }
    iterator = port_rule
    content {
      description = port_rule.value.notes
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      protocol    = port_rule.value.protocol == "HTTPS" ? local.protocol_numbers.TCP : (port_rule.value.protocol == "TCP" ? local.protocol_numbers.TCP : local.protocol_numbers.UDP)

      dynamic "tcp_options" {
        for_each = port_rule.value.protocol == "TCP" || port_rule.value.protocol == "HTTPS" ? [1] : []
        content {
          min = port_rule.value.port
          max = port_rule.value.port
        }
      }

      dynamic "udp_options" {
        for_each = port_rule.value.protocol == "UDP" ? [1] : []
        content {
          min = port_rule.value.port
          max = port_rule.value.port
        }
      }
    }
  }



  ingress_security_rules {
    description = "Enable all POD traffic"
    stateless   = false
    source      = local.subnet_podCIDR
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  ingress_security_rules {
    description = "Enable all Service traffic"
    stateless   = false
    source      = local.subnet_serviceCIDR
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }

  ingress_security_rules {
    description = "Ingress SSH from Home"
    stateless   = false
    source      = "192.168.1.0/24"
    source_type = "CIDR_BLOCK"
    protocol    = local.protocol_numbers.TCP
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "Ingress ICMP Destination Unreachable (private)"
    stateless   = false
    source      = local.subnet_private_cdir
    source_type = "CIDR_BLOCK"
    protocol    = local.protocol_numbers.ICMP
    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    description = "Ingress ICMP Destination Unreachable (public)"
    stateless   = false
    source      = local.subnet_public_cdir
    source_type = "CIDR_BLOCK"
    protocol    = local.protocol_numbers.ICMP
    icmp_options {
      type = 3
      code = 4
    }
  }

  freeform_tags = merge(var.tags, {})
}

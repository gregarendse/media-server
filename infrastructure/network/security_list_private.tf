# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list

locals {
  kubernetes_ports = [
    # Kubernetes Ports
    # Protocol     Port     Service     Direction     Notes
    {
      # TCP     2380     etcd peers     controller <-> controller     
      name     = "etcd-peers"
      protocol = "TCP"
      port     = 2380
      notes    = "controller <-> controller"
    },
    {
      # TCP     179     kube-router     worker <-> worker     BGP routing sessions between peers
      name     = "kube-router"
      protocol = "TCP"
      port     = 179
      notes    = "worker <-> worker     BGP routing sessions between peers"
    },
    {
      # UDP     4789     Calico     worker <-> worker     Calico VXLAN overlay
      name     = "calico"
      protocol = "UDP"
      port     = 4789
      notes    = "worker <-> worker     Calico VXLAN overlay"
    },
    {
      # TCP     10250     kubelet     controller, worker => host *     Authenticated kubelet API for the controller node kube-apiserver (and heapster/metrics-server addons) using TLS client certs
      name     = "kubelet"
      protocol = "TCP"
      port     = 10250
      notes    = "controller, worker => host *     Authenticated kubelet API for the controller node kube-apiserver (and heapster/metrics-server addons) using TLS client certs"
    },
    {
      # TCP     8132     konnectivity     worker <-> controller     Konnectivity is used as "reverse" tunnel between kube-apiserver and worker kubelets
      name     = "konnectivity"
      protocol = "TCP"
      port     = 8132
      notes    = "worker <-> controller     Konnectivity is used as reverse tunnel between kube-apiserver and worker kubelets"
    },
    {
      # adminPort admin port to listen on (default 8133)
      name     = "konnectivity-admin"
      protocol = "TCP"
      port     = 8133
      notes    = "admin port to listen on (default 8133)"

    },
    {
      # TCP     112     keepalived     controller <-> controller     Only required for control plane load balancing vrrpInstances for ip address 224.0.0.18. 224.0.0.18 is a multicast IP address defined in RFC 3768.
      name     = "keepalive"
      protocol = "TCP"
      port     = 112
      notes    = "controller <-> controller     Only required for control plane load balancing vrrpInstances for ip address 224.0.0.18. 224.0.0.18 is a multicast IP address defined in RFC 3768."
    }
  ]
}

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

  # Kubernetes Ports
  dynamic "ingress_security_rules" {
    for_each = local.kubernetes_ports
    iterator = port_rule
    content {
      description = port_rule.value.notes
      source      = local.subnet_private_cdir
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

  # Public ports
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
          min = port_rule.value.ports.target
          max = port_rule.value.ports.target
        }
      }

      dynamic "udp_options" {
        for_each = port_rule.value.protocol == "UDP" ? [1] : []
        content {
          min = port_rule.value.ports.target
          max = port_rule.value.ports.target
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

# ------ Create OCI CPE ------
resource "oci_core_cpe" "homelink" {
  compartment_id = oci_identity_compartment.homelab.id
  display_name   = "Mikrotik"
  ip_address     = data.http.public_ip.response_body
}

# ------ Create Instance Subnet ------
resource "oci_core_subnet" "vpn" {
  display_name        = "vpn"

  compartment_id      = oci_identity_compartment.homelab.id
  vcn_id              = module.vcn.vcn_id
  cidr_block          = local.subnet_vpn_cdir

  route_table_id      = oci_core_route_table.IaC_VCN_route_table.id

  security_list_ids   = [
    oci_core_security_list.security_policies.id
    ]

  freeform_tags = merge(var.tags, {})

}


# ------ Create Site-to-Site VPN ------
resource "oci_core_ipsec" "homelink" {
  compartment_id = oci_identity_compartment.homelab.id
  display_name   = "Home-Link"
  cpe_id         = oci_core_cpe.homelink.id
  drg_id         = oci_core_drg.homelink.id
  static_routes  = ["0.0.0.0/0"]
}

# ------ Create Security Policies ------
resource "oci_core_security_list" "security_policies" {
  compartment_id = oci_identity_compartment.homelab.id
  display_name   = "Home-Link Security Policy"
  vcn_id         = module.vcn.vcn_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.cidr_range
    tcp_options {
          min = 22
          max = 22
        }
  }
  ingress_security_rules {
    protocol = "6"
    source   = "192.168.0.0/16"
    tcp_options {
          min = 22
          max = 22
        }
  }

  ingress_security_rules {
    protocol = "1"
    source   = var.cidr_range
  }

  ingress_security_rules {
    protocol = "1"
    source   = "192.168.0.0/16"
  }
}

# ------ Create DRG on OCI ------
resource "oci_core_drg" "homelink" {
  compartment_id = oci_identity_compartment.homelab.id
  display_name   = "Home-Link"
}
# ------ Create DRG VCN attachment ------
resource "oci_core_drg_attachment" "homelink" {
  vcn_id             = module.vcn.vcn_id
  drg_id             = oci_core_drg.homelink.id
  display_name       = "Home-Link DRG Attachment"
}
# ------ Create VCN Route Table ------
resource "oci_core_route_table" "IaC_VCN_route_table" {
    compartment_id = oci_identity_compartment.homelab.id
    vcn_id = module.vcn.vcn_id
    display_name       = "Home-Link Routing Table"
    route_rules {
        network_entity_id = module.vcn.internet_gateway_id
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
    route_rules {
        network_entity_id = oci_core_drg.homelink.id
        destination = var.cidr_range
        destination_type = "CIDR_BLOCK"
    }
    route_rules {
        network_entity_id = oci_core_drg.homelink.id
        destination = "192.168.0.0/16"
        destination_type = "CIDR_BLOCK"
    }
}


# # Modify Tunnel 1 from static to BGP
# resource "oci_core_ipsec_connection_tunnel_management" "bgp_ip_sec_connection_tunnel_1" {
#     ipsec_id = oci_core_ipsec.aws_ipsec_connection.id
#     tunnel_id = data.oci_core_ipsec_connection_tunnels.aws_ip_sec_connection_tunnels.ip_sec_connection_tunnels[0].id
#     routing = "BGP"
#       bgp_session_info {
#         customer_bgp_asn = "64512"
#         customer_interface_ip = "169.254.150.225/30"
#         oracle_interface_ip = "169.254.150.226/30"
#     }
#     display_name = "Tunnel 1"
#     shared_secret = var.shared_secret_1
#     ike_version = "V2"
# }

# # Modify Tunnel 2 from static to BGP
# resource "oci_core_ipsec_connection_tunnel_management" "bgp_ip_sec_connection_tunnel_2" {
#     ipsec_id = oci_core_ipsec.aws_ipsec_connection.id
#     tunnel_id = data.oci_core_ipsec_connection_tunnels.aws_ip_sec_connection_tunnels.ip_sec_connection_tunnels[1].id
#     routing = "BGP"
#       bgp_session_info {
#         customer_bgp_asn = "64512"
#         customer_interface_ip = "169.254.150.230/30"
#         oracle_interface_ip = "169.254.150.229/30"
#     }
#     display_name = "Tunnel 2"
#     shared_secret = var.shared_secret_2
#     ike_version = "V2"
# }
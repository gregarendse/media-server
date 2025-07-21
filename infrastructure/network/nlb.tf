# Public Load Balancer
resource "oci_core_public_ip" "kubernetes" {
  compartment_id = data.oci_identity_compartment.homelab.id
  display_name   = "Kubernetes"
  lifetime       = "RESERVED"

  # ToDo: Replace with reference
  private_ip_id = "ocid1.privateip.oc1.uk-london-1.abwgiljr5fn4y6uuuoakjy3vkdkyen6pjqig6newy7zhl33mki7cuqlkryka"

  freeform_tags = merge(var.tags, {})
}

resource "oci_network_load_balancer_network_load_balancer" "public" {
  compartment_id = data.oci_identity_compartment.homelab.id

  display_name = "Kubernetes"

  # Public Load Balancers must be in a public subnet
  subnet_id = data.oci_core_subnet.public.id

  is_private = false

  nlb_ip_version                 = "IPV4"
  is_preserve_source_destination = false

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

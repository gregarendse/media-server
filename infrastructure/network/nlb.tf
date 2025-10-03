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

resource "oci_network_load_balancer_backend_set" "backend_set" {
  for_each = {
    for port in local.ports : port.name => port
    if port.public == true
  }
  # https://docs.oracle.com/en-us/iaas/api/#/en/networkloadbalancer/20200501/datatypes/UpdateBackendSetDetails
  # https://docs.oracle.com/en-us/iaas/api/#/en/networkloadbalancer/20200501/BackendSet/CreateBackendSet

  name                     = each.value.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.public.id
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = true
  is_fail_open             = false
  # ip_version                            = "IPV4"
  # is_instant_failover_enabled           = false
  # is_instant_failover_tcp_reset_enabled = true

  dynamic "health_checker" {
    for_each = each.value.health_check.protocol == "HTTP" || each.value.health_check.protocol == "HTTPS" ? [1] : []

    content {
      protocol    = each.value.health_check.protocol
      return_code = each.value.health_check.return_code
      url_path    = each.value.health_check.path
      port        = each.value.ports.target
    }

  }

  dynamic "health_checker" {
    for_each = each.value.health_check.protocol == "TCP" ? [1] : []

    content {
      protocol = "TCP"
    }

  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

resource "oci_network_load_balancer_listener" "listener" {
  for_each = {
    for port in local.ports : port.name => port
    if port.public == true
  }

  default_backend_set_name = each.value.name
  name                     = each.value.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.public.id

  port     = each.value.ports.listener
  protocol = each.value.protocol

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    oci_network_load_balancer_backend_set.backend_set
  ]
}

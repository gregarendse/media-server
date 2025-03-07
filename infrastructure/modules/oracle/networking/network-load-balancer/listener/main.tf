resource "oci_network_load_balancer_backend_set" "backend_set" {
  # https://docs.oracle.com/en-us/iaas/api/#/en/networkloadbalancer/20200501/datatypes/UpdateBackendSetDetails
  # https://docs.oracle.com/en-us/iaas/api/#/en/networkloadbalancer/20200501/BackendSet/CreateBackendSet

  name                                  = var.name
  network_load_balancer_id              = var.load_balancer_id
  policy                                = "TWO_TUPLE"
  is_fail_open                          = false
  ip_version                            = "IPV4"
  is_preserve_source                    = false
  is_instant_failover_enabled           = false
  is_instant_failover_tcp_reset_enabled = true

  health_checker {
    protocol    = var.health_check.protocol
    return_code = var.health_check.return_code
    url_path    = var.health_check.path
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

resource "oci_network_load_balancer_listener" "listener" {

  network_load_balancer_id = var.load_balancer_id
  default_backend_set_name = var.name

  name     = var.name
  port     = var.ports.listener
  protocol = var.protocol

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    oci_network_load_balancer_backend_set.backend_set
  ]
}

resource "oci_network_load_balancer_backend" "backend" {
  for_each = {
    for i in var.instances : i.display_name => i
  }

  network_load_balancer_id = var.load_balancer_id
  backend_set_name         = var.name

  target_id = each.value.id
  port      = var.ports.target

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [
    oci_network_load_balancer_backend_set.backend_set
  ]
}
